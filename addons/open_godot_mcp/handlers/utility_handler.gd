extends RefCounted

## Utility handler — godot_health (connection health check).
## Docs: 02-Tools/Utility.md §godot_health

const _PortResolver = preload("res://addons/open_godot_mcp/utils/port_resolver.gd")
const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")

var _bridge: Node


func handle(tool: String, action: String, params: Dictionary) -> Dictionary:
	match action:
		"check":
			return _check()
		"diagnostics":
			return _diagnostics()
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown action: %s" % action)


func _check() -> Dictionary:
	var bridge_connected: bool = _bridge != null and not (_bridge._clients as Array).is_empty()
	# The runtime autoload lives in the game process, not the editor —
	# has_node("/root/McpRuntimeAutoload") is always false here. The
	# debugger plugin tracks the game-side hello beacon; ask it.
	var runtime_connected := false
	if _bridge:
		var dbg: EditorDebuggerPlugin = _bridge.get_debugger()
		if dbg and dbg.has_method("is_game_ready"):
			runtime_connected = dbg.is_game_ready()
	var latency := 0.0
	return _EC.ok({
		"bridge_connected": bridge_connected,
		"runtime_connected": runtime_connected,
		"server_version": "0.1.0",
		"addon_version": "0.1.0",
		"latency_ms": latency,
	})


func _diagnostics() -> Dictionary:
	var port: int = _bridge.port if _bridge else _PortResolver.DEFAULT_BRIDGE_PORT
	var conflicts := []
	# Check Windows reserved ports
	for range in _PortResolver.get_windows_excluded_ports():
		if port >= range[0] and port <= range[1]:
			conflicts.append("%d-%d" % [range[0], range[1]])
	var warnings := []
	if _PortResolver.is_port_excluded_by_windows(port):
		warnings.append("Port %d is in a Windows reserved range" % port)
	return _EC.ok({
		"port": port,
		"conflicts": conflicts,
		"warnings": warnings,
	})
