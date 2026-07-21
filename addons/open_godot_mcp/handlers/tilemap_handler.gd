extends RefCounted

## Tilemap handler — godot_tilemap (TileMapLayer cell ops).
## TileMapLayer is the ONLY supported node from Godot 4.3+.
## TileMap was deprecated in 4.3 and removed in 4.7.
## Legacy TileMap nodes (pre-4.3 projects) are detected via get_class()
## string comparison (not `is TileMap`) to avoid parse errors on 4.7+.
## Docs: 02-Tools/Resource.md §godot_tilemap

const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")
const _VC = preload("res://addons/open_godot_mcp/utils/variant_codec.gd")
const _SP = preload("res://addons/open_godot_mcp/utils/scene_path.gd")

var _bridge: Node


func handle(tool: String, action: String, params: Dictionary) -> Dictionary:
	match action:
		"read_cells":
			return _read_cells(params)
		"set_cell":
			return _set_cell(params)
		"set_cells":
			return _set_cells(params)
		"clear":
			return _clear(params)
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown action: %s" % action)


func _get_tilemap(params: Dictionary) -> Node:
	var node_path: String = params.get("node_path", "")
	if node_path.is_empty():
		return null
	var scene := EditorInterface.get_edited_scene_root()
	if not scene:
		return null
	return _SP.resolve(node_path, scene)


func _check_tilemap_type(node: Node) -> String:
	## Returns "TileMapLayer", "TileMap" (legacy, pre-4.3), or "" (not a tilemap).
	## TileMapLayer is the only supported node from Godot 4.3+.
	## TileMap was deprecated in 4.3 and removed in 4.7.
	var cls := node.get_class()
	if cls == "TileMapLayer":
		return "TileMapLayer"
	if cls == "TileMap":
		return "TileMap"
	return ""


func _read_cells(params: Dictionary) -> Dictionary:
	var tm := _get_tilemap(params)
	if not tm:
		return _EC.fail("NODE_NOT_FOUND", "TileMapLayer not found")
	var tm_type := _check_tilemap_type(tm)
	if tm_type == "":
		return _EC.fail("INVALID_TYPE", "Node is not a TileMapLayer (got %s). TileMap is deprecated since 4.3, use TileMapLayer." % tm.get_class())
	var region: Dictionary = params.get("region", {})
	var cells := []
	if tm_type == "TileMapLayer":
		var layer := tm as TileMapLayer
		var used_cells := layer.get_used_cells()
		for coord in used_cells:
			var source_id := layer.get_cell_source_id(coord)
			var atlas := layer.get_cell_atlas_coords(coord)
			cells.append({
				"coords": {"x": coord.x, "y": coord.y},
				"source_id": source_id,
				"atlas_coords": {"x": atlas.x, "y": atlas.y},
			})
	else:
		# Legacy TileMap (pre-4.3 project) — dynamic dispatch, no direct type reference
		var layer_count: int = tm.call("get_layers_count")
		for layer_idx in layer_count:
			var used_cells: Array = tm.call("get_used_cells", layer_idx)
			for coord in used_cells:
				var source_id: int = tm.call("get_cell_source_id", layer_idx, coord)
				var atlas: Vector2i = tm.call("get_cell_atlas_coords", layer_idx, coord)
				cells.append({
					"coords": {"x": coord.x, "y": coord.y},
					"source_id": source_id,
					"atlas_coords": {"x": atlas.x, "y": atlas.y},
				})
	return _EC.ok({"cells": cells})


func _set_cell(params: Dictionary) -> Dictionary:
	var tm := _get_tilemap(params)
	if not tm:
		return _EC.fail("NODE_NOT_FOUND", "TileMapLayer not found")
	var tm_type := _check_tilemap_type(tm)
	if tm_type == "":
		return _EC.fail("INVALID_TYPE", "Node is not a TileMapLayer (got %s). TileMap is deprecated since 4.3, use TileMapLayer." % tm.get_class())
	var coords: Dictionary = params.get("coords", {})
	var source_id: int = params.get("source_id", 0)
	var atlas: Dictionary = params.get("atlas_coords", {"x": 0, "y": 0})
	var coord := Vector2i(int(coords.get("x", 0)), int(coords.get("y", 0)))
	var atlas_coord := Vector2i(int(atlas.get("x", 0)), int(atlas.get("y", 0)))
	if tm_type == "TileMapLayer":
		(tm as TileMapLayer).set_cell(coord, source_id, atlas_coord)
	else:
		# Legacy TileMap (pre-4.3 project) — layer 0
		tm.call("set_cell", 0, coord, source_id, atlas_coord)
	return _EC.ok()


func _set_cells(params: Dictionary) -> Dictionary:
	var tm := _get_tilemap(params)
	if not tm:
		return _EC.fail("NODE_NOT_FOUND", "TileMapLayer not found")
	var tm_type := _check_tilemap_type(tm)
	if tm_type == "":
		return _EC.fail("INVALID_TYPE", "Node is not a TileMapLayer (got %s). TileMap is deprecated since 4.3, use TileMapLayer." % tm.get_class())
	var cells: Array = params.get("cells", [])
	for cell in cells:
		var coords: Dictionary = cell.get("coords", {})
		var source_id: int = cell.get("source_id", 0)
		var atlas: Dictionary = cell.get("atlas_coords", {"x": 0, "y": 0})
		var coord := Vector2i(int(coords.get("x", 0)), int(coords.get("y", 0)))
		var atlas_coord := Vector2i(int(atlas.get("x", 0)), int(atlas.get("y", 0)))
		if tm_type == "TileMapLayer":
			(tm as TileMapLayer).set_cell(coord, source_id, atlas_coord)
		else:
			tm.call("set_cell", 0, coord, source_id, atlas_coord)
	return _EC.ok()


func _clear(params: Dictionary) -> Dictionary:
	var tm := _get_tilemap(params)
	if not tm:
		return _EC.fail("NODE_NOT_FOUND", "TileMapLayer not found")
	var tm_type := _check_tilemap_type(tm)
	if tm_type == "":
		return _EC.fail("INVALID_TYPE", "Node is not a TileMapLayer (got %s). TileMap is deprecated since 4.3, use TileMapLayer." % tm.get_class())
	var region: Dictionary = params.get("region", {})
	if tm_type == "TileMapLayer":
		(tm as TileMapLayer).clear()
	else:
		tm.call("clear")
	return _EC.ok()
