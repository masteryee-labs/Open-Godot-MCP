"""Animation tools — godot_animation (mixed, AnimationPlayer ops).

Docs: 02-Tools/Resource.md §godot_animation
  list, get, create, add_track, delete, play, stop, preset
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ._helpers import make_simple_tool


def register_animation_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_animation",
        "AnimationPlayer ops. Actions: list,get,create,add_track,delete,play,stop,preset. player_path=/root/.../AnimationPlayer.",
    )
