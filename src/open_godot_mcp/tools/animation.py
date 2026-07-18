"""Animation tools — godot_animation (mixed, AnimationPlayer ops).

Docs: 02-Tools/Resource.md §godot_animation
  list, get, create, add_track, delete, play, stop, preset
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ._helpers import make_simple_tool


def register_animation_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_animation",
        "AnimationPlayer operations. player_path is a NODE path (/root/.../AnimationPlayer). "
        "Actions: "
        "list(player_path) {animations:[str]}, "
        "get(player_path,name) {tracks,length,loop}, "
        "create(player_path,name,length,loop?) write (length in seconds), "
        "add_track(player_path,anim,track_type,path,keyframes) write "
        "(track_type: value|transform|bezier|method|audio|animation; "
        "path is relative to AnimationPlayer's parent: 'Node:property' "
        "(transform tracks: just 'Node' no :property); "
        "keyframes: all time values in SECONDS; "
        "value:[{time,value}], transform:[{time,position,rotation_deg,scale}], "
        "bezier:[{time,value,in_handle,out_handle}], "
        "method:[{time,method,args}], audio:[{time,stream_path,start_offset,end_offset}], "
        "animation:[{time,animation}]), "
        "delete(player_path,name) write, "
        "play(player_path,name) write (EDITOR PREVIEW only; for runtime use godot_exec call), "
        "stop(player_path) write, "
        "preset(player_path,anim,preset,target) write "
        "(preset: fade|slide|shake|pulse; target relative to AnimationPlayer parent "
        "like 'Player/Sprite2D' NOT /root/...; "
        "fade=modulate:a 1->0->1, slide=position +50px->back, "
        "shake=position random 5px 0.3s, pulse=scale 1->1.2->1).",
    )
