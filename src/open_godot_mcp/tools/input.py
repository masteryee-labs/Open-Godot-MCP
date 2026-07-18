"""Input tools — godot_input (write, gated).

Docs: 02-Tools/Input.md
  action, key, mouse_button, mouse_motion, joypad, text
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ._helpers import make_simple_tool


def register_input_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_input",
        "Inject input into the running game (gated). Actions: "
        "action(action,pressed,strength?) InputMap action (strength 0.0-1.0), "
        "key(key,pressed,modifiers?) key='KEY_SPACE' modifiers=['ctrl','shift','alt','meta'], "
        "mouse_button(button,position,pressed) button='MOUSE_BUTTON_LEFT' "
        "position={x,y} in ACTUAL window pixels (not design resolution!), "
        "mouse_motion(delta,button_mask?) delta={x,y} relative pixels, "
        "joypad(device,control,index,value?) control='button'|'axis' "
        "index='JOY_BUTTON_A'/'JOY_AXIS_LEFT_X' value=-1..1 (axis only), "
        "text(text) unicode text input, "
        "record_start() -> {started,start_frame} begin recording all injected inputs, "
        "record_stop() -> {stopped,events:[{frame,input}],event_count,duration_frames} "
        "stop recording and return event log, "
        "replay(events?) -> {replayed,duration_frames} replay recorded events "
        "(uses last record buffer if events omitted), "
        "sequence(steps:[input_dict],frame_delay?) -> {executed} "
        "execute multiple inputs in sequence with frame delay between each. "
        "ALWAYS call godot_game status first to get viewport_size for mouse coords. "
        "Mouse position is actual window pixel coords, NOT design resolution.",
        is_write=True,
    )
