"""Script tools — godot_script (mixed).

Docs: 02-Tools/Script.md
  read: path, start_line?, end_line?  (1-based)
  create(write): path, extends, content
  edit(write): path, edits:[{old,new,context?}]  (diff-based, AMBIGUOUS_MATCH on multi)
  write(write): path, content
  validate(read): path  (headless GDScript syntax check)
  attach(write): node_path(/root/...), script_path(res://...)
  detach(write): node_path
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ._helpers import make_simple_tool


def register_script_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_script",
        "GDScript file ops. Actions: read,create,edit(diff-based),write,validate,attach,detach. path=res://.",
    )
