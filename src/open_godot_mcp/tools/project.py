"""Project tools — godot_project / godot_input_map.

Docs: 02-Tools/Project.md
  project: info, get_setting, set_setting, list_settings, autoload_list/add/remove, rescan
  input_map: list, add, remove, bind, ensure, get
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ._helpers import make_simple_tool


def register_project_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_project",
        "Project settings & autoloads. Actions: info,get_setting,set_setting,list_settings,autoload_list,autoload_add,autoload_remove,rescan.",
    )
    make_simple_tool(
        mcp,
        ctx,
        "godot_input_map",
        "InputMap management. Actions: list,add,remove,bind,ensure,get.",
    )
