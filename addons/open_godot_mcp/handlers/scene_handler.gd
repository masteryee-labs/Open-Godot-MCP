extends RefCounted

## Scene handler — godot_scene (scene file ops).
## Docs: 02-Tools/Scene-Node.md §godot_scene

const _VC = preload("res://addons/open_godot_mcp/utils/variant_codec.gd")
const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")
const _SP = preload("res://addons/open_godot_mcp/utils/scene_path.gd")

var _bridge: Node


func handle(tool: String, action: String, params: Dictionary) -> Dictionary:
	match action:
		"create":
			return _create(params)
		"read":
			return _read(params)
		"save":
			return _save(params)
		"save_as":
			return _save_as(params)
		"hierarchy":
			return _hierarchy(params)
		"instantiate":
			return _instantiate(params)
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown action: %s" % action)


func _create(params: Dictionary) -> Dictionary:
	var path: String = params.get("path", "")
	var root_type: String = params.get("root_type", "Node")
	var root_name: String = params.get("root_name", "Root")
	if path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "path required (res://...)")
	if not path.ends_with(".tscn"):
		return _EC.fail("INVALID_ARGUMENT", "path must end with .tscn")
	# Create the root node
	var root_class: String = root_type
	if not ClassDB.class_exists(root_class):
		return _EC.fail("INVALID_ARGUMENT", "Unknown class: %s" % root_class)
	var root: Node = ClassDB.instantiate(root_class)
	root.name = root_name
	var scene := PackedScene.new()
	var err := scene.pack(root)
	if err != OK:
		root.free()
		return _EC.fail("INTERNAL_ERROR", "Failed to pack scene: %s" % error_string(err))
	err = ResourceSaver.save(scene, path)
	root.free()
	if err != OK:
		return _EC.fail("INTERNAL_ERROR", "Failed to save scene: %s" % error_string(err))
	return _EC.ok()


func _read(params: Dictionary) -> Dictionary:
	var path: String = params.get("path", "")
	var include_props: bool = params.get("include_properties", false)
	if path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "path required")
	if not ResourceLoader.exists(path):
		return _EC.fail("RESOURCE_NOT_FOUND", "Scene not found: %s" % path)
	var packed := load(path) as PackedScene
	if not packed:
		return _EC.fail("RESOURCE_NOT_FOUND", "Failed to load scene: %s" % path)
	var instance := packed.instantiate()
	var root_info := {"name": instance.name, "type": instance.get_class(), "path": str(instance.get_path())}
	var nodes := _collect_nodes(instance, include_props)
	var signals := _collect_signals(instance)
	instance.free()
	return _EC.ok({"root": root_info, "nodes": nodes, "signals": signals})


func _collect_nodes(node: Node, include_props: bool, depth: int = 0) -> Array:
	var arr := []
	var info := {"name": node.name, "type": node.get_class(), "path": str(node.get_path())}
	if include_props:
		info["properties"] = _VC.encode_node_properties(node)
	arr.append(info)
	for child in node.get_children():
		arr.append_array(_collect_nodes(child, include_props, depth + 1))
	return arr


func _collect_signals(node: Node) -> Array:
	var sigs := []
	for conn in node.get_incoming_connections():
		sigs.append({
			"signal": conn["signal_name"],
			"source_path": str(conn["source"].get_path()) if conn["source"] else "",
			"target_path": str(node.get_path()),
			"method": conn["callable"].get_method(),
		})
	return sigs


func _save(params: Dictionary) -> Dictionary:
	var path: String = params.get("path", "")
	var scene := EditorInterface.get_edited_scene_root()
	if not scene:
		return _EC.fail("SCENE_NOT_LOADED", "No scene open")
	if path.is_empty():
		if scene.scene_file_path.is_empty():
			return _EC.fail("INVALID_ARGUMENT", "Current scene has no path; use save_as with a path")
		var err := EditorInterface.save_scene()
		if err != OK:
			return _EC.fail("INTERNAL_ERROR", "Save failed: %s" % error_string(err))
	else:
		EditorInterface.save_scene_as(path, false)
	return _EC.ok()


func _save_as(params: Dictionary) -> Dictionary:
	var path: String = params.get("path", "")
	if path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "path required")
	EditorInterface.save_scene_as(path, false)
	return _EC.ok()


func _hierarchy(params: Dictionary) -> Dictionary:
	var path: String = params.get("path", "")
	var depth: int = params.get("depth", -1)  # -1 = unlimited
	if path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "path required")
	if not ResourceLoader.exists(path):
		return _EC.fail("RESOURCE_NOT_FOUND", "Scene not found: %s" % path)
	var packed := load(path) as PackedScene
	if not packed:
		return _EC.fail("RESOURCE_NOT_FOUND", "Failed to load: %s" % path)
	var instance := packed.instantiate()
	var tree := _build_hierarchy(instance, depth, 0)
	instance.free()
	return _EC.ok({"tree": tree})


func _build_hierarchy(node: Node, max_depth: int, current_depth: int) -> Dictionary:
	var info := {"name": node.name, "type": node.get_class()}
	if max_depth < 0 or current_depth < max_depth:
		var children := []
		for child in node.get_children():
			children.append(_build_hierarchy(child, max_depth, current_depth + 1))
		info["children"] = children
	else:
		info["children"] = []
	return info


func _instantiate(params: Dictionary) -> Dictionary:
	var child_path: String = params.get("child_scene_path", "")
	var parent_path: String = params.get("parent_path", "")
	var name: String = params.get("name", "")
	if child_path.is_empty() or parent_path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "child_scene_path and parent_path required")
	if not ResourceLoader.exists(child_path):
		return _EC.fail("RESOURCE_NOT_FOUND", "Scene not found: %s" % child_path)
	var scene := EditorInterface.get_edited_scene_root()
	if not scene:
		return _EC.fail("SCENE_NOT_LOADED", "No scene open")
	var parent := _SP.resolve(parent_path, scene)
	if not parent:
		return _EC.fail("NODE_NOT_FOUND", "Parent not found: %s" % parent_path)
	var packed := load(child_path) as PackedScene
	var instance := packed.instantiate()
	if not name.is_empty():
		instance.name = name
	parent.add_child(instance)
	instance.owner = scene
	return _EC.ok()
