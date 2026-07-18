extends RefCounted

## Asset handler — godot_asset (asset generation & management).
## Docs: 02-Tools/Utility.md §godot_asset

const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")

var _bridge: Node


func handle(tool: String, action: String, params: Dictionary) -> Dictionary:
	match action:
		"generate_2d":
			return _generate_2d(params)
		"list":
			return _list(params)
		"info":
			return _info(params)
		"import":
			return _import(params)
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown action: %s" % action)


func _generate_2d(params: Dictionary) -> Dictionary:
	var svg: String = params.get("svg", "")
	var filename: String = params.get("filename", "")
	var save_path: String = params.get("save_path", "res://")
	var width: int = params.get("width", 0)
	var height: int = params.get("height", 0)
	if svg.is_empty() or filename.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "svg and filename required")
	if not filename.ends_with(".png"):
		filename += ".png"
	# Create image from SVG
	var img := Image.new()
	var err := img.load_svg_from_string(svg, 1.0 if width == 0 else float(width))
	if err != OK:
		return _EC.fail("INTERNAL_ERROR", "Failed to load SVG: %s" % error_string(err))
	if width > 0 and height > 0:
		img.resize(width, height, Image.INTERPOLATE_LANCZOS)
	# Save
	var full_path := save_path.trim_suffix("/") + "/" + filename
	var abs_path := ProjectSettings.globalize_path(full_path)
	# Ensure dir exists
	var dir := DirAccess.open(ProjectSettings.globalize_path(save_path))
	if not dir:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(save_path))
	err = img.save_png(abs_path)
	if err != OK:
		return _EC.fail("INTERNAL_ERROR", "Failed to save PNG: %s" % error_string(err))
	EditorInterface.get_resource_filesystem().scan()
	return _EC.ok({"path": full_path})


func _list(params: Dictionary) -> Dictionary:
	var dir: String = params.get("dir", "res://")
	var type_filter: String = params.get("type", "")
	var assets := []
	var d := DirAccess.open(dir)
	if not d:
		return _EC.fail("INVALID_PATH", "Cannot open: %s" % dir)
	d.list_dir_begin()
	var file := d.get_next()
	while not file.is_empty():
		if file == "." or file == "..":
			file = d.get_next()
			continue
		if not d.current_is_dir():
			var full := dir.trim_suffix("/") + "/" + file
			if ResourceLoader.exists(full):
				var res := load(full)
				if res:
					var type := res.get_class()
					if type_filter.is_empty() or type == type_filter or ClassDB.is_parent_class(type, type_filter):
						assets.append({"path": full, "type": type, "name": file})
		file = d.get_next()
	d.list_dir_end()
	return _EC.ok({"assets": assets})


func _info(params: Dictionary) -> Dictionary:
	var path: String = params.get("path", "")
	if path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "path required")
	if not ResourceLoader.exists(path):
		return _EC.fail("RESOURCE_NOT_FOUND", "Asset not found: %s" % path)
	var res := load(path)
	var type := res.get_class() if res else "Unknown"
	var fs_path := ProjectSettings.globalize_path(path)
	var size := 0
	if FileAccess.file_exists(fs_path):
		var f := FileAccess.open(fs_path, FileAccess.READ)
		if f:
			size = f.get_length()
			f.close()
	var result := {"type": type, "size": size}
	# Get dimensions for image types
	if res is Texture2D:
		var tex := res as Texture2D
		result["dimensions"] = {"width": tex.get_width(), "height": tex.get_height()}
	return _EC.ok(result)


func _import(params: Dictionary) -> Dictionary:
	var source_path: String = params.get("source_path", "")
	var dest_path: String = params.get("dest_path", "")
	if source_path.is_empty() or dest_path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "source_path and dest_path required")
	if not FileAccess.file_exists(source_path):
		return _EC.fail("NOT_FOUND", "Source file not found: %s" % source_path)
	var dest_fs := ProjectSettings.globalize_path(dest_path)
	# Ensure dir exists
	var dest_dir := dest_path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dest_dir))
	var err := DirAccess.copy_absolute(source_path, dest_fs)
	if err != OK:
		return _EC.fail("INTERNAL_ERROR", "Failed to copy: %s" % error_string(err))
	EditorInterface.get_resource_filesystem().scan()
	return _EC.ok()
