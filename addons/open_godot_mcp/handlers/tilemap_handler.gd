extends RefCounted

## Tilemap handler — godot_tilemap (TileMapLayer/GridMap cell ops).
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


func _read_cells(params: Dictionary) -> Dictionary:
	var tm := _get_tilemap(params)
	if not tm:
		return _EC.fail("NODE_NOT_FOUND", "TileMap not found")
	var region: Dictionary = params.get("region", {})
	var cells := []
	# Handle TileMapLayer (Godot 4.5+) and TileMap
	if tm is TileMapLayer:
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
	elif tm is TileMap:
		var tilemap := tm as TileMap
		# Godot 4.x TileMap has layers; get layer 0
		for layer_idx in tilemap.get_layers_count():
			for coord in tilemap.get_used_cells(layer_idx):
				var source_id := tilemap.get_cell_source_id(layer_idx, coord)
				var atlas := tilemap.get_cell_atlas_coords(layer_idx, coord)
				cells.append({
					"coords": {"x": coord.x, "y": coord.y},
					"source_id": source_id,
					"atlas_coords": {"x": atlas.x, "y": atlas.y},
				})
	return _EC.ok({"cells": cells})


func _set_cell(params: Dictionary) -> Dictionary:
	var tm := _get_tilemap(params)
	if not tm:
		return _EC.fail("NODE_NOT_FOUND", "TileMap not found")
	var coords: Dictionary = params.get("coords", {})
	var source_id: int = params.get("source_id", 0)
	var atlas: Dictionary = params.get("atlas_coords", {"x": 0, "y": 0})
	var coord := Vector2i(int(coords.get("x", 0)), int(coords.get("y", 0)))
	var atlas_coord := Vector2i(int(atlas.get("x", 0)), int(atlas.get("y", 0)))
	if tm is TileMapLayer:
		(tm as TileMapLayer).set_cell(coord, source_id, atlas_coord)
	elif tm is TileMap:
		(tm as TileMap).set_cell(0, coord, source_id, atlas_coord)
	return _EC.ok()


func _set_cells(params: Dictionary) -> Dictionary:
	var tm := _get_tilemap(params)
	if not tm:
		return _EC.fail("NODE_NOT_FOUND", "TileMap not found")
	var cells: Array = params.get("cells", [])
	for cell in cells:
		var coords: Dictionary = cell.get("coords", {})
		var source_id: int = cell.get("source_id", 0)
		var atlas: Dictionary = cell.get("atlas_coords", {"x": 0, "y": 0})
		var coord := Vector2i(int(coords.get("x", 0)), int(coords.get("y", 0)))
		var atlas_coord := Vector2i(int(atlas.get("x", 0)), int(atlas.get("y", 0)))
		if tm is TileMapLayer:
			(tm as TileMapLayer).set_cell(coord, source_id, atlas_coord)
		elif tm is TileMap:
			(tm as TileMap).set_cell(0, coord, source_id, atlas_coord)
	return _EC.ok()


func _clear(params: Dictionary) -> Dictionary:
	var tm := _get_tilemap(params)
	if not tm:
		return _EC.fail("NODE_NOT_FOUND", "TileMap not found")
	var region: Dictionary = params.get("region", {})
	if tm is TileMapLayer:
		(tm as TileMapLayer).clear()
	elif tm is TileMap:
		(tm as TileMap).clear()
	return _EC.ok()
