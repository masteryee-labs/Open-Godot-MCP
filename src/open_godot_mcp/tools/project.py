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
        "Project settings & autoloads. Actions: "
        "info {name,version,godot_version,main_scene}, "
        "get_setting(key) {value}, set_setting(key,value) write, "
        "list_settings(category?) {settings:{}}, "
        "autoload_list {autoloads:[{name,path,enabled}]}, "
        "autoload_add(name,path=res://...) write, autoload_remove(name) write, "
        "rescan write. key uses / separated path like 'display/window/size/viewport_width'.",
    )
    make_simple_tool(
        mcp,
        ctx,
        "godot_input_map",
        "InputMap management. Actions: "
        "list(include_builtin?) {actions:[{name,deadzone,events}]}, "
        "add(action,deadzone?) write, remove(action) write, "
        "bind(action,event_type,params) write, ensure(...) write (idempotent), "
        "get(action) {events:[{event_type,params}]}. "
        "event_type: 'key'|'mouse_button'|'joypad_button'|'joypad_axis'. "
        "params: key={key:'KEY_SPACE',modifiers?}, mouse_button={button:'MOUSE_BUTTON_LEFT'}, "
        "joypad_button={device:0,button:'JOY_BUTTON_A'}, "
        "joypad_axis={device:0,axis:'JOY_AXIS_LEFT_X',axis_range:1}.",
    )
