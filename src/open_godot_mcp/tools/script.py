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
        "GDScript file ops. Actions: "
        "read(path,start_line?,end_line?) {content,total_lines} (1-based lines), "
        "create(path,extends,content) write, "
        "edit(path,edits:[{old,new,context?}]) write -> {ok,changed_lines:[{start,end}]}, "
        "write(path,content) write, "
        "validate(path) {ok,errors:[{line,column,message}]}, "
        "attach(node_path=/root/...,script_path=res://...) write, "
        "detach(node_path=/root/...) write. "
        "extends is a Godot class name (Node2D, Resource, ...). "
        "edit is diff-based: provide old->new snippets, not full file. "
        "AMBIGUOUS_MATCH if old appears multiple times (add context to disambiguate).",
    )
