"""Server context shared by all tools.

Holds the InstanceManager, security flags, and provides a single ``call()``
helper that routes to the right bridge.
"""

from __future__ import annotations

import logging
from dataclasses import dataclass, field

from .bridge import BridgeClient
from .game_instance_manager import GameInstanceManager
from .instance_manager import InstanceManager
from .utils.error_codes import fail

log = logging.getLogger(__name__)


@dataclass
class ServerContext:
    """Shared mutable state for the MCP server."""

    instance_manager: InstanceManager = field(default_factory=InstanceManager)
    game_instance_manager: GameInstanceManager = field(default_factory=GameInstanceManager)
    read_only: bool = False
    allow_eval: bool = True
    allowed_paths: list[str] | None = None
    projects: list[str] | None = None
    server_version: str = "0.1.0"
    # Lazy-adopt state (set by server.run_stdio)
    _pending_adopts: list[str] = field(default_factory=list)
    _adopt_host: str = "127.0.0.1"
    _adopt_port: int | None = None
    _adopted: bool = False

    # ---- routing ----

    def bridge(self, instance_id: str | None = None) -> BridgeClient | None:
        # Game instances (standalone processes) use game_instance_manager.
        if instance_id and instance_id.startswith("game_"):
            return self.game_instance_manager.get_bridge(instance_id)
        return self.instance_manager.get_bridge(instance_id)

    async def call(
        self,
        tool: str,
        action: str,
        params: dict | None = None,
        *,
        instance_id: str | None = None,
        timeout: float = 30.0,
    ) -> dict:
        """Route a tool call to the right bridge. Returns the raw bridge response."""
        # Lazy-adopt: connect to the first reachable bridge on first call.
        # Retry on failure so a Godot editor that starts after the MCP
        # server eventually gets adopted (bridge may not be listening yet
        # when the MCP server first starts).
        if not self._adopted or self.instance_manager.get_bridge() is None:
            self._adopted = True
            if self._pending_adopts:
                for p in self._pending_adopts:
                    log.info("Lazy-adopting project %s", p)
                    try:
                        await self.instance_manager.adopt(p, host=self._adopt_host)
                    except Exception as exc:
                        log.warning("adopt failed for %s: %s", p, exc)
            elif self._adopt_port is not None:
                log.info("Lazy-adopting bridge at %s:%d (no --projects)", self._adopt_host, self._adopt_port)
                try:
                    await self.instance_manager.adopt_by_port(
                        self._adopt_port, host=self._adopt_host
                    )
                except Exception as exc:
                    log.warning("adopt-by-port failed: %s", exc)
        bridge = self.bridge(instance_id)
        if bridge is None:
            return fail("BRIDGE_NOT_CONNECTED", "No Godot instance connected")
        if not bridge.connected:
            return fail("BRIDGE_NOT_CONNECTED", "Bridge not connected")
        return await bridge.call_tool(tool, action, params, timeout=timeout)

    # ---- security ----

    def check_writable(self) -> dict | None:
        """Return a fail dict if read-only mode is on, else None."""
        if self.read_only:
            return fail("PERMISSION_DENIED", "Server is in read-only mode")
        return None

    def check_eval(self) -> dict | None:
        """Return a fail dict if eval is disabled, else None."""
        if not self.allow_eval:
            return fail("PERMISSION_DENIED", "godot_exec eval is disabled (--no-eval)")
        return None

    def check_path(self, path: str) -> dict | None:
        """If allowed_paths is set, verify *path* is under one of them."""
        if self.allowed_paths is None:
            return None
        from pathlib import Path

        p = Path(path).resolve()
        for allowed in self.allowed_paths:
            try:
                p.relative_to(Path(allowed).resolve())
                return None
            except ValueError:
                continue
        return fail("PERMISSION_DENIED", f"Path {path} is outside allowed paths")
