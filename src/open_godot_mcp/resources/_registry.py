"""Register MCP Resources (Docs/02-Tools/Index.md §MCP Resources).

Resources are read-only URIs the AI can @-mention. We register them as
FastMCP resource functions that query the bridge live.
"""

from __future__ import annotations

import logging

from fastmcp import FastMCP

from ..context import ServerContext

log = logging.getLogger(__name__)


def register_resources(mcp: FastMCP, ctx: ServerContext) -> None:
    @mcp.resource("godot://editor/state")
    async def editor_state() -> str:
        """Current editor state as JSON text."""
        resp = await ctx.call("godot_editor_read", "state", {})
        return _to_text(resp)

    @mcp.resource("godot://editor/scene-tree")
    async def scene_tree() -> str:
        """Current scene tree (depth=2 summary) as JSON text."""
        resp = await ctx.call("godot_node_read", "tree", {"depth": 2})
        return _to_text(resp)

    @mcp.resource("godot://editor/logs")
    async def editor_logs() -> str:
        """Recent editor logs (last 50 lines) as JSON text."""
        resp = await ctx.call("godot_log", "get", {"count": 50})
        return _to_text(resp)

    @mcp.resource("godot://editor/screenshot")
    async def screenshot() -> str:
        """Latest game screenshot path (saved to disk)."""
        resp = await ctx.call("godot_screenshot", "game", {"format": "jpeg", "quality": 70, "max_width": 1280})
        return _to_text(resp)

    @mcp.resource("godot://instances")
    async def instances() -> str:
        """Running editor instances as JSON text."""
        return _to_text({"instances": ctx.instance_manager.list_instances()})

    @mcp.resource("godot://project/info")
    async def project_info() -> str:
        """Project info as JSON text."""
        resp = await ctx.call("godot_project", "info", {})
        return _to_text(resp)


def _to_text(obj) -> str:
    import json

    return json.dumps(obj, default=str, ensure_ascii=False)
