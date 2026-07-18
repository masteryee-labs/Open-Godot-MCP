extends RefCounted

## Profiler handler — godot_profiler (performance monitoring).
## Docs: 02-Tools/Diagnostics.md §godot_profiler
##
## All metrics are collected in the game process — Engine.get_frames_per_second
## and Performance.get_monitor reflect whichever process calls them, so
## routing through the debugger channel is the only way to get game-side
## numbers from the editor.

const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")

var _bridge: Node


func handle(tool: String, action: String, params: Dictionary) -> Dictionary:
	match action:
		"snapshot":
			return await _call_runtime("snapshot", {})
		"series":
			return await _call_runtime("series", params)
		"spikes":
			return await _call_runtime("spikes", params)
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown action: %s" % action)


func _call_runtime(action: String, params: Dictionary) -> Dictionary:
	if _bridge == null:
		return _EC.fail("INTERNAL_ERROR", "Bridge not set")
	var dbg: EditorDebuggerPlugin = _bridge.get_debugger()
	if dbg == null:
		return _EC.fail("RUNTIME_NOT_CONNECTED", "Debugger plugin not available")
	var call_params := {"action": action}
	call_params.merge(params, true)
	return await dbg.call_runtime("profiler", call_params)
