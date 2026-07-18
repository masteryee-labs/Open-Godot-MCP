## Port resolver — find free ports, avoid Windows reserved ranges.
##
## Implements Docs/01-Architecture/Connection-Stability.md §可配置 port + §Windows Port Reservation.
## Priority: env var > EditorSettings > auto-avoidance > default.

class_name PortResolver

const DEFAULT_BRIDGE_PORT := 6970
const DEFAULT_DAP_PORT := 6006
const DEFAULT_LSP_PORT := 6005
const DEFAULT_GAME_PORT := 7070


static func get_env_port(env_var: String, default_port: int) -> int:
	var raw := OS.get_environment(env_var)
	if raw.is_empty():
		return default_port
	var p := raw.to_int()
	if p < 1 or p > 65535:
		push_warning("Invalid port in %s=%s, using default %d" % [env_var, raw, default_port])
		return default_port
	return p


static func is_port_free(port: int, host: String = "127.0.0.1") -> bool:
	var sock := TCPServer.new()
	var err := sock.listen(port, host)
	var free := (err == OK)
	sock.stop()
	return free


static func get_windows_excluded_ports() -> Array:
	## Returns Array of [start, end] port ranges excluded on Windows.
	if OS.get_name() != "Windows":
		return []
	var output: Array = []
	var exit := OS.execute("netsh", ["interface", "ipv4", "show", "excludedportrange", "protocol=tcp"], output, true)
	if exit != OK:
		return []
	var ranges: Array = []
	if output.is_empty():
		return []
	var text: String = output[0]
	var in_data := false
	for line in text.split("\n"):
		var stripped := line.strip_edges()
		if stripped.is_empty():
			continue
		if stripped.begins_with("---"):
			in_data = true
			continue
		if not in_data:
			if stripped.find("Start") >= 0 and stripped.find("End") >= 0:
				in_data = true
			continue
		var parts := stripped.split(" ", false)
		if parts.size() >= 2:
			var start := parts[0].to_int()
			var end := parts[1].to_int()
			if start > 0 and end > 0:
				ranges.append([start, end])
	return ranges


static func is_port_excluded_by_windows(port: int) -> bool:
	for range in get_windows_excluded_ports():
		if port >= range[0] and port <= range[1]:
			return true
	return false


static func resolve_port(preferred: int, default_port: int, host: String = "127.0.0.1") -> int:
	## Resolve a single port: try preferred, then default, then increment.
	var excluded := get_windows_excluded_ports() if OS.get_name() == "Windows" else []

	var _is_ok := func(p: int) -> bool:
		if p < 1 or p > 65535:
			return false
		for range in excluded:
			if p >= range[0] and p <= range[1]:
				return false
		return is_port_free(p, host)

	# Try preferred then default
	for p in [preferred, default_port]:
		if _is_ok.call(p):
			return p

	# Increment from default
	var p := default_port + 1
	while p <= 65535:
		if _is_ok.call(p):
			return p
		p += 1
	# Wrap around
	p = 1024
	while p < default_port:
		if _is_ok.call(p):
			return p
		p += 1
	push_error("No free port found near %d" % default_port)
	return default_port


static func resolve_bridge_port() -> int:
	var env_p := get_env_port("OPEN_GODOT_MCP_PORT", -1)
	var settings_p: int = DEFAULT_BRIDGE_PORT
	var auto_p: bool = true
	# EditorSettings is not a static class — access via EditorInterface singleton
	var es := EditorInterface.get_editor_settings()
	if es:
		var sp = es.get_setting("open_godot_mcp/bridge/port")
		if sp != null:
			settings_p = int(sp)
		var ap = es.get_setting("open_godot_mcp/bridge/auto_port")
		if ap != null:
			auto_p = bool(ap)
	var preferred := env_p if env_p > 0 else settings_p
	if auto_p:
		return resolve_port(preferred, DEFAULT_BRIDGE_PORT)
	return preferred
