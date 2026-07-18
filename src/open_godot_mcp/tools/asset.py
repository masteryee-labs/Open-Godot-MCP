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
        "Asset generation & management. Actions: "
        "generate_2d(svg,filename,save_path,width?,height?) write -> {ok,path} "
        "(svg is SVG string content; save_path is res:// dir; "
        "path returned is full res:// path like res://assets/enemy.png; "
        "width/height omit to use SVG viewBox), "
        "list(dir,type?) read {assets:[{path,type,name}]} "
        "(type is Godot resource class name string like 'Texture2D','AudioStream','Font'), "
        "info(path) read {type,size,dimensions?} (dimensions for images/textures only), "
        "import(source_path,dest_path,preset?) write "
        "(source_path=filesystem abs path; dest_path=res://...).",
    )
