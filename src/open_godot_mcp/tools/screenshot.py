"""Screenshot tools — godot_screenshot (read-only, saves to disk).

Docs: 02-Tools/Screenshot.md
  game, editor, region, burst
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ._helpers import make_simple_tool


def register_screenshot_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_screenshot",
        "Screenshots saved to disk (auto-allow). Actions: game(max_width?,format?,quality?),editor(viewport?,max_width?),region(rect,max_width?,source?),burst(count?,duration_ms?,interval_ms?).",
    )
