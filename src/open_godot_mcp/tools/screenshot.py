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
        "Screenshots saved to disk (auto-allow, returns path not base64). Actions: "
        "game(max_width?,format?='png',quality?=90) {path,size_bytes,dimensions:{width,height}}, "
        "editor(viewport?='2d'|'3d',max_width?) {path,...}, "
        "region(rect={x,y,width,height},max_width?,source?='game'|'editor') "
        "{path,...} (rect in actual window pixels, origin top-left), "
        "burst(count?=10,duration_ms?=1000,interval_ms?,max_width?,format?,quality?) "
        "{paths:[...],dimensions,count,duration_ms} (sequential frames for animation). "
        "dimensions = ACTUAL window pixels, not design resolution. "
        "Save tokens: format=jpeg quality=70 max_width=1280. "
        "In frozen mode, burst auto-steps game time per frame.",
    )
