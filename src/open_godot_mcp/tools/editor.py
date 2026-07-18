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
        "Read-only editor state (auto-allow). Actions: "
        "state {godot_version,current_scene,is_playing,project_path}, "
        "selection {nodes:[{path,type,name}]}, "
        "open_scenes {scenes:[res://...]}, "
        "viewport(viewport='2d'|'3d') {size:{width,height},transform}, "
        "performance {fps,memory,draw_calls,object_count}.",
    )
    make_simple_tool(
        mcp,
        ctx,
        "godot_editor_edit",
        "Write to editor (gated, Undo/Redo). Actions: "
        "open_scene(path=res://...), save_scene(path?=res://...), save_all, "
        "set_selection(node_paths=[/root/...]), focus_node(node_path=/root/...), "
        "quit(save=bool).",
        is_write=True,
    )
