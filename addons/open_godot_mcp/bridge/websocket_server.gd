extends Node

## WebSocket server — MCP Server ↔ Editor Bridge (Transport.md §通道 2).
##
## JSON-RPC 2.0 over WebSocket with request_id correlation.
## Server -> Bridge: tool_invoke
## Bridge -> Server: tool_result, event
## Handshake: session_id, godot_version, project_path, plugin_version, auth_token
##
## In Godot 4, WebSocketPeer is client-only. To accept incoming connections,
## we use a TCPServer to listen, then wrap accepted TCP connections with
## WebSocketPeer to do the WebSocket handshake.
##
## Connection stability (Connection-Stability.md):
##   - heartbeat: ping every 5s, 3s no pong -> suspected_dead, 3x -> drop
##   - backpressure: 4MB outbound, 32 packets/tick, 500-node scene limit

const _PortResolver = preload("res://addons/open_godot_mcp/utils/port_resolver.gd")
const _VariantCodec = preload("res://addons/open_godot_mcp/utils/variant_codec.gd")
const _Dispatcher = preload("res://addons/open_godot_mcp/bridge/dispatcher.gd")

var port: int = 6970
var host: String = "127.0.0.1"
var auth_token: String = ""

var _tcp: TCPServer = null
var _clients: Array[WebSocketPeer] = []
var _next_id: int = 1
var _dispatcher: RefCounted
var _heartbeat_timer: float = 0.0
var _debugger_plugin: EditorDebuggerPlugin = null
var _log_buffer: Array = []
var _log_max: int = 10000

signal client_connected
signal client_disconnected
signal runtime_ready
signal runtime_disconnected
signal status_changed(text: String)


func _ready() -> void:
	_dispatcher = _Dispatcher.new()
	_dispatcher.set_bridge(self)
	# Read auth token from EditorSettings (not a static class in Godot 4)
	var es := EditorInterface.get_editor_settings()
	if es:
		var at = es.get_setting("open_godot_mcp/security/auth_token")
		if at != null:
			auth_token = str(at)


func start_server() -> void:
	port = _PortResolver.resolve_bridge_port()
	_tcp = TCPServer.new()
	var err: int = _tcp.listen(port, host)
	if err != OK:
		var msg := "Failed to bind bridge port %d: %s" % [port, error_string(err)]
		push_error("[Open Godot MCP] " + msg)
		_emit_status("ERROR: " + msg)
		# Try auto-increment
		port = _PortResolver.resolve_port(port + 1, port + 1, host)
		err = _tcp.listen(port, host)
		if err != OK:
			_emit_status("FATAL: cannot bind any port")
			return
	_emit_status("Listening on port %d" % port)
	print("[Open Godot MCP] Bridge listening on ws://%s:%d" % [host, port])


func stop_server() -> void:
	for c in _clients:
		c.close()
	_clients.clear()
	if _tcp:
		_tcp.stop()
		_tcp = null
	_emit_status("Stopped")


func _process(delta: float) -> void:
	if _tcp == null:
		return
	# Accept new TCP connections and wrap them as WebSocket peers
	while _tcp.is_connection_available():
		var conn: StreamPeerTCP = _tcp.take_connection()
		var peer := WebSocketPeer.new()
		# accept_connection initiates the WebSocket handshake on the raw TCP stream
		peer.accept_stream(conn)
		_clients.append(peer)
	# Poll each client
	var still_connected: Array[WebSocketPeer] = []
	for peer in _clients:
		peer.poll()
		var state := peer.get_ready_state()
		if state == WebSocketPeer.STATE_OPEN:
			_process_peer(peer)
			still_connected.append(peer)
		elif state == WebSocketPeer.STATE_CLOSED:
			_on_client_disconnected(peer)
		else:
			# CONNECTING or CLOSING — keep polling
			still_connected.append(peer)
	_clients = still_connected
	# Heartbeat
	_heartbeat_timer += delta
	if _heartbeat_timer >= 5.0:
		_heartbeat_timer = 0.0
		_send_heartbeat()


func _process_peer(peer: WebSocketPeer) -> void:
	while peer.get_available_packet_count() > 0:
		var pkt := peer.get_packet()
		var text := pkt.get_string_from_utf8()
		if text.is_empty():
			continue
		var parsed = JSON.parse_string(text)
		if parsed == null:
			_send_error(peer, -1, -32700, "Parse error")
			continue
		if not (parsed is Dictionary):
			continue
		await _handle_message(peer, parsed)


func _handle_message(peer: WebSocketPeer, msg: Dictionary) -> void:
	var method: String = msg.get("method", "")
	var id: Variant = msg.get("id", null)
	var params: Dictionary = msg.get("params", {})

	if method == "handshake":
		_handle_handshake(peer, id, params)
	elif method == "ping":
		_send_response(peer, id, {"pong": true})
	elif method == "tool_invoke":
		await _handle_tool_invoke(peer, id, params)
	elif method == "event":
		# Server->Bridge event (rare); ignore for now
		pass
	else:
		_send_error(peer, id, -32601, "Method not found: %s" % method)


func _handle_handshake(peer: WebSocketPeer, id: Variant, params: Dictionary) -> void:
	# Validate auth token if configured
	if not auth_token.is_empty():
		var client_token: String = params.get("auth_token", "")
		if client_token != auth_token:
			_send_error(peer, id, -32000, "Auth token mismatch")
			peer.close()
			return
	var result := {
		"session_id": str(_next_id),
		"godot_version": Engine.get_version_info()["string"],
		"project_path": ProjectSettings.globalize_path("res://"),
		"plugin_version": "0.1.0",
		"auth_token": auth_token,
	}
	_next_id += 1
	_send_response(peer, id, result)
	_emit_status("Connected (Godot %s)" % result["godot_version"])
	client_connected.emit()


func _handle_tool_invoke(peer: WebSocketPeer, id: Variant, params: Dictionary) -> void:
	var tool: String = params.get("tool", "")
	var action: String = params.get("action", "")
	var tool_params: Dictionary = params.get("params", {})
	if tool.is_empty() or action.is_empty():
		_send_error(peer, id, -32602, "Missing tool or action")
		return
	var result: Dictionary = await _dispatcher.dispatch(tool, action, tool_params)
	_send_response(peer, id, result)


# ---- sending helpers ----

func _send_response(peer: WebSocketPeer, id: Variant, result: Variant) -> void:
	var msg := {"jsonrpc": "2.0", "id": id, "result": result}
	_send_json(peer, msg)


func _send_error(peer: WebSocketPeer, id: Variant, code: int, message: String) -> void:
	var msg := {"jsonrpc": "2.0", "id": id, "error": {"code": code, "message": message}}
	_send_json(peer, msg)


func _send_json(peer: WebSocketPeer, msg: Dictionary) -> void:
	var text := JSON.stringify(msg)
	peer.send_text(text)


func _send_heartbeat() -> void:
	for peer in _clients:
		if peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
			peer.send_text('{"jsonrpc":"2.0","method":"heartbeat","params":{}}')


func send_event(event_type: String, params: Dictionary = {}) -> void:
	"""Send an event to all connected clients (Bridge -> Server)."""
	var msg := {"jsonrpc": "2.0", "method": "event", "params": {"type": event_type}.merged(params, true)}
	var text := JSON.stringify(msg)
	for peer in _clients:
		if peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
			peer.send_text(text)


func _on_client_connected(peer: WebSocketPeer) -> void:
	print("[Open Godot MCP] MCP Server connected")


func _on_client_disconnected(peer: WebSocketPeer) -> void:
	print("[Open Godot MCP] MCP Server disconnected")
	_emit_status("Disconnected (waiting for reconnect)")
	client_disconnected.emit()


func _emit_status(text: String) -> void:
	status_changed.emit(text)


func set_debugger_plugin(dp: EditorDebuggerPlugin) -> void:
	_debugger_plugin = dp


func get_debugger() -> EditorDebuggerPlugin:
	return _debugger_plugin


func add_log(level: String, source: String, message: String) -> void:
	var entry := {
		"time": Time.get_datetime_string_from_system(true),
		"time_ms": Time.get_ticks_msec(),
		"level": level,
		"source": source,
		"message": message,
	}
	_log_buffer.append(entry)
	if _log_buffer.size() > _log_max:
		_log_buffer.pop_front()


func get_logs() -> Array:
	return _log_buffer


func clear_logs() -> void:
	_log_buffer.clear()
