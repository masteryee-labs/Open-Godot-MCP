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
        "Observe running game state (auto-allow). Actions: digest(groups?),inspect(node_path,properties?),watch(node_path,property,duration_ms?),signals(node_path?,since_ms?).",
    )
