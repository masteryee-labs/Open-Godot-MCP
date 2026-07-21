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
        "Execute GDScript in running game (gated). Actions: eval(code,await?),call(node_path,method,args?),assert(condition,description?,await?). Disabled if --no-eval.",
        is_write=True,
    )
    async def godot_exec(action: str, params: dict | None = None) -> dict:
        # Extra security gate for eval
        if action == "eval" and not ctx.allow_eval:
            return fail("PERMISSION_DENIED", "godot_exec eval is disabled (--no-eval)")
        return await route_tool(ctx, "godot_exec", action, params, is_write=True)
