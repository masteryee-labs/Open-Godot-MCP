"""Asset tools — godot_asset (mixed, asset generation & management).

Docs: 02-Tools/Utility.md §godot_asset
  generate_2d, list, info, import
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ._helpers import make_simple_tool


def register_asset_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_asset",
        "Asset generation & management. Actions: generate_2d(svg,filename,save_path,width?,height?),list,info,import.",
    )
