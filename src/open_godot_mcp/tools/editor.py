"""Editor tools — godot_editor_read / godot_editor_edit.

Docs: 02-Tools/Editor.md
  read: state, selection, open_scenes, viewport, performance
  edit: open_scene, save_scene, save_all, set_selection, focus_node, quit
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ._helpers import make_simple_tool


def register_editor_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_editor_read",
        "Read-only editor state. Actions: state,selection,open_scenes,viewport,performance.",
    )
    make_simple_tool(
        mcp,
        ctx,
        "godot_editor_edit",
        "Write to editor (gated, Undo/Redo). Actions: open_scene,save_scene,save_all,set_selection,focus_node,quit.",
        is_write=True,
    )
