extends RefCounted

## Resource handler — godot_resource (read-only, type-aware).
## Docs: 02-Tools/Resource.md §godot_resource

const _VC = preload("res://addons/open_godot_mcp/utils/variant_codec.gd")
const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")

var _bridge: Node


func handle(tool: String, action: String, params: Dictionary) -> Dictionary:
	match action:
		"inspect":
			return _inspect(params)
		"list":
			return _list(params)
		"find":
			return _find(params)
		"info":
			return _info(params)
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown action: %s" % action)


func _inspect(params: Dictionary) -> Dictionary:
	var path: String = params.get("path", "")
	if path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "path required")
	if not ResourceLoader.exists(path):
		return _EC.fail("RESOURCE_NOT_FOUND", "Resource not found: %s" % path)
	var res := load(path)
	if not res:
		return _EC.fail("RESOURCE_NOT_FOUND", "Failed to load: %s" % path)
	var type := res.get_class()
	var props := {}
	match type:
		"SpriteFrames":
			var sf := res as SpriteFrames
			var anims := sf.get_animation_names()
			var frame_counts := {}
			var anim_list := []
			for a in anims:
				anim_list.append(a)
				frame_counts[a] = sf.get_frame_count(a)
			props = {"animations": anim_list, "frame_counts": frame_counts}
		"TileSet":
			var ts := res as TileSet
			var tiles := []
			for i in ts.get_source_count():
				var sid := ts.get_source_id(i)
				tiles.append({"source_id": sid})
			props = {"tiles": tiles}
		_:
			for p in res.get_property_list():
				var n: String = p["name"]
				if not n.begins_with("_") and n not in ["resource_path", "resource_name", "script", "_meta"]:
					props[n] = _VC.encode_variant(res.get(n))
	return _EC.ok({"type": type, "properties": props})


func _list(params: Dictionary) -> Dictionary:
	var dir: String = params.get("dir", "res://")
	var type_filter: String = params.get("type_filter", "")
	if dir.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "dir required")
	var resources := []
	_list_dir_recursive(dir, type_filter, resources)
	return _EC.ok({"resources": resources})


func _list_dir_recursive(dir_path: String, type_filter: String, out: Array) -> void:
	var d := DirAccess.open(dir_path)
	if not d:
		return
	d.list_dir_begin()
	var file := d.get_next()
	while not file.is_empty():
		if file == "." or file == "..":
			file = d.get_next()
			continue
		var full := dir_path.trim_suffix("/") + "/" + file
		if d.current_is_dir():
			if not file.begins_with("."):
				_list_dir_recursive(full, type_filter, out)
		else:
			var res_path := full
			if ResourceLoader.exists(res_path):
				var res := load(res_path)
				if res:
					var type := res.get_class()
					if type_filter.is_empty() or type == type_filter or ClassDB.is_parent_class(type, type_filter):
						out.append({"path": res_path, "type": type, "name": file})
		file = d.get_next()
	d.list_dir_end()


func _find(params: Dictionary) -> Dictionary:
	var type_name: String = params.get("type", "")
	var glob: String = params.get("glob", "")
	if type_name.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "type required")
	var resources := []
	_find_recursive("res://", type_name, glob, resources)
	return _EC.ok({"resources": resources})


func _find_recursive(dir_path: String, type_name: String, glob: String, out: Array) -> void:
	var d := DirAccess.open(dir_path)
	if not d:
		return
	d.list_dir_begin()
	var file := d.get_next()
	while not file.is_empty():
		if file == "." or file == "..":
			file = d.get_next()
			continue
		var full := dir_path.trim_suffix("/") + "/" + file
		if d.current_is_dir():
			if not file.begins_with("."):
				_find_recursive(full, type_name, glob, out)
		else:
			if not glob.is_empty() and not _simple_glob_match(glob, file):
				file = d.get_next()
				continue
			if ResourceLoader.exists(full):
				var res := load(full)
				if res:
					var cls := res.get_class()
					if type_name.is_empty() or cls == type_name or ClassDB.is_parent_class(cls, type_name):
						out.append({"path": full, "type": cls, "name": file})
		file = d.get_next()
	d.list_dir_end()


func _simple_glob_match(pattern: String, text: String) -> bool:
	if pattern == "*":
		return true
	if pattern.begins_with("*."):
		return text.ends_with(pattern.substr(1))
	if pattern.begins_with("*"):
		return text.ends_with(pattern.substr(1))
	if pattern.ends_with("*"):
		return text.begins_with(pattern.left(pattern.length() - 1))
	return text == pattern


func _info(params: Dictionary) -> Dictionary:
	var path: String = params.get("path", "")
	if path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "path required")
	if not ResourceLoader.exists(path):
		return _EC.fail("RESOURCE_NOT_FOUND", "Resource not found: %s" % path)
	var res := load(path)
	var type := res.get_class() if res else "Unknown"
	var fs_path := ProjectSettings.globalize_path(path)
	var size := 0
	if FileAccess.file_exists(fs_path):
		var f := FileAccess.open(fs_path, FileAccess.READ)
		if f:
			size = f.get_length()
			f.close()
	var imported := FileAccess.file_exists(fs_path + ".import")
	return _EC.ok({"type": type, "size": size, "imported": imported, "path": path})
