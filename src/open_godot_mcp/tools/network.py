"""Network tools — godot_network (mixed, multiplayer testing).

Docs: 02-Tools/Network.md
  launch_instance, list_instances, switch, terminate, simulate_peer,
  network_condition, sync_state, rpc_call

Instance management (launch/list/switch/terminate/sync_state) is handled
Python-side via GameInstanceManager — it spawns standalone Godot processes.
Runtime actions (simulate_peer/network_condition/rpc_call) route through
the game instance's WebSocket bridge to the runtime autoload.
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ..utils.error_codes import fail, ok
from ._helpers import guard_write, make_tool


def _get_project_path(ctx: ServerContext) -> str | None:
    """Get the project path from the active editor bridge."""
    bridge = ctx.bridge()
    if bridge and bridge.info.project_path:
        return bridge.info.project_path
    return None


def register_network_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    @make_tool(
        mcp,
        ctx,
        "godot_network",
        "Multiplayer game testing. Actions: launch_instance(role,scene?,args?),list_instances,switch,terminate,simulate_peer,network_condition,sync_state,rpc_call.",
    )
    async def godot_network(action: str, params: dict | None = None) -> dict:
        params = params or {}
        mgr = ctx.game_instance_manager

        if action == "launch_instance":
            blocked = guard_write(ctx)
            if blocked:
                return blocked
            role = params.get("role", "")
            scene = params.get("scene", "")
            args = params.get("args", {})
            project_path = _get_project_path(ctx)
            if not project_path:
                return fail(
                    "BRIDGE_NOT_CONNECTED",
                    "No editor bridge connected — need project path",
                )
            return await mgr.launch_instance(role, scene, args, project_path=project_path)

        elif action == "list_instances":
            return ok(instances=mgr.list_instances())

        elif action == "switch":
            blocked = guard_write(ctx)
            if blocked:
                return blocked
            iid = params.get("instance_id")
            if not iid:
                return fail("INVALID_ARGUMENT", "instance_id required (use 'editor' to switch back to editor)")
            if iid in ("editor", ""):
                mgr.clear_active()
                return ok()
            return mgr.switch(iid)

        elif action == "terminate":
            blocked = guard_write(ctx)
            if blocked:
                return blocked
            iid = params.get("instance_id")
            if not iid:
                return fail("INVALID_ARGUMENT", "instance_id required")
            return await mgr.terminate(iid)

        elif action == "sync_state":
            instances = params.get("instances")
            return await mgr.sync_state(instances)

        elif action in ("simulate_peer", "network_condition", "rpc_call"):
            blocked = guard_write(ctx)
            if blocked:
                return blocked
            iid = params.get("instance_id")
            # If instance_id is given, route to that standalone game instance.
            # Otherwise, fall back to the editor bridge (PIE game via debugger).
            if iid:
                bridge = mgr.get_bridge(iid)
                if bridge is None:
                    return fail("INSTANCE_NOT_FOUND", f"No game instance {iid!r}")
                if not bridge.connected:
                    return fail("BRIDGE_NOT_CONNECTED", f"Game instance {iid!r} not connected")
                fwd_params = {k: v for k, v in params.items() if k != "instance_id"}
                return await bridge.call_tool("godot_network", action, fwd_params)
            # No instance_id — route through the editor bridge (PIE)
            editor_bridge = ctx.bridge()
            if editor_bridge is None or not editor_bridge.connected:
                return fail("BRIDGE_NOT_CONNECTED", "No game instance or editor bridge connected")
            fwd_params = {k: v for k, v in params.items() if k != "instance_id"}
            return await editor_bridge.call_tool("godot_network", action, fwd_params)

        else:
            return fail("INVALID_ARGUMENT", f"Unknown action: {action}")
