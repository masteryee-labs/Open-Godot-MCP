"""Game control tools — godot_game (mixed).

Docs: 02-Tools/Game-Control.md §godot_game
  play(write): scene?, frozen?  -> {ok, runtime_ready}
  stop, pause, resume (write)
  status(read): {is_playing, runtime_connected, fps, viewport_size?}
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ._helpers import make_simple_tool


def register_game_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_game",
        "Game lifecycle. Actions: "
        "play(scene?,frozen?) write -> {ok,runtime_ready} "
        "(scene: omit=current editor scene, 'main'=project main, or res://...; "
        "frozen=true starts with Engine.time_scale=0 for deterministic playtesting), "
        "stop write, pause write (get_tree().paused=true), resume write, "
        "status(read) {is_playing,runtime_connected,fps,viewport_size?}. "
        "pause != freeze: pause uses Godot pause system, freeze sets time_scale=0. "
        "resume does NOT unfreeze; use godot_game_time unfreeze for that.",
    )
