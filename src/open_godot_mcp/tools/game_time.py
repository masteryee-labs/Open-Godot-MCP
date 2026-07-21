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
        "Deterministic clock control (gated). Actions: freeze,unfreeze,step(ms,inputs?),step_until(condition,timeout_ms?,interval_ms?).",
        is_write=True,
    )
