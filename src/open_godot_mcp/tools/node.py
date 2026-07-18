"""Node tools — godot_node_read / godot_node_edit.

Docs: 02-Tools/Scene-Node.md
  read: inspect, tree, find, children, properties  (all use /root/... paths)
  edit: create, delete, reparent, rename, duplicate, set_property, set_properties, set_groups
"""
from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext
from ._helpers import make_simple_tool


def register_node_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_node_read",
        "Read nodes from the editor's loaded scene tree (auto-allow). Actions: "
        "inspect(node_path,properties?) {type,name,properties:{}}, "
        "tree(root_path?,depth?,offset?,limit?) {root,children:[...],total,has_more}, "
        "find(name?/type?/group?/path_glob?) {nodes:[{path,type,name}]}, "
        "children(node_path,recursive?) {children:[{name,type,path}]}, "
        "properties(node_path) {properties:{}}, "
        "get_signals(node_path) {signals:[{name,connections:[{signal,callable,flags}]}]}, "
        "get_groups(node_path) {groups:[str]}, "
        "find_in_group(group) {nodes:[{path,name,type}]}. "
        "All node_path use /root/... format. Godot types are JSON objects "
        "(Vector2={x,y}, Color={r,g,b,a}).",
    )
    make_simple_tool(
        mcp,
        ctx,
        "godot_node_edit",
        "Edit nodes in the editor (gated, Undo/Redo on all mutations). Actions: "
        "create(type,name,parent_path,properties?) -> {ok,node_path}, "
        "create_batch(nodes:[{type,name,parent_path,properties?}]) -> {ok,created:[{name,type}],count} "
        "(batch create in one UndoRedo action, partial rollback on error), "
        "delete(node_path), reparent(node_path,new_parent,index?), "
        "rename(node_path,new_name), duplicate(node_path,new_name?) -> {ok,node_path}, "
        "set_property(node_path,property,value), "
        "set_properties(node_path,properties:{}), "
        "set_groups(node_path,groups:[str]), "
        "add_to_group(node_path,group), remove_from_group(node_path,group), "
        "connect_signal(source_path,signal,target_path,method), "
        "disconnect_signal(source_path,signal,target_path,method). "
        "type is a Godot class name (Node2D, CharacterBody2D, ...). "
        "properties values use JSON Godot-type encoding.",
        is_write=True,
    )
