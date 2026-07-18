"""Exec tools — godot_exec (write, gated, GDScript injection).

Docs: 02-Tools/Runtime-State.md §godot_exec
  eval, call
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ..utils.error_codes import fail
from ._helpers import make_tool, route_tool


def register_exec_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    @make_tool(
        mcp,
        ctx,
        "godot_exec",
        "Execute GDScript in the running game (gated, security-sensitive). Actions: "
        "eval(code,await?) -> {result,error?} (result is last expression value; "
        "await=true if code contains 'await' keyword; "
        "eval context: self=get_tree().root, autoloads accessible by name, "
        "get_tree()/Engine globals available). "
        "call(node_path,method,args?) -> {result} (call method on a node; "
        "args is JSON array with Godot-type encoding). "
        "assert(condition,description?,await?) -> {condition,passed,time_ms} "
        "(evaluate GDScript bool expression in game context; returns ASSERT_FAILED if false). "
        "Use for test setup: grant weapon, skip to wave, spawn bot. "
        "Use assert for playtest verification: assert 'Player.health > 0'. "
        "DISABLED if server started with --no-eval (PERMISSION_DENIED). "
        "C# Godot: eval not supported (C# is compiled); use call instead. "
        "params is a dict: e.g. {\"code\": \"Player.health = 100\", \"await\": false}.",
        is_write=True,
    )
    async def godot_exec(action: str, params: dict | None = None) -> dict:
        # Extra security gate for eval
        if action == "eval" and not ctx.allow_eval:
            return fail("PERMISSION_DENIED", "godot_exec eval is disabled (--no-eval)")
        return await route_tool(ctx, "godot_exec", action, params, is_write=True)
