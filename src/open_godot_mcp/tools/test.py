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
        "Built-in test framework (McpTestSuite, auto-discovered from res://tests/). Actions: "
        "list {suites:[{name,file,test_count}],tests:[{suite,name}]} "
        "(name includes 'test_' prefix, e.g. 'test_player_takes_damage'), "
        "run(suite?,test_name?,exclude?) write -> {results:{passed,failed,skipped,details:[...]}} "
        "(test_name/exclude include 'test_' prefix; omit both = run all), "
        "results(verbose?) read (verbose=true includes passed; default only failed/skipped), "
        "create(path,test_name) write "
        "(path=res://tests/...gd; test_name WITHOUT 'test_' prefix, e.g. 'player_takes_damage'; "
        "tool generates func test_<test_name> skeleton). "
        "NOTE: create's test_name has NO test_ prefix; run/list/exclude use WITH test_ prefix.",
    )
