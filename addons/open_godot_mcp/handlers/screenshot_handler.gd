extends RefCounted

## Screenshot handler — godot_screenshot (save to disk, return path).
## Docs: 02-Tools/Screenshot.md
##
## Game captures route through the debugger channel to the runtime autoload.
## Editor captures are done locally (editor viewport is accessible here).

const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")
const _VC = preload("res://addons/open_godot_mcp/utils/variant_codec.gd")
const _Cleanup = preload("res://addons/open_godot_mcp/utils/screenshot_cleanup.gd")

var _bridge: Node
var _screenshot_dir: String = "user://mcp_screenshots"


func handle(tool: String, action: String, params: Dictionary) -> Dictionary:
	_ensure_screenshot_dir()
	match action:
		"game":
			return await _game(params)
		"editor":
			return _editor(params)
		"region":
			return await _region(params)
		"burst":
			return await _burst(params)
		"cleanup":
			return _cleanup(params)
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown action: %s" % action)


func _ensure_screenshot_dir() -> void:
	var d := DirAccess.open("user://")
	if d and not d.dir_exists("mcp_screenshots"):
		d.make_dir("mcp_screenshots")


func _game(params: Dictionary) -> Dictionary:
	var dbg: EditorDebuggerPlugin = _get_debugger()
	if dbg == null:
		return _EC.fail("RUNTIME_NOT_CONNECTED", "Game not running or debugger unavailable")
	return await dbg.call_runtime("screenshot", {"action": "game", "params": params})


func _editor(params: Dictionary) -> Dictionary:
	var viewport := params.get("viewport", "2d")
	var max_width: int = params.get("max_width", 0)
	var img := _capture_editor_viewport(viewport)
	if not img:
		return _EC.fail("INTERNAL_ERROR", "Failed to capture editor viewport")
	img = _resize_image(img, max_width)
	var path := _save_image(img, "editor", "png", 90)
	_auto_cleanup()
	return _EC.ok({"path": path, "size_bytes": _file_size(path), "dimensions": {"width": img.get_width(), "height": img.get_height()}})


func _region(params: Dictionary) -> Dictionary:
	var rect: Dictionary = params.get("rect", {})
	var source: String = params.get("source", "game")
	var max_width: int = params.get("max_width", 0)
	if rect.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "rect required {x,y,width,height}")
	if source == "game":
		var dbg: EditorDebuggerPlugin = _get_debugger()
		if dbg == null:
			return _EC.fail("RUNTIME_NOT_CONNECTED", "Game not running or debugger unavailable")
		var call_params := {"action": "region", "params": params}
		return await dbg.call_runtime("screenshot", call_params)
	else:
		var img := _capture_editor_viewport("2d")
		if not img:
			return _EC.fail("INTERNAL_ERROR", "Failed to capture")
		var x := int(rect.get("x", 0))
		var y := int(rect.get("y", 0))
		var w := int(rect.get("width", img.get_width()))
		var h := int(rect.get("height", img.get_height()))
		var region_img := img.get_region(Rect2i(x, y, w, h))
		region_img = _resize_image(region_img, max_width)
		var path := _save_image(region_img, "region", "png", 90)
		_auto_cleanup()
		return _EC.ok({"path": path, "size_bytes": _file_size(path), "dimensions": {"width": region_img.get_width(), "height": region_img.get_height()}})


func _burst(params: Dictionary) -> Dictionary:
	var dbg: EditorDebuggerPlugin = _get_debugger()
	if dbg == null:
		return _EC.fail("RUNTIME_NOT_CONNECTED", "Game not running or debugger unavailable")
	return await dbg.call_runtime("screenshot", {"action": "burst", "params": params})


func _cleanup(params: Dictionary) -> Dictionary:
	var max_count: int = int(params.get("max_count", -1))
	var max_age_hours: float = float(params.get("max_age_hours", -1.0))
	var abs_dir := ProjectSettings.globalize_path(_screenshot_dir)
	var r := _Cleanup.cleanup(abs_dir, max_count, max_age_hours)
	return _EC.ok(r)


func _auto_cleanup() -> void:
	var abs_dir := ProjectSettings.globalize_path(_screenshot_dir)
	_Cleanup.cleanup(abs_dir)


func _get_debugger() -> EditorDebuggerPlugin:
	if _bridge == null:
		return null
	var dbg: EditorDebuggerPlugin = _bridge.get_debugger()
	return dbg


func _capture_editor_viewport(viewport: String) -> Image:
	var vp := EditorInterface.get_editor_main_screen()
	if vp:
		var tex: ViewportTexture = vp.get_texture()
		if tex:
			return tex.get_image()
	var img := DisplayServer.screen_get_image(DisplayServer.SCREEN_PRIMARY)
	return img


func _resize_image(img: Image, max_width: int) -> Image:
	if max_width > 0 and img.get_width() > max_width:
		var ratio := float(max_width) / float(img.get_width())
		var new_h := int(img.get_height() * ratio)
		img.resize(max_width, new_h, Image.INTERPOLATE_LANCZOS)
	return img


func _save_image(img: Image, prefix: String, fmt: String, quality: int) -> String:
	var ts := Time.get_ticks_msec()
	var filename := "%s_%d.%s" % [prefix, ts, fmt]
	var path := _screenshot_dir + "/" + filename
	var abs_path := ProjectSettings.globalize_path(path)
	match fmt:
		"png":
			img.save_png(abs_path)
		"jpeg", "jpg":
			img.save_jpg(abs_path, quality)
		"webp":
			img.save_webp(abs_path, quality)
	return abs_path


func _file_size(path: String) -> int:
	var f := FileAccess.open(path, FileAccess.READ)
	if f:
		var s := f.get_length()
		f.close()
		return s
	return 0
