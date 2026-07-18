extends RefCounted

## Runtime state handler — godot_runtime_state (observe running game).
## Docs: 02-Tools/Runtime-State.md
##
## Routes to the game-side runtime autoload via the debugger channel.
## The editor cannot directly access the game's SceneTree; it must go
## through EditorDebuggerSession.send_message → EngineDebugger capture.

const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")

var _bridge: Node


func handle(tool: String, action: String, params: Dictionary) -> Dictionary:
	if _bridge == null:
		return _EC.fail("INTERNAL_ERROR", "Bridge not set")
	var dbg: EditorDebuggerPlugin = _bridge.get_debugger()
	if dbg == null:
		return _EC.fail("RUNTIME_NOT_CONNECTED", "Debugger plugin not available")
	# Route to game runtime: method "state", with action + params
	var call_params := {"action": action}
	call_params.merge(params, true)
	return await dbg.call_runtime("state", call_params)
