extends RefCounted

## Filesystem/docs/log handler — godot_filesystem / godot_docs / godot_log.
## Docs: 02-Tools/Filesystem.md

const _VC = preload("res://addons/open_godot_mcp/utils/variant_codec.gd")
const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")

var _bridge: Node
var _log_buffer: Array = []  # ring buffer of log entries
var _log_max: int = 10000


func handle(tool: String, action: String, params: Dictionary) -> Dictionary:
	if tool == "godot_filesystem":
		return _handle_filesystem(action, params)
	elif tool == "godot_docs":
		return _handle_docs(action, params)
	elif tool == "godot_log":
		return _handle_log(action, params)
	return _EC.fail("INVALID_ARGUMENT", "Unknown tool: %s" % tool)


func _handle_filesystem(action: String, params: Dictionary) -> Dictionary:
	match action:
		"list":
			return _fs_list(params)
		"read":
			return _fs_read(params)
		"search":
			return _fs_search(params)
		"create":
			return _fs_create(params)
		"delete":
			return _fs_delete(params)
		"rename":
			return _fs_rename(params)
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown action: %s" % action)


func _fs_list(params: Dictionary) -> Dictionary:
	var path: String = params.get("path", "")
	var include_hidden: bool = params.get("include_hidden", false)
	if path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "path required")
	var fs_path := _resolve_path(path)
	var d := DirAccess.open(fs_path)
	if not d:
		return _EC.fail("INVALID_PATH", "Cannot open: %s" % fs_path)
	var entries := []
	d.list_dir_begin()
	var file := d.get_next()
	while not file.is_empty():
		if file == "." or file == "..":
			file = d.get_next()
			continue
		if not include_hidden and file.begins_with("."):
			file = d.get_next()
			continue
		var full := fs_path.trim_suffix("/") + "/" + file
		var type := "dir" if d.current_is_dir() else "file"
		var entry := {"name": file, "type": type}
		if type == "file":
			var f := FileAccess.open(full, FileAccess.READ)
			if f:
				entry["size"] = f.get_length()
				f.close()
		entries.append(entry)
		file = d.get_next()
	d.list_dir_end()
	return _EC.ok({"entries": entries})


func _fs_read(params: Dictionary) -> Dictionary:
	var path: String = params.get("path", "")
	var start_line: int = params.get("start_line", 1)
	var end_line: int = params.get("end_line", 0)
	var max_bytes: int = params.get("max_bytes", 0)
	if path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "path required")
	# Reject binary file types
	var ext := path.get_extension().to_lower()
	var binary_exts := ["png", "jpg", "jpeg", "webp", "bmp", "bin", "import", "mesh", "material", "meshlib", "scn", "res", "tres"]
	if ext in binary_exts:
		return _EC.fail("UNSUPPORTED_FILE_TYPE", "Binary files not supported by read. Use godot_resource info or godot_asset info for metadata. Extension: .%s" % ext)
	var fs_path := _resolve_path(path)
	if not FileAccess.file_exists(fs_path):
		return _EC.fail("NOT_FOUND", "File not found: %s" % fs_path)
	var f := FileAccess.open(fs_path, FileAccess.READ)
	if not f:
		return _EC.fail("INTERNAL_ERROR", "Cannot open: %s" % fs_path)
	var text := f.get_as_text()
	f.close()
	if max_bytes > 0 and text.length() > max_bytes:
		text = text.left(max_bytes)
	var lines := text.split("\n")
	var total := lines.size()
	var start: int = max(1, int(start_line)) - 1
	var endd: int = int(end_line) if end_line > 0 else total
	endd = min(endd, total)
	var content := "\n".join(lines.slice(start, endd))
	return _EC.ok({"content": content, "total_lines": total})


func _fs_search(params: Dictionary) -> Dictionary:
	var query: String = params.get("query", "")
	var glob: String = params.get("glob", "")
	var max_results: int = params.get("max_results", 50)
	if query.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "query required (Python re regex)")
	var matches := []
	var regex := RegEx.new()
	if regex.compile(query) != OK:
		return _EC.fail("INVALID_ARGUMENT", "Invalid regex: %s" % query)
	_search_recursive("res://", regex, glob, max_results, matches)
	return _EC.ok({"matches": matches})


func _search_recursive(dir_path: String, regex: RegEx, glob: String, max_results: int, out: Array) -> void:
	if out.size() >= max_results:
		return
	var d := DirAccess.open(dir_path)
	if not d:
		return
	d.list_dir_begin()
	var file := d.get_next()
	while not file.is_empty() and out.size() < max_results:
		if file == "." or file == "..":
			file = d.get_next()
			continue
		var full := dir_path.trim_suffix("/") + "/" + file
		if d.current_is_dir():
			if not file.begins_with("."):
				_search_recursive(full, regex, glob, max_results, out)
		else:
			if not glob.is_empty() and not _glob_match_simple(glob, file):
				file = d.get_next()
				continue
			var ext := file.get_extension().to_lower()
			if ext in ["png", "jpg", "jpeg", "webp", "bmp", "bin", "import", "mesh"]:
				file = d.get_next()
				continue
			var f := FileAccess.open(full, FileAccess.READ)
			if f:
				var text := f.get_as_text()
				f.close()
				var line_num := 0
				for line in text.split("\n"):
					line_num += 1
					if regex.search(line):
						out.append({"path": full, "line_number": line_num, "line": line, "match_text": regex.search(line).get_string()})
						if out.size() >= max_results:
							break
		file = d.get_next()
	d.list_dir_end()


func _glob_match_simple(pattern: String, text: String) -> bool:
	if pattern == "*":
		return true
	if pattern.begins_with("*."):
		return text.ends_with(pattern.substr(1))
	return text == pattern


func _fs_create(params: Dictionary) -> Dictionary:
	var path: String = params.get("path", "")
	var content: String = params.get("content", "")
	if path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "path required")
	var fs_path := _resolve_path(path)
	var f := FileAccess.open(fs_path, FileAccess.WRITE)
	if not f:
		return _EC.fail("INTERNAL_ERROR", "Cannot write: %s" % fs_path)
	f.store_string(content)
	f.close()
	return _EC.ok()


func _fs_delete(params: Dictionary) -> Dictionary:
	var path: String = params.get("path", "")
	var confirm: bool = params.get("confirm", false)
	if path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "path required")
	# Dangerous path check
	var is_dangerous := _is_dangerous_path(path)
	if is_dangerous and not confirm:
		return _EC.fail("PERMISSION_DENIED", "Dangerous path requires confirm=true. Path: %s" % path)
	var fs_path := _resolve_path(path)
	var d := DirAccess.open("res://")
	if DirAccess.dir_exists_absolute(fs_path):
		if d.remove(fs_path) != OK:
			return _EC.fail("INTERNAL_ERROR", "Failed to delete dir: %s" % fs_path)
	else:
		if d.remove(fs_path) != OK:
			return _EC.fail("INTERNAL_ERROR", "Failed to delete file: %s" % fs_path)
	return _EC.ok()


func _is_dangerous_path(path: String) -> bool:
	# res:// root, res://addons/, project.godot, anything with addons/
	if path == "res://" or path == "res://":
		return true
	if path == "res://project.godot":
		return true
	if path.begins_with("res://addons/") or path.contains("/addons/"):
		return true
	return false


func _fs_rename(params: Dictionary) -> Dictionary:
	var old_path: String = params.get("old_path", "")
	var new_path: String = params.get("new_path", "")
	if old_path.is_empty() or new_path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "old_path, new_path required")
	var old_fs := _resolve_path(old_path)
	var new_fs := _resolve_path(new_path)
	var d := DirAccess.open("res://")
	if d.rename(old_fs, new_fs) != OK:
		return _EC.fail("INTERNAL_ERROR", "Rename failed: %s -> %s" % [old_fs, new_fs])
	return _EC.ok()


func _resolve_path(p: String) -> String:
	if p.begins_with("res://"):
		return ProjectSettings.globalize_path(p)
	return p


# ---- godot_docs ----

func _handle_docs(action: String, params: Dictionary) -> Dictionary:
	match action:
		"fetch":
			return _docs_fetch(params)
		"search":
			return _docs_search(params)
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown action: %s" % action)


func _docs_fetch(params: Dictionary) -> Dictionary:
	var cls_name: String = params.get("class_name", "")
	var method: String = params.get("method", "")
	if cls_name.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "class_name required")
	# Build docs URL for the current Godot version
	var version := Engine.get_version_info()
	var major: int = int(version["major"])
	var minor: int = int(version["minor"])
	var url := "https://docs.godotengine.org/en/%d.%d/classes/class_%s.html" % [major, minor, cls_name.to_lower()]
	if not method.is_empty():
		url += "#" + method
	# Fetch is done on Python side typically; here we return the URL
	# For now, return the URL and let Python fetch
	return _EC.ok({"markdown": "(Fetch the URL on the Python side)", "url": url})


func _docs_search(params: Dictionary) -> Dictionary:
	var query: String = params.get("query", "")
	if query.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "query required")
	# Return a search URL; Python side can fetch
	var version := Engine.get_version_info()
	var url := "https://docs.godotengine.org/en/%d.%d/search.html?q=%s" % [version["major"], version["minor"], query.uri_encode()]
	return _EC.ok({"results": [{"title": "Search: %s" % query, "url": url, "snippet": "Search the Godot docs"}]})


# ---- godot_log ----

func _handle_log(action: String, params: Dictionary) -> Dictionary:
	match action:
		"get":
			return _log_get(params)
		"errors":
			return _log_errors(params)
		"clear":
			return _log_clear()
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown action: %s" % action)


func _get_log_buffer() -> Array:
	if _bridge and _bridge.has_method("get_logs"):
		return _bridge.get_logs()
	return _log_buffer


func _log_get(params: Dictionary) -> Dictionary:
	var source: String = params.get("source", "all")
	var level: String = params.get("level", "")
	var count: int = params.get("count", 100)
	var offset: int = params.get("offset", 0)
	var since_ms: int = params.get("since_ms", 0)
	var entries := _filter_logs(source, since_ms, level)
	var sliced := entries.slice(offset, offset + count)
	return _EC.ok({"entries": sliced})


func _log_errors(params: Dictionary) -> Dictionary:
	var max: int = params.get("max", 50)
	var include_warnings: bool = params.get("include_warnings", false)
	var entries := []
	for e in _get_log_buffer():
		var level: String = e.get("level", "")
		if level == "error" or (include_warnings and level == "warning"):
			entries.append(e)
			if entries.size() >= max:
				break
	return _EC.ok({"errors": entries})


func _log_clear() -> Dictionary:
	if _bridge and _bridge.has_method("clear_logs"):
		_bridge.clear_logs()
	else:
		_log_buffer.clear()
	return _EC.ok()


func _filter_logs(source: String, since_ms: int, level: String = "") -> Array:
	var out := []
	var now := Time.get_ticks_msec()
	for e in _get_log_buffer():
		var s: String = e.get("source", "")
		if source != "all" and s != source:
			continue
		if not level.is_empty() and e.get("level", "") != level:
			continue
		if since_ms > 0:
			var t: int = e.get("time_ms", 0)
			if now - t > since_ms:
				continue
		out.append(e)
	return out


func add_log(level: String, source: String, message: String) -> void:
	if _bridge and _bridge.has_method("add_log"):
		_bridge.add_log(level, source, message)
	else:
		var entry := {
			"time": Time.get_datetime_string_from_system(true),
			"time_ms": Time.get_ticks_msec(),
			"level": level,
			"source": source,
			"message": message,
		}
		_log_buffer.append(entry)
		if _log_buffer.size() > _log_max:
			_log_buffer.pop_front()
