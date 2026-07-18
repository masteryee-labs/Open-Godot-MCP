extends RefCounted

## Node handler — godot_node_read / godot_node_edit.
## Docs: 02-Tools/Scene-Node.md

const _VC = preload("res://addons/open_godot_mcp/utils/variant_codec.gd")
const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")
const _SP = preload("res://addons/open_godot_mcp/utils/scene_path.gd")

var _bridge: Node


func handle(tool: String, action: String, params: Dictionary) -> Dictionary:
	match action:
		"inspect":
			return _inspect(params)
		"tree":
			return _tree(params)
		"find":
			return _find(params)
		"children":
			return _children(params)
		"properties":
			return _properties(params)
		"get_signals":
			return _get_signals(params)
		"get_groups":
			return _get_groups(params)
		"find_in_group":
			return _find_in_group(params)
		"create":
			return _create(params)
		"create_batch":
			return _create_batch(params)
		"delete":
			return _delete(params)
		"reparent":
			return _reparent(params)
		"rename":
			return _rename(params)
		"duplicate":
			return _duplicate(params)
		"set_property":
			return _set_property(params)
		"set_properties":
			return _set_properties(params)
		"set_groups":
			return _set_groups(params)
		"add_to_group":
			return _add_to_group(params)
		"remove_from_group":
			return _remove_from_group(params)
		"connect_signal":
			return _connect_signal(params)
		"disconnect_signal":
			return _disconnect_signal(params)
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown action: %s" % action)


func _get_scene_root() -> Node:
	return EditorInterface.get_edited_scene_root()


func _find_node(node_path: String) -> Node:
	var scene := _get_scene_root()
	if not scene:
		return null
	return _SP.resolve(node_path, scene)


func _inspect(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	var props: Array = params.get("properties", [])
	if node_path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "node_path required")
	var node := _find_node(node_path)
	if not node:
		return _EC.fail("NODE_NOT_FOUND", _SP.format_node_error(node_path, _get_scene_root()))
	var prop_dict := _VC.encode_node_properties(node, PackedStringArray(props))
	return _EC.ok({"type": node.get_class(), "name": node.name, "properties": prop_dict})


func _tree(params: Dictionary) -> Dictionary:
	var root_path: String = params.get("root_path", "")
	var depth: int = params.get("depth", -1)
	var offset: int = params.get("offset", 0)
	var limit: int = params.get("limit", 500)
	var scene := _get_scene_root()
	if not scene:
		return _EC.fail("SCENE_NOT_LOADED", "No scene open")
	var root: Node = scene
	if not root_path.is_empty():
		root = _SP.resolve(root_path, scene)
		if not root:
			return _EC.fail("NODE_NOT_FOUND", "Root not found: %s" % root_path)
	var count := {"value": 0}
	var children := _build_tree_children(root, depth, 0, count, offset, limit)
	return _EC.ok({
		"root": {"name": root.name, "type": root.get_class(), "path": str(root.get_path())},
		"children": children,
		"total": count["value"],
		"has_more": count["value"] > offset + limit,
	})


func _build_tree_children(node: Node, max_depth: int, current_depth: int, count: Dictionary, offset: int, limit: int) -> Array:
	var arr := []
	if max_depth >= 0 and current_depth >= max_depth:
		return arr
	for child in node.get_children():
		count["value"] = int(count["value"]) + 1
		if count["value"] <= offset or count["value"] > offset + limit:
			continue
		var info := {
			"name": child.name,
			"type": child.get_class(),
			"path": str(child.get_path()),
			"children_count": child.get_child_count(),
		}
		info["children"] = _build_tree_children(child, max_depth, current_depth + 1, count, offset, limit)
		arr.append(info)
	return arr


func _find(params: Dictionary) -> Dictionary:
	var name_filter: String = params.get("name", "")
	var type_filter: String = params.get("type", "")
	var group_filter: String = params.get("group", "")
	var path_glob: String = params.get("path_glob", "")
	var scene := _get_scene_root()
	if not scene:
		return _EC.fail("SCENE_NOT_LOADED", "No scene open")
	var nodes := []
	_find_recursive(scene, nodes, name_filter, type_filter, group_filter, path_glob)
	var result := []
	for n in nodes:
		result.append({"path": str(n.get_path()), "type": n.get_class(), "name": n.name})
	return _EC.ok({"nodes": result})


func _find_recursive(node: Node, out: Array, name_f: String, type_f: String, group_f: String, glob: String) -> void:
	var is_match := true
	if not name_f.is_empty() and node.name != name_f:
		is_match = false
	if not type_f.is_empty() and not node.is_class(type_f):
		is_match = false
	if not group_f.is_empty() and not node.is_in_group(group_f):
		is_match = false
	if not glob.is_empty():
		# Simple glob: support * in path
		var path := str(node.get_path())
		if not _glob_match(glob, path):
			is_match = false
	if is_match:
		out.append(node)
	for child in node.get_children():
		_find_recursive(child, out, name_f, type_f, group_f, glob)


func _glob_match(pattern: String, text: String) -> bool:
	# Convert glob to regex-like matching
	# ** = any chars including /, * = any chars except /
	var regex_pattern := "^"
	var i := 0
	while i < pattern.length():
		if pattern.substr(i, 2) == "**":
			regex_pattern += ".*"
			i += 2
		elif pattern[i] == "*":
			regex_pattern += "[^/]*"
			i += 1
		else:
			regex_pattern += "\\" + pattern[i] if pattern[i] in ".+()[]{}|^$" else pattern[i]
			i += 1
	regex_pattern += "$"
	var regex := RegEx.new()
	if regex.compile(regex_pattern) != OK:
		return false
	return regex.search(text) != null


func _children(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	var recursive: bool = params.get("recursive", false)
	if node_path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "node_path required")
	var node := _find_node(node_path)
	if not node:
		return _EC.fail("NODE_NOT_FOUND", "Node not found: %s" % node_path)
	var children := []
	if recursive:
		_collect_all_descendants(node, children)
	else:
		for child in node.get_children():
			children.append({"name": child.name, "type": child.get_class(), "path": str(child.get_path())})
	return _EC.ok({"children": children})


func _collect_all_descendants(node: Node, out: Array) -> void:
	for child in node.get_children():
		out.append({"name": child.name, "type": child.get_class(), "path": str(child.get_path())})
		_collect_all_descendants(child, out)


func _properties(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	if node_path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "node_path required")
	var node := _find_node(node_path)
	if not node:
		return _EC.fail("NODE_NOT_FOUND", "Node not found: %s" % node_path)
	var all_props := PackedStringArray()
	for p in node.get_property_list():
		var n: String = p["name"]
		if not n.begins_with("_") and n not in ["script", "resource_path"]:
			all_props.append(n)
	return _EC.ok({"properties": _VC.encode_node_properties(node, all_props)})


# ---- edit actions ----

func _create(params: Dictionary) -> Dictionary:
	var type_name: String = params.get("type", "")
	var name: String = params.get("name", "")
	var parent_path: String = params.get("parent_path", "")
	var properties: Dictionary = params.get("properties", {})
	if type_name.is_empty() or name.is_empty() or parent_path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "type, name, parent_path required")
	if not ClassDB.class_exists(type_name):
		return _EC.fail("INVALID_ARGUMENT", "Unknown class: %s" % type_name)
	var scene := _get_scene_root()
	if not scene:
		return _EC.fail("SCENE_NOT_LOADED", "No scene open")
	var parent := _SP.resolve(parent_path, scene)
	if not parent:
		return _EC.fail("NODE_NOT_FOUND", "Parent not found: %s" % parent_path)
	var node: Node = ClassDB.instantiate(type_name)
	node.name = name
	var ur := EditorInterface.get_editor_undo_redo()
	ur.create_action("Create %s '%s'" % [type_name, name])
	ur.add_do_method(parent, "add_child", node)
	ur.add_do_method(node, "set_owner", scene)
	for prop_name in properties:
		var decoded := _VC.decode_variant(properties[prop_name])
		ur.add_do_property(node, prop_name, decoded)
	ur.add_undo_method(parent, "remove_child", node)
	ur.add_undo_reference(node)
	ur.commit_action()
	return _EC.ok({"node_path": str(node.get_path())})


func _delete(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	if node_path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "node_path required")
	var node := _find_node(node_path)
	if not node:
		return _EC.fail("NODE_NOT_FOUND", "Node not found: %s" % node_path)
	var parent := node.get_parent()
	var idx := node.get_index()
	var scene := _get_scene_root()
	var ur := EditorInterface.get_editor_undo_redo()
	ur.create_action("Delete '%s'" % node.name)
	ur.add_do_method(parent, "remove_child", node)
	ur.add_undo_method(parent, "add_child", node)
	ur.add_undo_method(parent, "move_child", node, idx)
	ur.add_undo_method(node, "set_owner", scene)
	ur.add_undo_reference(node)
	ur.commit_action()
	return _EC.ok()


func _reparent(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	var new_parent: String = params.get("new_parent", "")
	var index: int = params.get("index", -1)
	if node_path.is_empty() or new_parent.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "node_path, new_parent required")
	var node := _find_node(node_path)
	if not node:
		return _EC.fail("NODE_NOT_FOUND", "Node not found: %s" % node_path)
	var parent := _find_node(new_parent)
	if not parent:
		return _EC.fail("NODE_NOT_FOUND", "Parent not found: %s" % new_parent)
	var old_parent := node.get_parent()
	var old_idx := node.get_index()
	var ur := EditorInterface.get_editor_undo_redo()
	ur.create_action("Reparent '%s'" % node.name)
	ur.add_do_method(old_parent, "remove_child", node)
	ur.add_do_method(parent, "add_child", node)
	if index >= 0:
		ur.add_do_method(parent, "move_child", node, index)
	ur.add_undo_method(parent, "remove_child", node)
	ur.add_undo_method(old_parent, "add_child", node)
	ur.add_undo_method(old_parent, "move_child", node, old_idx)
	ur.commit_action()
	return _EC.ok()


func _rename(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	var new_name: String = params.get("new_name", "")
	if node_path.is_empty() or new_name.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "node_path, new_name required")
	var node := _find_node(node_path)
	if not node:
		return _EC.fail("NODE_NOT_FOUND", "Node not found: %s" % node_path)
	var ur := EditorInterface.get_editor_undo_redo()
	ur.create_action("Rename '%s' to '%s'" % [node.name, new_name])
	ur.add_do_property(node, "name", new_name)
	ur.add_undo_property(node, "name", node.name)
	ur.commit_action()
	return _EC.ok()


func _duplicate(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	var new_name: String = params.get("new_name", "")
	if node_path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "node_path required")
	var node := _find_node(node_path)
	if not node:
		return _EC.fail("NODE_NOT_FOUND", "Node not found: %s" % node_path)
	var scene := _get_scene_root()
	var parent := node.get_parent()
	var dup := node.duplicate()
	if not new_name.is_empty():
		dup.name = new_name
	var ur := EditorInterface.get_editor_undo_redo()
	ur.create_action("Duplicate '%s'" % node.name)
	ur.add_do_method(parent, "add_child", dup)
	ur.add_do_method(dup, "set_owner", scene)
	ur.add_undo_method(parent, "remove_child", dup)
	ur.add_undo_reference(dup)
	ur.commit_action()
	return _EC.ok({"node_path": str(dup.get_path())})


func _set_property(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	var prop: String = params.get("property", "")
	var value: Variant = params.get("value", null)
	if node_path.is_empty() or prop.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "node_path, property required")
	var node := _find_node(node_path)
	if not node:
		return _EC.fail("NODE_NOT_FOUND", "Node not found: %s" % node_path)
	var decoded := _VC.decode_variant(value)
	var ur := EditorInterface.get_editor_undo_redo()
	ur.create_action("Set %s.%s" % [node.name, prop])
	ur.add_do_property(node, prop, decoded)
	ur.add_undo_property(node, prop, node.get(prop))
	ur.commit_action()
	return _EC.ok()


func _set_properties(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	var properties: Dictionary = params.get("properties", {})
	if node_path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "node_path required")
	var node := _find_node(node_path)
	if not node:
		return _EC.fail("NODE_NOT_FOUND", "Node not found: %s" % node_path)
	var ur := EditorInterface.get_editor_undo_redo()
	ur.create_action("Set properties on '%s'" % node.name)
	for prop_name in properties:
		var decoded := _VC.decode_variant(properties[prop_name])
		ur.add_do_property(node, prop_name, decoded)
		ur.add_undo_property(node, prop_name, node.get(prop_name))
	ur.commit_action()
	return _EC.ok()


func _set_groups(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	var groups: Array = params.get("groups", [])
	if node_path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "node_path required")
	var node := _find_node(node_path)
	if not node:
		return _EC.fail("NODE_NOT_FOUND", "Node not found: %s" % node_path)
	var old_groups: Array = []
	for g in node.get_groups():
		old_groups.append(g)
	var ur := EditorInterface.get_editor_undo_redo()
	ur.create_action("Set groups on '%s'" % node.name)
	for g in old_groups:
		ur.add_do_method(node, "remove_from_group", g)
		ur.add_undo_method(node, "add_to_group", g)
	for g in groups:
		ur.add_do_method(node, "add_to_group", g)
		ur.add_undo_method(node, "remove_from_group", g)
	ur.commit_action()
	return _EC.ok()


func _add_to_group(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	var group: String = params.get("group", "")
	if node_path.is_empty() or group.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "node_path, group required")
	var node := _find_node(node_path)
	if not node:
		return _EC.fail("NODE_NOT_FOUND", "Node not found: %s" % node_path)
	var ur := EditorInterface.get_editor_undo_redo()
	ur.create_action("Add '%s' to group '%s'" % [node.name, group])
	ur.add_do_method(node, "add_to_group", group)
	ur.add_undo_method(node, "remove_from_group", group)
	ur.commit_action()
	return _EC.ok()


func _remove_from_group(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	var group: String = params.get("group", "")
	if node_path.is_empty() or group.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "node_path, group required")
	var node := _find_node(node_path)
	if not node:
		return _EC.fail("NODE_NOT_FOUND", "Node not found: %s" % node_path)
	if not node.is_in_group(group):
		return _EC.fail("INVALID_ARGUMENT", "Node not in group: %s" % group)
	var ur := EditorInterface.get_editor_undo_redo()
	ur.create_action("Remove '%s' from group '%s'" % [node.name, group])
	ur.add_do_method(node, "remove_from_group", group)
	ur.add_undo_method(node, "add_to_group", group)
	ur.commit_action()
	return _EC.ok()


func _get_groups(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	if node_path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "node_path required")
	var node := _find_node(node_path)
	if not node:
		return _EC.fail("NODE_NOT_FOUND", "Node not found: %s" % node_path)
	var groups: Array = []
	for g in node.get_groups():
		groups.append(g)
	return _EC.ok({"groups": groups})


func _find_in_group(params: Dictionary) -> Dictionary:
	var group: String = params.get("group", "")
	if group.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "group required")
	var scene := _get_scene_root()
	if not scene:
		return _EC.fail("SCENE_NOT_LOADED", "No scene open")
	var scene_path := str(scene.get_path())
	var nodes := []
	for n in scene.get_tree().get_nodes_in_group(group):
		var np := str(n.get_path())
		# Include nodes that are descendants of the edited scene root
		if np == scene_path or np.begins_with(scene_path + "/"):
			nodes.append({"path": np, "name": n.name, "type": n.get_class()})
	return _EC.ok({"nodes": nodes})


# ---- signal actions ----

func _get_signals(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	if node_path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "node_path required")
	var node := _find_node(node_path)
	if not node:
		return _EC.fail("NODE_NOT_FOUND", "Node not found: %s" % node_path)
	var signals := []
	for s in node.get_signal_list():
		var sig_name: String = s["name"]
		var conns := node.get_signal_connection_list(sig_name)
		var conn_list := []
		for c in conns:
			conn_list.append({
				"signal": str(c["signal"]),
				"callable": str(c["callable"]),
				"flags": int(c["flags"]),
			})
		signals.append({"name": sig_name, "connections": conn_list})
	return _EC.ok({"signals": signals})


func _connect_signal(params: Dictionary) -> Dictionary:
	var source_path: String = params.get("source_path", "")
	var signal_name: String = params.get("signal", "")
	var target_path: String = params.get("target_path", "")
	var method: String = params.get("method", "")
	if source_path.is_empty() or signal_name.is_empty() or target_path.is_empty() or method.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "source_path, signal, target_path, method required")
	var source := _find_node(source_path)
	if not source:
		return _EC.fail("NODE_NOT_FOUND", "Source not found: %s" % source_path)
	var target := _find_node(target_path)
	if not target:
		return _EC.fail("NODE_NOT_FOUND", "Target not found: %s" % target_path)
	if not source.has_signal(signal_name):
		return _EC.fail("INVALID_ARGUMENT", "Signal '%s' not found on %s" % [signal_name, source.get_class()])
	var ur := EditorInterface.get_editor_undo_redo()
	ur.create_action("Connect %s::%s -> %s::%s" % [source.name, signal_name, target.name, method])
	ur.add_do_method(source, "connect", signal_name, Callable(target, method))
	ur.add_undo_method(source, "disconnect", signal_name, Callable(target, method))
	ur.commit_action()
	return _EC.ok()


func _disconnect_signal(params: Dictionary) -> Dictionary:
	var source_path: String = params.get("source_path", "")
	var signal_name: String = params.get("signal", "")
	var target_path: String = params.get("target_path", "")
	var method: String = params.get("method", "")
	if source_path.is_empty() or signal_name.is_empty() or target_path.is_empty() or method.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "source_path, signal, target_path, method required")
	var source := _find_node(source_path)
	if not source:
		return _EC.fail("NODE_NOT_FOUND", "Source not found: %s" % source_path)
	var target := _find_node(target_path)
	if not target:
		return _EC.fail("NODE_NOT_FOUND", "Target not found: %s" % target_path)
	var callable := Callable(target, method)
	if not source.is_connected(signal_name, callable):
		return _EC.fail("INVALID_ARGUMENT", "Signal not connected: %s::%s -> %s::%s" % [source.name, signal_name, target.name, method])
	var ur := EditorInterface.get_editor_undo_redo()
	ur.create_action("Disconnect %s::%s -> %s::%s" % [source.name, signal_name, target.name, method])
	ur.add_do_method(source, "disconnect", signal_name, callable)
	ur.add_undo_method(source, "connect", signal_name, callable)
	ur.commit_action()
	return _EC.ok()


# ---- batch actions ----

func _create_batch(params: Dictionary) -> Dictionary:
	var nodes: Array = params.get("nodes", [])
	if nodes.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "nodes[] required (array of {type, name, parent_path, properties?})")
	var scene := _get_scene_root()
	if not scene:
		return _EC.fail("SCENE_NOT_LOADED", "No scene open")
	var ur := EditorInterface.get_editor_undo_redo()
	ur.create_action("Batch create %d nodes" % nodes.size())
	var created := []
	var partial := false
	var first_error := ""
	for entry in nodes:
		var type_name: String = entry.get("type", "")
		var name: String = entry.get("name", "")
		var parent_path: String = entry.get("parent_path", "")
		var properties: Dictionary = entry.get("properties", {})
		if type_name.is_empty() or name.is_empty() or parent_path.is_empty():
			first_error = "Missing type/name/parent_path in node entry"
			partial = true
			break
		if not ClassDB.class_exists(type_name):
			first_error = "Unknown class: %s" % type_name
			partial = true
			break
		var parent := _SP.resolve(parent_path, scene)
		if not parent:
			first_error = "Parent not found: %s" % parent_path
			partial = true
			break
		var node: Node = ClassDB.instantiate(type_name)
		node.name = name
		ur.add_do_method(parent, "add_child", node)
		ur.add_do_method(node, "set_owner", scene)
		for prop_name in properties:
			var decoded := _VC.decode_variant(properties[prop_name])
			ur.add_do_property(node, prop_name, decoded)
		ur.add_undo_method(parent, "remove_child", node)
		ur.add_undo_reference(node)
		created.append({"name": name, "type": type_name})
	if partial:
		ur.commit_action()
		return _EC.fail("PARTIAL", "Batch stopped at %d/%d: %s" % [created.size(), nodes.size(), first_error])
	ur.commit_action()
	return _EC.ok({"created": created, "count": created.size()})
