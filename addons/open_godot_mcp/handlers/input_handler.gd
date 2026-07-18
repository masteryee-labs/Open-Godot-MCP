extends RefCounted

## Input handler — godot_input (inject input into running game).
## Docs: 02-Tools/Input.md
##
## Routes to the game-side runtime autoload via the debugger channel.

const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")

var _bridge: Node


func handle(tool: String, action: String, params: Dictionary) -> Dictionary:
	if _bridge == null:
		return _EC.fail("INTERNAL_ERROR", "Bridge not set")
	var dbg: EditorDebuggerPlugin = _bridge.get_debugger()
	if dbg == null:
		return _EC.fail("RUNTIME_NOT_CONNECTED", "Debugger plugin not available")
	# Use "input_type" to avoid collision with InputMap action name in params["action"]
	var call_params := {"input_type": action}
	call_params.merge(params, true)
	return await dbg.call_runtime("input", call_params)
