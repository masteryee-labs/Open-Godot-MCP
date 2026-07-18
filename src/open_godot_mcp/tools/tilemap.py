"""TileMap tools — godot_tilemap (mixed, TileMapLayer/GridMap ops).

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
        "TileMapLayer/GridMap cell operations. node_path is a NODE path (/root/.../TileMapLayer). "
        "Actions: "
        "read_cells(node_path,region?) {cells:[{coords:{x,y},source_id,atlas_coords:{x,y}}]} "
        "(region omitted = all cells; region={x,y,width,height} in grid coords), "
        "set_cell(node_path,coords,source_id,atlas_coords) write, "
        "set_cells(node_path,cells:[{coords,source_id,atlas_coords}]) write, "
        "clear(node_path,region?) write. "
        "coords={x,y} grid coords (not pixels); source_id is TileSource int ID; "
        "atlas_coords={x,y} tile coords within atlas.",
    )
