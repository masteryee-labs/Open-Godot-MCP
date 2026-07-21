"""TileMapLayer tools — godot_tilemap (mixed, TileMapLayer cell ops).

TileMapLayer is the only supported node from Godot 4.3+.
TileMap was deprecated in 4.3 and removed in 4.7.
Legacy TileMap nodes (pre-4.3 projects) are supported via dynamic dispatch.

Docs: 02-Tools/Resource.md §godot_tilemap
  read_cells, set_cell, set_cells, clear
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ._helpers import make_simple_tool


def register_tilemap_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_tilemap",
        "TileMapLayer/GridMap cell ops. Actions: read_cells(node_path,region?),set_cell,set_cells,clear. node_path=/root/....",
    )
