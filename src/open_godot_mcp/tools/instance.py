"""Instance tools — godot_instance (mixed, editor process management).

Docs: 02-Tools/Instance.md
  launch_editor, list, switch, terminate, adopt
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ..utils.error_codes import fail, ok
from ._helpers import make_tool


def register_instance_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    @make_tool(
        mcp,
        ctx,
        "godot_instance",
        "Manage Godot EDITOR instances (not game instances — use godot_network for those). "
        "Actions: "
        "launch_editor(project_path) write -> {instance_id,ports:{bridge,dap,lsp}} "
        "(project_path is absolute filesystem path with project.godot), "
        "list {instances:[{instance_id,project_path,ports,active}]}, "
        "switch(instance_id) write, terminate(instance_id) write, "
        "adopt(project_path) write -> {ok,instance_id,ports} "
        "(connect to an already-running Godot editor with the addon enabled). "
        "Each instance gets port block: bridge=6970+10n, dap=6006+10n, lsp=6005+10n. "
        "params is a dict: e.g. {\"project_path\": \"C:/Users/me/my_game\"}.",
        is_write=True,
    )
    async def godot_instance(action: str, params: dict | None = None) -> dict:
        mgr = ctx.instance_manager
        params = params or {}
        if action == "launch_editor":
            project_path = params.get("project_path")
            if not project_path:
                return fail("INVALID_ARGUMENT", "project_path required")
            return await mgr.launch_editor(project_path)
        elif action == "list":
            return ok(instances=mgr.list_instances())
        elif action == "switch":
            iid = params.get("instance_id")
            if not iid:
                return fail("INVALID_ARGUMENT", "instance_id required")
            return mgr.switch(iid)
        elif action == "terminate":
            iid = params.get("instance_id")
            if not iid:
                return fail("INVALID_ARGUMENT", "instance_id required")
            return await mgr.terminate(iid)
        elif action == "adopt":
            project_path = params.get("project_path")
            if not project_path:
                return fail("INVALID_ARGUMENT", "project_path required")
            return await mgr.adopt(project_path)
        else:
            return fail("INVALID_ARGUMENT", f"Unknown action: {action}")
