extends RefCounted

## Network handler — godot_network (multiplayer game testing).
## Docs: 02-Tools/Network.md
##
## Instance management (launch_instance/list_instances/switch/terminate/sync_state)
## is handled by the Python MCP server's GameInstanceManager — those actions
## never reach this bridge handler. This handler only routes runtime actions
## (simulate_peer/network_condition/rpc_call) through the debugger channel to
## the game-side runtime autoload, for the PIE (Play-in-Editor) game.

const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")

var _bridge: Node


func handle(tool: String, action: String, params: Dictionary) -> Dictionary:
	match action:
		"simulate_peer":
			return await _call_runtime("simulate_peer", params)
		"network_condition":
			return await _call_runtime("network_condition", params)
		"rpc_call":
			return await _call_runtime("rpc_call", params)
		"launch_instance", "list_instances", "switch", "terminate", "sync_state":
			return _EC.fail("INVALID_ARGUMENT", "%s is handled by the MCP server (GameInstanceManager)" % action)
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
	return await dbg.call_runtime("network", call_params)
