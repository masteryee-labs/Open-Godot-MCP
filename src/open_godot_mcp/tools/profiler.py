"""Profiler tools — godot_profiler (read-only).

Docs: 02-Tools/Diagnostics.md §godot_profiler
  snapshot, series, spikes
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ._helpers import make_simple_tool


def register_profiler_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_profiler",
        "Performance profiling (auto-allow, game must be running). Actions: "
        "snapshot {fps,process_time,physics_time,memory,draw_calls,object_count} "
        "(process_time/physics_time in ms/frame; memory in bytes), "
        "series(duration_ms?=1000,metrics?) {frames:[{frame,fps?,...}]} "
        "(metrics subset of [fps,process_time,physics_time,memory,draw_calls,object_count]), "
        "spikes(threshold_ms?=33) {spikes:[{frame,time_ms,duration_ms}]} "
        "(frames slower than threshold; 33ms = below 30fps). "
        "Lighter than godot_editor_read performance: this needs game running and "
        "includes process_time/physics_time.",
    )
