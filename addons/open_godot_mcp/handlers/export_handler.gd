extends RefCounted

## Export handler — godot_export (game export).
## Docs: 02-Tools/Utility.md §godot_export

const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")

var _bridge: Node


func handle(tool: String, action: String, params: Dictionary) -> Dictionary:
	match action:
		"presets":
			return _presets()
		"add_preset":
			return _add_preset(params)
		"export":
			return _EC.fail("INVALID_ARGUMENT", "export is handled by the MCP server (spawns headless Godot CLI)")
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown action: %s" % action)


func _presets() -> Dictionary:
	var config := ConfigFile.new()
	config.load("res://export_presets.cfg")
	var presets := []
	if config.has_section("presets"):
		var count := config.get_value("presets", "count", 0) as int
		for i in count:
			var prefix := "preset.%d" % i
			if config.has_section(prefix):
				var name := config.get_value(prefix, "name", "")
				var platform := config.get_value(prefix, "platform", "")
				var path := config.get_value(prefix, "export_path", "")
				presets.append({"name": name, "platform": platform, "path": path if not path.is_empty() else null})
	return _EC.ok({"presets": presets})


func _add_preset(params: Dictionary) -> Dictionary:
	var name: String = params.get("name", "")
	var platform: String = params.get("platform", "")
	var settings: Dictionary = params.get("settings", {})
	if name.is_empty() or platform.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "name and platform required")
	var config := ConfigFile.new()
	config.load("res://export_presets.cfg")
	var count := config.get_value("presets", "count", 0) as int
	var prefix := "preset.%d" % count
	config.set_value(prefix, "name", name)
	config.set_value(prefix, "platform", platform)
	for key in settings:
		config.set_value(prefix, key, settings[key])
	config.set_value("presets", "count", count + 1)
	config.save("res://export_presets.cfg")
	return _EC.ok()
