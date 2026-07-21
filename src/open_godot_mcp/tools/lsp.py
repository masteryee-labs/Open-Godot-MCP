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
        "GDScript LSP (auto-allow). Actions: diagnostics(path?),complete,definition,hover,symbols. path=res://.",
    )
