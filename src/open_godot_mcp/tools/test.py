"""Test tools — godot_test (mixed, built-in test framework).

Docs: 02-Tools/Test.md
  list, run, results, create
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ._helpers import make_simple_tool


def register_test_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_test",
        "Built-in test framework. Actions: list,run(suite?,test_name?,exclude?),results(verbose?),create(path,test_name).",
    )
