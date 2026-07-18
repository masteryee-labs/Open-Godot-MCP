@tool
extends EditorExportPlugin

## MCP Export Plugin — strips the runtime autoload and MCP-only files
## from exported builds.
## Docs: 01-Architecture/Runtime-Autoload.md §匯出
##
## The runtime autoload exists solely to service editor-driven debugger
## calls. An exported game has no debugger channel, so the autoload
## would just add dead weight (and print a misleading "debugger=false"
## line at boot). Strip it from the PCK.
##
## Godot's export pipeline doesn't give us a "remove this autoload"
## hook directly; the supported mechanism is _export_customize_scene /
## _export_customize_resource + skipping files via _export_begin. We
## can't fully prevent the autoload script from being packed if some
## other resource references it, but we CAN clear the autoload
## ProjectSettings entry from the exported project.godot by writing a
## stripped copy during _export_begin.

const _RUNTIME_AUTOLOAD_NAME := "McpRuntimeAutoload"
const _RUNTIME_AUTOLOAD_PATH := "res://addons/open_godot_mcp/runtime/runtime_autoload.gd"


func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
	var strip: bool = true
	var es := EditorInterface.get_editor_settings()
	if es:
		var v = es.get_setting("open_godot_mcp/runtime/strip_on_export")
		if v != null:
			strip = bool(v)
	if not strip:
		return
	# Clear the autoload entry in the in-memory ProjectSettings so the
	# exporter writes a project.godot without it. The exporter snapshots
	# ProjectSettings during _export_begin to produce the exported
	# project.godot. We restore the entry after the export finishes via
	# _export_end (called on the same plugin instance).
	if ProjectSettings.has_setting("autoload/" + _RUNTIME_AUTOLOAD_NAME):
		# Stash the current value so _export_end can restore it.
		_stashed_value = ProjectSettings.get_setting("autoload/" + _RUNTIME_AUTOLOAD_NAME, "")
		ProjectSettings.clear("autoload/" + _RUNTIME_AUTOLOAD_NAME)


var _stashed_value: String = ""


func _export_end() -> void:
	# Restore the autoload entry in the editor's in-memory ProjectSettings
	# so the editor itself still has the autoload for the next play.
	if not _stashed_value.is_empty():
		ProjectSettings.set_setting("autoload/" + _RUNTIME_AUTOLOAD_NAME, _stashed_value)
		ProjectSettings.set_as_basic("autoload/" + _RUNTIME_AUTOLOAD_NAME, true)
		_stashed_value = ""


func _export_customize_resource(resource: Resource, path: String) -> Resource:
	# Drop the runtime autoload script itself if the exporter tries to
	# pack it (e.g. because project.godot still referenced it before our
	# _export_begin cleared the entry).
	if path == _RUNTIME_AUTOLOAD_PATH:
		return null
	return resource


func _export_customize_scene(scene: Node, path: String) -> Node:
	# The autoload is a singleton, not a scene node — nothing to strip here.
	# Kept for completeness with the export plugin contract.
	return scene


func _get_name() -> String:
	return "Open Godot MCP Export Strip"
