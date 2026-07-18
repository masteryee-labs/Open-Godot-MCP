"""Resource tools — godot_resource (read-only, type-aware).

Docs: 02-Tools/Resource.md §godot_resource
  inspect, list, find, info  (all use res:// paths)
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ._helpers import make_simple_tool


def register_resource_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_resource",
        "Read-only resource inspection (auto-allow, type-aware). Actions: "
        "inspect(path) {type,properties:{}} (SpriteFrames shows animations, TileSet shows tiles), "
        "list(dir,type_filter?) {resources:[{path,type,name}]}, "
        "find(type,glob?) {resources:[...]}, "
        "info(path) {type,size,imported,path}. "
        "path/dir use res://. type_filter is a Godot resource class name string "
        "(e.g. 'SpriteFrames','TileSet','Material','Texture2D').",
    )
