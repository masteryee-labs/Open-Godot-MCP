"""C# tools — godot_csharp_check (read-only compile/syntax check).

Docs: 08-CSharp-Support/Syntax-Check.md
  info, build, syntax
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ._helpers import make_simple_tool


def register_csharp_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_csharp_check",
        "C# compile/syntax check. Actions: info,build(project?),syntax(source?/path?).",
    )
