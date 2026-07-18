"""Scene tools — godot_scene (mixed read/write).

Docs: 02-Tools/Scene-Node.md §godot_scene
  create(write): path(res://.tscn), root_type, root_name
  read: path, include_properties?
  save(write): path?  save_as(write): path
  hierarchy(read): path, depth?
  instantiate(write): child_scene_path, parent_path(/root/...), name
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ._helpers import make_simple_tool


def register_scene_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_scene",
        "Scene file ops (.tscn). Actions: "
        "create(path,root_type,root_name) write, "
        "read(path,include_properties?) {root,nodes,signals}, "
        "save(path?) write, save_as(path) write, "
        "hierarchy(path,depth?) {tree}, "
        "instantiate(child_scene_path,parent_path,name) write. "
        "path=res://..., parent_path=/root/.... "
        "root_type is a Godot class name like 'Node2D'.",
    )
