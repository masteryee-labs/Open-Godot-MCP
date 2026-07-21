"""Batch tools — godot_batch (write, gated, reduce round-trips).

Docs: 02-Tools/Utility.md §godot_batch
  execute
"""
from __future__ import annotations

import asyncio

from fastmcp import FastMCP

from ..context import ServerContext
from ..utils.error_codes import fail, ok
from ._helpers import make_tool, pop_instance_id


def register_batch_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    @make_tool(
        mcp,
        ctx,
        "godot_batch",
        "Batch-execute multiple tool calls in one round-trip (gated). Action: execute(operations:[{tool,action,params}]). No nesting.",
        is_write=True,
    )
    async def godot_batch(action: str, params: dict | None = None) -> dict:
        if action != "execute":
            return fail("INVALID_ARGUMENT", f"Unknown action: {action} (expected 'execute')")
        params = params or {}
        operations = params.get("operations")
        if not isinstance(operations, list):
            return fail("INVALID_ARGUMENT", "operations must be a list of {tool,action,params}")

        async def _run_one(op: dict) -> dict:
            if not isinstance(op, dict):
                return fail("INVALID_ARGUMENT", f"Operation must be a dict, got {type(op).__name__}")
            tool = op.get("tool")
            op_action = op.get("action")
            op_params = op.get("params", {})
            if not tool or not op_action:
                return fail("INVALID_ARGUMENT", "Each operation needs 'tool' and 'action'")
            if tool == "godot_batch":
                return fail("INVALID_ARGUMENT", "Nested godot_batch is not allowed")
            if not isinstance(op_params, dict):
                return fail("INVALID_ARGUMENT", "params must be a dict")
            op_params = dict(op_params)
            op_params, iid = pop_instance_id(op_params)
            try:
                return await ctx.call(tool, op_action, op_params, instance_id=iid)
            except Exception as e:  # noqa: BLE001
                return fail("INTERNAL_ERROR", f"{type(e).__name__}: {e}")

        results = await asyncio.gather(*[_run_one(op) for op in operations])
        return ok(results=list(results))
