extends RefCounted

## Exec handler — godot_exec (GDScript injection into running game).
## Docs: 02-Tools/Runtime-State.md §godot_exec
##
## Routes to the game-side runtime autoload via the debugger channel.

const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")

var _bridge: Node


func handle(tool: String, action: String, params: Dictionary) -> Dictionary:
	# Security check: eval may be disabled
	var allow_eval: bool = true
	var es := EditorInterface.get_editor_settings()
	if es:
		var ae = es.get_setting("open_godot_mcp/security/allow_eval")
		if ae != null:
			allow_eval = bool(ae)
	if action == "eval" and not allow_eval:
		return _EC.fail("PERMISSION_DENIED", "eval is disabled in EditorSettings")
	if _bridge == null:
		return _EC.fail("INTERNAL_ERROR", "Bridge not set")
	var dbg: EditorDebuggerPlugin = _bridge.get_debugger()
	if dbg == null:
		return _EC.fail("RUNTIME_NOT_CONNECTED", "Debugger plugin not available")
	var call_params := {"action": action}
	call_params.merge(params, true)
	return await dbg.call_runtime("exec", call_params)
