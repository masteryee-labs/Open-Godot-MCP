"""Resource tools — godot_resource (read-only, type-aware).

Docs: 02-Tools/Resource.md §godot_resource
  inspect, list, find, info  (all use res:// paths)
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ._helpers import make_simple_tool


def register_resource_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_resource",
        "Read-only resource inspection. Actions: inspect,list,find,info. path=res://.",
    )
