"""Debugger tools — godot_debugger (mixed, DAP integration).

Docs: 02-Tools/Diagnostics.md §godot_debugger
  set_breakpoint, remove_breakpoint, resume, step_over, step_into,
  stack_trace, variables, sessions
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ._helpers import make_simple_tool


def register_debugger_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_debugger",
        "DAP debugger. Actions: set_breakpoint,remove_breakpoint,resume,continue,step_over,step_into,step_out,stack_trace,variables,evaluate,list_breakpoints,sessions.",
    )
