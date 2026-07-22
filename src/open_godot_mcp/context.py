"""Server context shared by all tools.

Holds the InstanceManager, security flags, and provides a single ``call()``
helper that routes to the right bridge.
"""

from __future__ import annotations

import logging
from dataclasses import dataclass, field

from . import __version__
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
    server_version: str = __version__
    # Lazy-adopt state (set by server.run_stdio)
    _pending_adopts: list[str] = field(default_factory=list)
    _adopt_host: str = "127.0.0.1"
    _adopt_port: int | None = None
    _adopted: bool = False
    # Agnes/NVIDIA API: tools are dynamically registered based on this config.
    # _mcp holds the FastMCP instance so we can add/remove tools on hot-reload.
    # _registered_agnes_tools tracks what's currently registered so we can diff.
    _mcp: object = None
    _registered_agnes_tools: set = field(default_factory=set)

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
            # Register the agnes_config_changed event handler on the new bridge
            # so dock hot-reload triggers tool re-sync. Idempotent: on_event
            # appends, but we only register once per bridge object.
            bridge = self.instance_manager.get_bridge()
            if bridge is not None and not bridge._agnes_handler_registered:
                bridge.on_event("agnes_config_changed", self.on_agnes_config_event)
                bridge._agnes_handler_registered = True
        bridge = self.bridge(instance_id)
        if bridge is None:
            return fail("BRIDGE_NOT_CONNECTED", "No Godot instance connected")
        # Note: do not early-return on `not bridge.connected` — call_tool
        # performs an on-demand connect so the bridge recovers when Godot
        # comes back without requiring an MCP server restart.
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

    # ---- Agnes/NVIDIA dynamic tool registration ----

    def on_agnes_config_event(self, params: dict | None = None) -> None:
        """Bridge event handler: config file changed on disk → re-sync tools.

        If *params* contains ``config_path``, use that path instead of the
        default home-dir path. This lets the dock switch to project-level
        config.
        """
        path = None
        if isinstance(params, dict):
            cp = params.get("config_path")
            if isinstance(cp, str) and cp:
                path = cp
        if path:
            log.info("agnes_config_changed event received (path=%s) — re-syncing tools", path)
        else:
            log.info("agnes_config_changed event received — re-syncing tools")
        self.sync_agnes_tools(path=path)

    def sync_agnes_tools(self, path: str | None = None) -> None:
        """Register/unregister agnes_*/nvidia_* tools to match config on disk.

        Called at server build time and on hot-reload events from the dock.
        Reads the config file fresh each call. No-op if _mcp is not set.

        If *path* is given, read from that path instead of the default.
        """
        if self._mcp is None:
            return
        from pathlib import Path

        from .agnes_config import all_enabled_tools, load_config

        cfg = load_config(path=Path(path)) if path else load_config()
        desired = set(all_enabled_tools(cfg))
        current = set(self._registered_agnes_tools)
        # Remove tools that are no longer enabled.
        for name in current - desired:
            try:
                # FastMCP 3.x: remove_tool moved to local_provider (top-level
                # mcp.remove_tool is deprecated). Try new API first, fall back.
                remover = getattr(self._mcp, "local_provider", self._mcp)
                remover.remove_tool(name)  # type: ignore[attr-defined]
            except Exception as e:  # noqa: BLE001
                log.warning("remove_tool %s failed: %s", name, e)
        # Add tools that are newly enabled.
        for name in desired - current:
            try:
                _register_single_agnes_tool(self._mcp, self, name)
            except Exception as e:  # noqa: BLE001
                log.warning("register %s failed: %s", name, e)
        self._registered_agnes_tools = desired


def _register_single_agnes_tool(mcp, ctx, name: str) -> None:
    """Register one agnes_*/nvidia_* tool by name. Imports lazily to avoid cycles."""
    from .tools.agnes import register_agnes_tools
    from .tools.nvidia import register_nvidia_tools

    if name.startswith("agnes_"):
        register_agnes_tools(mcp, ctx, only={name})
    elif name.startswith("nvidia_"):
        register_nvidia_tools(mcp, ctx, only={name})
    else:
        log.warning("unknown agnes/nvidia tool name: %s", name)
