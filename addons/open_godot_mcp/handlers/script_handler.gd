extends RefCounted

## Script handler — godot_script (GDScript file ops).
## Docs: 02-Tools/Script.md

const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")
const _SP = preload("res://addons/open_godot_mcp/utils/scene_path.gd")

var _bridge: Node


func handle(tool: String, action: String, params: Dictionary) -> Dictionary:
	match action:
		"read":
			return _read(params)
		"create":
			return _create(params)
		"edit":
			return _edit(params)
		"write":
			return _write(params)
		"validate":
			return _validate(params)
		"attach":
			return _attach(params)
		"detach":
			return _detach(params)
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown action: %s" % action)


func _read(params: Dictionary) -> Dictionary:
	var path: String = params.get("path", "")
	var start_line: int = params.get("start_line", 1)
	var end_line: int = params.get("end_line", 0)
	if path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "path required")
	var fs_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(fs_path):
		return _EC.fail("RESOURCE_NOT_FOUND", "Script not found: %s" % path)
	var f := FileAccess.open(fs_path, FileAccess.READ)
	if not f:
		return _EC.fail("INTERNAL_ERROR", "Cannot open: %s" % fs_path)
	var all_text := f.get_as_text()
	f.close()
	var lines := all_text.split("\n")
	var total := lines.size()
	var start: int = max(1, int(start_line)) - 1  # 1-based to 0-based
	var endd: int = int(end_line) if end_line > 0 else total
	endd = min(endd, total)
	var content := "\n".join(lines.slice(start, endd))
	return _EC.ok({"content": content, "total_lines": total})


func _create(params: Dictionary) -> Dictionary:
	var path: String = params.get("path", "")
	var extends_str: String = params.get("extends", "Node")
	var content: String = params.get("content", "")
	if path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "path required")
	if not path.ends_with(".gd"):
		return _EC.fail("INVALID_ARGUMENT", "path must end with .gd")
	var full := "extends %s\n\n%s" % [extends_str, content]
	var fs_path := ProjectSettings.globalize_path(path)
	var f := FileAccess.open(fs_path, FileAccess.WRITE)
	if not f:
		return _EC.fail("INTERNAL_ERROR", "Cannot write: %s" % fs_path)
	f.store_string(full)
	f.close()
	EditorInterface.get_resource_filesystem().scan()
	return _EC.ok()


func _edit(params: Dictionary) -> Dictionary:
	var path: String = params.get("path", "")
	var edits: Array = params.get("edits", [])
	if path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "path required")
	if edits.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "edits required (array of {old, new, context?})")
	var fs_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(fs_path):
		return _EC.fail("RESOURCE_NOT_FOUND", "Script not found: %s" % path)
	var f := FileAccess.open(fs_path, FileAccess.READ)
	var text := f.get_as_text()
	f.close()
	var changed_lines := []
	for edit in edits:
		var old_s: String = edit.get("old", "")
		var new_s: String = edit.get("new", "")
		var context: String = edit.get("context", "")
		if old_s.is_empty():
			changed_lines.append({"start": 0, "end": 0, "error": "empty old"})
			continue
		# Find occurrences
		var occurrences := []
		var search_pos := 0
		while true:
			var pos := text.find(old_s, search_pos)
			if pos < 0:
				break
			occurrences.append(pos)
			search_pos = pos + old_s.length()
		if occurrences.is_empty():
			return _EC.fail("NOT_FOUND", "old text not found in file", {"snippet": old_s.left(80)})
		if occurrences.size() > 1 and context.is_empty():
			var line_nums := []
			for occ in occurrences:
				line_nums.append(text.count("\n", 0, occ) + 1)
			return _EC.fail("AMBIGUOUS_MATCH", "old text appears %d times; add context or expand old" % occurrences.size(), {"matches": line_nums})
		# If context given, use it to disambiguate
		var use_pos: int = occurrences[0]
		if not context.is_empty():
			# Find occurrence whose surrounding text matches context
			for occ in occurrences:
				var around := text.substr(max(0, occ - context.length()), context.length() * 2 + old_s.length())
				if around.find(context) >= 0:
					use_pos = occ
					break
		var start_line := text.count("\n", 0, use_pos) + 1
		text = text.left(use_pos) + new_s + text.substr(use_pos + old_s.length())
		var end_line := text.count("\n", 0, use_pos + new_s.length()) + 1
		changed_lines.append({"start": start_line, "end": end_line})
	# Write back
	f = FileAccess.open(fs_path, FileAccess.WRITE)
	f.store_string(text)
	f.close()
	EditorInterface.get_resource_filesystem().scan()
	return _EC.ok({"changed_lines": changed_lines})


func _write(params: Dictionary) -> Dictionary:
	var path: String = params.get("path", "")
	var content: String = params.get("content", "")
	if path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "path required")
	var fs_path := ProjectSettings.globalize_path(path)
	var f := FileAccess.open(fs_path, FileAccess.WRITE)
	if not f:
		return _EC.fail("INTERNAL_ERROR", "Cannot write: %s" % fs_path)
	f.store_string(content)
	f.close()
	EditorInterface.get_resource_filesystem().scan()
	return _EC.ok()


func _validate(params: Dictionary) -> Dictionary:
	var path: String = params.get("path", "")
	if path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "path required")
	# Try to load the script — GDScript parser will report errors
	var script := load(path)
	if script == null:
		# Reload to force parse
		script = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if script == null:
		return _EC.ok({"errors": [{"line": 0, "column": 0, "message": "Failed to load script (syntax error)"}]})
	# If script loaded, check for errors
	var errors := []
	# GDScript.load() reports errors via push_error; we can't easily capture them here.
	# A more robust approach would use a headless script parse.
	# For now, if the script loads, it's valid.
	return _EC.ok({"errors": errors})


func _attach(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	var script_path: String = params.get("script_path", "")
	if node_path.is_empty() or script_path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "node_path, script_path required")
	var scene := EditorInterface.get_edited_scene_root()
	if not scene:
		return _EC.fail("SCENE_NOT_LOADED", "No scene open")
	var node := _SP.resolve(node_path, scene)
	if not node:
		return _EC.fail("NODE_NOT_FOUND", "Node not found: %s" % node_path)
	if not ResourceLoader.exists(script_path):
		return _EC.fail("RESOURCE_NOT_FOUND", "Script not found: %s" % script_path)
	var script := load(script_path)
	var ur := EditorInterface.get_editor_undo_redo()
	ur.create_action("Attach script to '%s'" % node.name)
	ur.add_do_method(node, "set_script", script)
	ur.add_undo_method(node, "set_script", node.get_script())
	ur.commit_action()
	return _EC.ok()


func _detach(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	if node_path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "node_path required")
	var scene := EditorInterface.get_edited_scene_root()
	if not scene:
		return _EC.fail("SCENE_NOT_LOADED", "No scene open")
	var node := _SP.resolve(node_path, scene)
	if not node:
		return _EC.fail("NODE_NOT_FOUND", "Node not found: %s" % node_path)
	var ur := EditorInterface.get_editor_undo_redo()
	ur.create_action("Detach script from '%s'" % node.name)
	ur.add_do_method(node, "set_script", null)
	ur.add_undo_method(node, "set_script", node.get_script())
	ur.commit_action()
	return _EC.ok()
