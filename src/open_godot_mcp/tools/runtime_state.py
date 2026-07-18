"""Runtime state tools — godot_runtime_state (read-only).

Docs: 02-Tools/Runtime-State.md §godot_runtime_state
  digest, inspect, watch, signals
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ._helpers import make_simple_tool


def register_runtime_state_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_runtime_state",
        "Observe running game state (auto-allow, cheap JSON observation). Actions: "
        "digest(groups?=['mcp_watch'],include_properties?) {nodes:{},frame} "
        "(nodes keyed by /root/... path; value from _mcp_state() or default props; "
        "frame is current game frame number), "
        "inspect(node_path,properties?) {properties:{}} (LIVE game state, not editor), "
        "watch(node_path,property,duration_ms?=1000) {samples:[{t_ms,value}]} "
        "(samples per-frame; t_ms relative to watch start), "
        "signals(node_path?,since_ms?) {signals:[{time_ms,node_path,signal_name,args}]} "
        "(time_ms from game start; since_ms relative to now, default 1000). "
        "Requires game running (RUNTIME_NOT_CONNECTED if not). "
        "Cheap observation: use digest instead of screenshots for logic bugs.",
    )
