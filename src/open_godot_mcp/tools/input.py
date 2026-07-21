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
        "Inject input into running game (gated). Actions: action,key,mouse_button,mouse_motion,joypad,text,record_start,record_stop,replay,sequence.",
        is_write=True,
    )
