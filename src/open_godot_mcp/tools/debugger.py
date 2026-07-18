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
        "DAP debugger integration. Actions: "
        "set_breakpoint(script_path=res://...,line) write, "
        "remove_breakpoint(script_path,line) write, "
        "resume/continue write, step_over/step_into/step_out write, "
        "stack_trace(read) {frames:[{frame,file,line,function,source}],paused} "
        "(frame=0=innermost, used for variables frame_id), "
        "variables(frame_id?) read {variables:{},frame_id} (Godot-type encoded), "
        "evaluate(expression,frame_id?) read {result,expression} "
        "(evaluate expression in paused game context), "
        "list_breakpoints(read) {breakpoints:[]}, "
        "sessions(read) {sessions:[{active,paused}]} "
        "(auto-reports when game pauses at breakpoint/assert).",
    )
