"""Health tools — godot_health (read-only).

Docs: 02-Tools/Utility.md §godot_health
  check, diagnostics
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ._helpers import make_simple_tool


def register_health_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_health",
        "Connection health. Actions: check,diagnostics. Call first to verify connectivity.",
    )
