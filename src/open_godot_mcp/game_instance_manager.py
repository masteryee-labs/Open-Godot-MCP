"""Game Instance Manager — manage standalone game processes for multiplayer testing.

Per Docs/05-Network-Testing/Guide.md:
  Each game instance is a standalone Godot process (not PIE) with:
    - Its own game multiplayer port (OGM_GAME_PORT env)
    - A WebSocket control channel (runtime_autoload standalone mode)
    - A role: 'host' or 'client'

The MCP server connects to each game's WS server directly (no editor needed)
and routes runtime calls (state, input, exec, network_condition, etc.) to it.

This is distinct from InstanceManager which manages EDITOR instances.
"""

from __future__ import annotations

import asyncio
import logging
import os
import shutil
import signal
import subprocess
from dataclasses import dataclass
from pathlib import Path

from .bridge import BridgeClient
from .utils.error_codes import fail, ok
from .utils.port_resolver import DEFAULT_GAME_PORT, resolve_port

log = logging.getLogger(__name__)


@dataclass
class GameInstance:
    """A standalone game process for multiplayer testing."""

    instance_id: str
    role: str  # "host" or "client"
    game_port: int
    project_path: str
    scene: str
    args: dict
    bridge: BridgeClient
    process: subprocess.Popen | None = None
    active: bool = False
    connected: bool = False


class GameInstanceManager:
    """Owns all GameInstance objects and routes calls to the right one."""

    def __init__(self) -> None:
        self._instances: dict[str, GameInstance] = {}
        self._active_id: str | None = None
        self._counter = 0

    @property
    def active_id(self) -> str | None:
        return self._active_id

    def _next_id(self) -> str:
        self._counter += 1
        return f"game_{self._counter}"

    def _next_game_port(self) -> int:
        """Allocate a free game port, starting from DEFAULT_GAME_PORT + 10*n."""
        n = len(self._instances)
        preferred = DEFAULT_GAME_PORT + 10 * n
        return resolve_port(preferred, preferred)

    def list_instances(self) -> list[dict]:
        out = []
        for inst in self._instances.values():
            out.append(
                {
                    "instance_id": inst.instance_id,
                    "role": inst.role,
                    "connected": inst.bridge.connected,
                    "game_port": inst.game_port,
                    "active": inst.active,
                }
            )
        return out

    def get(self, instance_id: str | None = None) -> GameInstance | None:
        if instance_id is not None:
            return self._instances.get(instance_id)
        if self._active_id is None:
            return None
        return self._instances.get(self._active_id)

    def get_bridge(self, instance_id: str | None = None) -> BridgeClient | None:
        inst = self.get(instance_id)
        return inst.bridge if inst else None

    def _find_godot(self) -> str | None:
        return os.environ.get("GODOT_BIN") or shutil.which("godot")

    async def launch_instance(
        self,
        role: str,
        scene: str = "",
        args: dict | None = None,
        project_path: str | None = None,
    ) -> dict:
        """Launch a standalone game process.

        role: 'host' or 'client'
        scene: res:// path for the game to load (host: required, client: optional)
        args: {'connect_to': 'ip:port', 'reconnect': bool} for client
        project_path: filesystem path to the Godot project (from editor bridge)
        """
        if role not in ("host", "client"):
            return fail("INVALID_ARGUMENT", f"role must be 'host' or 'client', got {role!r}")
        if project_path is None:
            return fail("INVALID_ARGUMENT", "project_path required (no editor bridge connected)")
        if role == "host" and not scene:
            return fail("INVALID_ARGUMENT", "scene required for host role")

        godot = self._find_godot()
        if not godot:
            return fail("NOT_FOUND", "Godot executable not found (set GODOT_BIN or add to PATH)")

        path = Path(project_path)
        if not (path / "project.godot").exists():
            return fail("INVALID_PATH", f"Not a Godot project: {project_path}")

        game_port = self._next_game_port()
        inst_id = self._next_id()
        args = args or {}

        env = os.environ.copy()
        env["OGM_GAME_PORT"] = str(game_port)
        env["OGM_ROLE"] = role
        if role == "client":
            connect_to = args.get("connect_to", "")
            if not connect_to:
                return fail(
                    "INVALID_ARGUMENT",
                    "client role requires args.connect_to (e.g. '127.0.0.1:7070')",
                )
            env["OGM_CONNECT_TO"] = connect_to
            if args.get("reconnect"):
                env["OGM_RECONNECT"] = "true"

        # Build command: godot --path <project> [scene]
        cmd = [godot, "--path", str(path)]
        if scene:
            cmd.append(scene)

        try:
            proc = subprocess.Popen(
                cmd,
                env=env,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        except OSError as e:
            return fail("INTERNAL_ERROR", f"Failed to launch Godot: {e}")

        bridge = BridgeClient(host="127.0.0.1", port=game_port)
        inst = GameInstance(
            instance_id=inst_id,
            role=role,
            game_port=game_port,
            project_path=str(path),
            scene=scene,
            args=args,
            bridge=bridge,
            process=proc,
        )
        self._instances[inst_id] = inst
        self._mark_active(inst_id)

        # Connect in background — game needs time to start
        asyncio.create_task(self._connect_when_ready(inst))
        return ok(instance_id=inst_id, game_port=game_port)

    async def _connect_when_ready(self, inst: GameInstance, max_wait: float = 30.0) -> None:
        """Poll the game's WS port until the runtime autoload server is up."""
        deadline = asyncio.get_event_loop().time() + max_wait
        while asyncio.get_event_loop().time() < deadline:
            if inst.process and inst.process.poll() is not None:
                log.warning("Game process exited before WS came up (instance %s)", inst.instance_id)
                return
            if await inst.bridge.connect():
                inst.connected = True
                log.info("Game instance %s connected on port %d", inst.instance_id, inst.game_port)
                return
            await asyncio.sleep(0.5)

    def switch(self, instance_id: str) -> dict:
        inst = self._instances.get(instance_id)
        if inst is None:
            return fail("INSTANCE_NOT_FOUND", f"No game instance {instance_id!r}")
        self._mark_active(instance_id)
        return ok()

    def clear_active(self) -> None:
        """Clear the active game instance so runtime tools fall back to the editor."""
        for inst in self._instances.values():
            inst.active = False
        self._active_id = None

    def _mark_active(self, instance_id: str) -> None:
        for inst in self._instances.values():
            inst.active = inst.instance_id == instance_id
        self._active_id = instance_id

    async def terminate(self, instance_id: str) -> dict:
        inst = self._instances.get(instance_id)
        if inst is None:
            return fail("INSTANCE_NOT_FOUND", f"No game instance {instance_id!r}")
        await inst.bridge.disconnect()
        if inst.process and inst.process.poll() is None:
            try:
                inst.process.send_signal(signal.SIGTERM)
                try:
                    inst.process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    inst.process.kill()
            except (OSError, subprocess.SubprocessError):
                pass
        del self._instances[instance_id]
        if self._active_id == instance_id:
            self._active_id = next(iter(self._instances), None)
            if self._active_id:
                self._mark_active(self._active_id)
        return ok()

    async def sync_state(self, instance_ids: list[str] | None = None) -> dict:
        """Compare runtime state across game instances.

        Calls godot_runtime_state digest on each instance and compares
        the mcp_watch nodes. Returns per-node sync status.
        """
        if instance_ids is None:
            instance_ids = list(self._instances.keys())
        if len(instance_ids) < 2:
            return fail("INVALID_ARGUMENT", "sync_state requires at least 2 instances")

        # Query each instance's state in parallel
        async def _query(iid: str) -> tuple[str, dict]:
            inst = self._instances.get(iid)
            if inst is None or not inst.bridge.connected:
                return iid, {}
            resp = await inst.bridge.call_tool("godot_runtime_state", "digest", {})
            if resp.get("ok"):
                return iid, resp.get("nodes", {})
            return iid, {}

        results = await asyncio.gather(*[_query(iid) for iid in instance_ids])
        states = dict(results)

        # Compare nodes across instances
        # Collect all node paths
        all_paths: set[str] = set()
        for nodes in states.values():
            all_paths.update(nodes.keys())

        sync_results = []
        all_in_sync = True
        for path in all_paths:
            values = []
            for iid in instance_ids:
                nodes = states.get(iid, {})
                val = nodes.get(path)
                values.append({
                    "instance_id": iid,
                    "node_path": path,
                    "properties": val,
                    "in_sync": False,
                })
            # Compare: all non-None values must be equal
            non_none = [v["properties"] for v in values if v["properties"] is not None]
            in_sync = len(non_none) > 0 and all(v == non_none[0] for v in non_none)
            if not in_sync:
                all_in_sync = False
            for v in values:
                v["in_sync"] = in_sync
            sync_results.extend(values)

        return ok(all_in_sync=all_in_sync, sync=sync_results)

    async def shutdown_all(self) -> None:
        for inst_id in list(self._instances.keys()):
            await self.terminate(inst_id)
