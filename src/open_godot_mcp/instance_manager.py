"""Instance Manager — manage multiple Godot editor instances.

Per Docs/01-Architecture/Multi-Instance.md:
  Each instance gets a port block: bridge 6970+10n, dap 6006+10n, lsp 6005+10n, game 7070+10n.
  Tools accept an optional ``instance_id``; absent -> active instance.

The active instance is the most recently switched-to one. ``godot_instance``
tool calls route here for launch/list/switch/terminate/adopt.
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
from .utils.port_resolver import allocate_instance_ports

log = logging.getLogger(__name__)


@dataclass
class EditorInstance:
    """A single Godot editor instance managed by the MCP server."""

    instance_id: str
    project_path: str
    ports: dict[str, int]
    bridge: BridgeClient
    process: subprocess.Popen | None = None
    active: bool = False
    adopted: bool = False  # True if connected to an externally-launched editor

    @property
    def bridge_port(self) -> int:
        return self.ports["bridge"]


class InstanceManager:
    """Owns all EditorInstance objects and routes tool calls to the right one."""

    def __init__(self) -> None:
        self._instances: dict[str, EditorInstance] = {}
        self._active_id: str | None = None
        self._counter = 0

    # ---- lookup ----

    @property
    def active_id(self) -> str | None:
        return self._active_id

    def list_instances(self) -> list[dict]:
        out = []
        for inst in self._instances.values():
            out.append(
                {
                    "instance_id": inst.instance_id,
                    "project_path": inst.project_path,
                    "ports": inst.ports,
                    "active": inst.active,
                    "connected": inst.bridge.connected,
                    "adopted": inst.adopted,
                }
            )
        return out

    def get(self, instance_id: str | None = None) -> EditorInstance | None:
        """Get instance by id, or the active one if id is None."""
        if instance_id is not None:
            return self._instances.get(instance_id)
        if self._active_id is None:
            return None
        return self._instances.get(self._active_id)

    def get_bridge(self, instance_id: str | None = None) -> BridgeClient | None:
        inst = self.get(instance_id)
        return inst.bridge if inst else None

    def require_bridge(self, instance_id: str | None = None) -> BridgeClient:
        """Get bridge or raise ValueError (caller converts to fail dict)."""
        inst = self.get(instance_id)
        if inst is None:
            raise ValueError(f"No instance {instance_id!r} (active={self._active_id!r})")
        if not inst.bridge.connected:
            raise ValueError(f"Instance {inst.instance_id} bridge not connected")
        return inst.bridge

    # ---- lifecycle ----

    def _next_id(self) -> str:
        self._counter += 1
        return f"inst_{self._counter}"

    async def launch_editor(
        self,
        project_path: str,
        *,
        godot_bin: str | None = None,
        host: str = "127.0.0.1",
    ) -> dict:
        """Launch a new Godot editor instance and connect to its bridge.

        Per Instance.md: ``project_path`` is a filesystem absolute path.
        Returns ``{instance_id, ports}``.
        """
        path = Path(project_path)
        if not (path / "project.godot").exists():
            return fail("INVALID_PATH", f"Not a Godot project (no project.godot): {project_path}")

        godot = godot_bin or os.environ.get("GODOT_BIN") or shutil.which("godot")
        if not godot:
            return fail("NOT_FOUND", "Godot executable not found (set GODOT_BIN or add to PATH)")

        idx = len(self._instances)
        ports = allocate_instance_ports(idx, host=host)
        inst_id = self._next_id()

        # Pass port via env so the plugin reads OPEN_GODOT_MCP_PORT (Connection-Stability.md §對策 1)
        env = os.environ.copy()
        env["OPEN_GODOT_MCP_PORT"] = str(ports["bridge"])
        env["OPEN_GODOT_MCP_DAP_PORT"] = str(ports["dap"])
        env["OPEN_GODOT_MCP_LSP_PORT"] = str(ports["lsp"])

        try:
            proc = subprocess.Popen(
                [godot, "--editor", "--path", str(path)],
                env=env,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        except OSError as e:
            return fail("INTERNAL_ERROR", f"Failed to launch Godot: {e}")

        bridge = BridgeClient(host=host, port=ports["bridge"])
        inst = EditorInstance(
            instance_id=inst_id,
            project_path=str(path),
            ports=ports,
            bridge=bridge,
            process=proc,
        )
        self._instances[inst_id] = inst
        self._active_id = inst_id
        self._mark_active(inst_id)

        # Try to connect in the background; the editor needs time to start.
        asyncio.create_task(self._connect_when_ready(inst))
        return ok(instance_id=inst_id, ports=ports)

    async def _connect_when_ready(self, inst: EditorInstance, max_wait: float = 30.0) -> None:
        """Poll the bridge port until the editor's WebSocket server is up."""
        deadline = asyncio.get_event_loop().time() + max_wait
        while asyncio.get_event_loop().time() < deadline:
            if inst.process and inst.process.poll() is not None:
                log.warning("Godot process exited before bridge came up (instance %s)", inst.instance_id)
                return
            if await inst.bridge.connect():
                return
            await asyncio.sleep(0.5)

    async def adopt(self, project_path: str, *, host: str = "127.0.0.1") -> dict:
        """Connect to an already-running Godot editor (Instance.md §adopt).

        The editor must have the addon enabled and its bridge reachable.
        We read the bridge port from the project's EditorSettings or env.
        """
        path = Path(project_path)
        if not (path / "project.godot").exists():
            return fail("INVALID_PATH", f"Not a Godot project: {project_path}")

        # Try default port first, then scan a small range
        from .utils.port_resolver import DEFAULT_BRIDGE_PORT, is_port_free

        candidates = [DEFAULT_BRIDGE_PORT]
        candidates += [DEFAULT_BRIDGE_PORT + 10 * i for i in range(1, 6)]
        port = None
        for p in candidates:
            if not is_port_free(p, host):
                port = p
                break
        if port is None:
            return fail("BRIDGE_NOT_CONNECTED", "No reachable bridge found for project")

        idx = len(self._instances)
        ports = {"bridge": port, "dap": 6006 + 10 * idx, "lsp": 6005 + 10 * idx, "game": 7070 + 10 * idx}
        inst_id = self._next_id()
        bridge = BridgeClient(host=host, port=port)
        if not await bridge.connect():
            return fail("BRIDGE_NOT_CONNECTED", f"Could not connect to bridge at {host}:{port}")
        inst = EditorInstance(
            instance_id=inst_id,
            project_path=str(path),
            ports=ports,
            bridge=bridge,
            adopted=True,
        )
        self._instances[inst_id] = inst
        self._mark_active(inst_id)
        return ok(instance_id=inst_id, ports=ports)

    async def adopt_by_port(self, port: int, *, host: str = "127.0.0.1") -> dict:
        """Connect to a running Godot editor's bridge by port, without a project path.

        Used when the MCP server is started with --bridge-port but no --projects.
        """
        idx = len(self._instances)
        ports = {"bridge": port, "dap": 6006 + 10 * idx, "lsp": 6005 + 10 * idx, "game": 7070 + 10 * idx}
        inst_id = self._next_id()
        bridge = BridgeClient(host=host, port=port)
        if not await bridge.connect():
            return fail("BRIDGE_NOT_CONNECTED", f"Could not connect to bridge at {host}:{port}")
        inst = EditorInstance(
            instance_id=inst_id,
            project_path="(unknown)",
            ports=ports,
            bridge=bridge,
            adopted=True,
        )
        self._instances[inst_id] = inst
        self._mark_active(inst_id)
        return ok(instance_id=inst_id, ports=ports)

    def switch(self, instance_id: str) -> dict:
        inst = self._instances.get(instance_id)
        if inst is None:
            return fail("INSTANCE_NOT_FOUND", f"No instance {instance_id!r}")
        self._mark_active(instance_id)
        return ok()

    def _mark_active(self, instance_id: str) -> None:
        for inst in self._instances.values():
            inst.active = inst.instance_id == instance_id
        self._active_id = instance_id

    async def terminate(self, instance_id: str) -> dict:
        inst = self._instances.get(instance_id)
        if inst is None:
            return fail("INSTANCE_NOT_FOUND", f"No instance {instance_id!r}")
        await inst.bridge.disconnect()
        if inst.process and inst.process.poll() is None and not inst.adopted:
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

    async def shutdown_all(self) -> None:
        for inst_id in list(self._instances.keys()):
            await self.terminate(inst_id)
