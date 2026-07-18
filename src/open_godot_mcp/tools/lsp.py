"""LSP tools — godot_lsp (read-only, GDScript language server).

Docs: 02-Tools/Diagnostics.md §godot_lsp
  diagnostics, complete, definition, hover, symbols
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ._helpers import make_simple_tool


def register_lsp_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_lsp",
        "GDScript LSP integration (auto-allow, GDScript only — C# uses Roslyn). "
        "path is res:// resource path. Actions: "
        "diagnostics(path?) {diagnostics:[{line,column,severity,code,message}]} "
        "(severity: error|warning|info; no path = all open scripts), "
        "complete(path,line,column) {completions:[{label,kind,detail?}]} (1-based), "
        "definition(path,line,column) {location:{path,line,column}|null} (1-based), "
        "hover(path,line,column) {hover:{content,kind?}|null}, "
        "symbols(path) {symbols:[{name,kind,line,detail?}]}. "
        "Use LSP diagnostics instead of launching the game to catch errors fast.",
    )
