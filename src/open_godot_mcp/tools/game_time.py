"""Game time tools — godot_game_time (write, deterministic clock control).

Docs: 02-Tools/Game-Control.md §godot_game_time
  freeze, unfreeze, step, step_until
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ._helpers import make_simple_tool


def register_game_time_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_game_time",
        "Deterministic clock control (gated). Core innovation for playtesting. Actions: "
        "freeze -> {ok,frame} (Engine.time_scale=0, game stops at current frame), "
        "unfreeze(time_scale?=1.0) -> {ok,frame}, "
        "step(ms,inputs?) -> {ok,frame,elapsed} (elapsed in seconds; "
        "inputs=[{type,...,at_ms}] where at_ms is 0..ms within the slice; "
        "types: action,key,mouse_button,mouse_motion,joypad,text — same params as godot_input), "
        "step_until(condition,timeout_ms?=10000,interval_ms?=16) -> {ok,frame,elapsed,condition_met}. "
        "condition is a GDScript expression evaluated in the game process "
        "(same context as godot_exec eval: SceneTree root, autoloads accessible). "
        "Example: \"get_tree().get_nodes_in_group('boss').size() >= 1\".",
        is_write=True,
    )
