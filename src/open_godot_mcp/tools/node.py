"""Node tools — godot_node_read / godot_node_edit.

Docs: 02-Tools/Scene-Node.md
  read: inspect, tree, find, children, properties  (all use /root/... paths)
  edit: create, delete, reparent, rename, duplicate, set_property, set_properties, set_groups
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ._helpers import make_simple_tool


def register_node_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_node_read",
        "Read editor scene tree nodes. Actions: inspect,tree,find,children,properties,get_signals,get_groups,find_in_group. node_path=/root/....",
    )
    make_simple_tool(
        mcp,
        ctx,
        "godot_node_edit",
        "Edit editor nodes (gated, Undo/Redo). Actions: create,create_batch,delete,reparent,rename,duplicate,set_property,set_properties,set_groups,add_to_group,remove_from_group,connect_signal,disconnect_signal.",
        is_write=True,
    )
