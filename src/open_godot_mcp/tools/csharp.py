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
        "C# compile/syntax check (read-only). Actions: "
        "info {is_dotnet,csproj,dotnet_available,dotnet_version} — check if project is .NET, "
        "build(project?) {ok,errors:[{file,line,col,code,message}],warnings,exit_code} — run dotnet build, "
        "syntax(source?/path?) {ok,errors:[{line,col,code,message}]} — basic syntax check (brace balance, GDScript-in-C# detection), "
        "use 'build' for full compile check via dotnet build.",
    )
