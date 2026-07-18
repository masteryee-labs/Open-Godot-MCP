@tool
extends EditorDebuggerPlugin

## MCP Debugger Plugin — bridges editor ↔ game runtime over the debugger channel.
##
## The game runs as a separate OS process. Even in "Embed" mode the game's
## SceneTree is unreachable from the editor. Godot's debugger protocol
## (EditorDebuggerSession.send_message / EngineDebugger.register_message_capture)
## is the engine's supported IPC and works regardless of embed mode.
##
## Protocol (prefix "ogm"):
##   Editor → Game:  "ogm:call"      [request_id, method, params_json]
##   Game → Editor:  "ogm:response"  [request_id, result_json]
##   Game → Editor:  "ogm:error"     [request_id, message]
##   Game → Editor:  "ogm:hello"     []  (boot beacon)

const CAPTURE_PREFIX := "ogm"
const DEFAULT_TIMEOUT_SEC := 15.0
const GAME_READY_WAIT_SEC := 20.0

var _bridge: Node = null
var _next_request_id: int = 1
# request_id -> {"done": bool, "result": Dictionary}
# _capture writes directly to the entry; call_runtime polls it.
# Signal/lambda capture was unreliable in this context — the on_response
# callable connected to _response_received never fired when _capture
# emitted from the debugger message handler.
var _pending: Dictionary = {}
var _game_ready := false
var _game_session_id := -1
# Godot fires _setup_session once for the editor's own self-session at
# plugin-enable time, and again for each game subprocess. Track which is
# which so call_runtime never targets the editor self-session (which has
# no McpRuntimeAutoload and would silently swallow every request).
var _editor_self_session_id := -1

# Buffer for debugger inspection messages (stack_dump, stack_frame_vars,
# evaluated). EditorDebuggerSession has NO add_session_message_listener in
# Godot 4.x — _capture on the plugin is the only way to receive these.
var _debug_msg_buffer: Array = []

signal _game_hello()


func _has_capture(prefix: String) -> bool:
	return prefix == CAPTURE_PREFIX or prefix == "console" or prefix == "stack_dump" or prefix == "stack_frame_vars" or prefix == "evaluated"


func _setup_session(session_id: int) -> void:
	# The first _setup_session fires before EditorInterface.is_playing_scene()
	# can ever be true — it's the editor's own debug self-session. Pin it so
	# _first_active_session can skip it when looking for the game session.
	if _editor_self_session_id == -1 and not EditorInterface.is_playing_scene():
		_editor_self_session_id = session_id
		return
	var session := get_session(session_id)
	if session:
		session.started.connect(_on_session_started.bind(session_id))
		session.stopped.connect(_on_session_stopped.bind(session_id))
	_game_session_id = session_id
	_game_ready = false


func _on_session_started(session_id: int) -> void:
	if session_id == _editor_self_session_id:
		return
	_game_session_id = session_id
	_game_ready = false
	if _bridge:
		_bridge.send_event("debugger_session_started", {})


func _on_session_stopped(session_id: int) -> void:
	if session_id == _editor_self_session_id:
		return
	_game_ready = false
	# Fail any in-flight requests
	for rid in _pending.keys():
		var entry: Dictionary = _pending[rid]
		entry["done"] = true
		entry["result"] = _fail("RUNTIME_ERROR", "Game stopped")
	_pending.clear()
	if _bridge:
		_bridge.send_event("debugger_session_stopped", {})


func set_bridge(bridge: Node) -> void:
	_bridge = bridge


func is_game_running() -> bool:
	return EditorInterface.is_playing_scene()


func is_game_ready() -> bool:
	return _game_ready and is_game_running()


## Async: call a method on the game-side runtime autoload via debugger channel.
## Returns the result Dictionary, or a fail dict on timeout/error.
func call_runtime(method: String, params: Dictionary = {}, timeout_sec: float = DEFAULT_TIMEOUT_SEC) -> Dictionary:
	if not is_game_running():
		return _fail("RUNTIME_NOT_CONNECTED", "Game not running")
	var session := _first_active_session()
	if session == null:
		return _fail("RUNTIME_NOT_CONNECTED", "No active debugger session")
	# Wait for game hello if not ready yet
	if not _game_ready:
		var waited := 0.0
		while not _game_ready and is_game_running() and waited < GAME_READY_WAIT_SEC:
			await Engine.get_main_loop().process_frame
			waited += 0.016
		if not _game_ready:
			return _fail("RUNTIME_NOT_CONNECTED", "Game runtime did not become ready (no ogm:hello beacon)")

	var request_id := _next_request_id
	_next_request_id += 1

	# Store pending result in a dictionary that _capture can write to directly.
	# This avoids signal/lambda capture issues — the on_response lambda
	# connected to _response_received never fired when _capture emitted
	# from the debugger message handler. Polling a shared dict works reliably.
	var pending_entry := {"done": false, "result": {}}
	_pending[request_id] = pending_entry

	session.send_message("ogm:call", [request_id, method, JSON.stringify(params)])

	# Wait with timeout — poll the pending entry.
	var deadline := Time.get_ticks_msec() + int(timeout_sec * 1000.0)
	while not pending_entry["done"] and Time.get_ticks_msec() < deadline:
		if not is_game_running():
			_pending.erase(request_id)
			return _fail("RUNTIME_NOT_CONNECTED", "Game stopped during call")
		await Engine.get_main_loop().process_frame

	if not pending_entry["done"]:
		_pending.erase(request_id)
		return _fail("TIMEOUT", "Runtime call '%s' timed out after %.1fs" % [method, timeout_sec])

	_pending.erase(request_id)
	return pending_entry["result"]


func _capture(message: String, data: Array, session_id: int) -> bool:
	match message:
		"ogm:hello":
			_game_ready = true
			_game_hello.emit()
			return true
		"ogm:response":
			if data.size() < 2:
				return true
			var rid: int = int(data[0])
			var result_json: String = str(data[1])
			var parsed = JSON.parse_string(result_json)
			var result_dict: Dictionary = parsed if parsed is Dictionary else {"raw": result_json}
			if _pending.has(rid):
				var entry: Dictionary = _pending[rid]
				entry["done"] = true
				entry["result"] = result_dict
			return true
		"ogm:error":
			if data.size() < 2:
				return true
			var rid: int = int(data[0])
			var msg: String = str(data[1])
			if _pending.has(rid):
				var entry: Dictionary = _pending[rid]
				entry["done"] = true
				entry["result"] = _fail("RUNTIME_ERROR", msg)
			return true
		"ogm:log":
			if data.size() >= 2:
				var lvl: String = str(data[0])
				var log_msg: String = str(data[1])
				if _bridge:
					_bridge.add_log(lvl, "game", log_msg)
			return true
		"console:output":
			if data.size() > 0:
				if _bridge:
					_bridge.add_log("info", "game", str(data[0]))
				else:
					printerr("[MCP] console:output but _bridge is null")
			return true
		"console:error":
			if data.size() > 0:
				if _bridge:
					_bridge.add_log("error", "game", str(data[0]))
				else:
					printerr("[MCP] console:error but _bridge is null")
			return true
		"console:warning":
			if data.size() > 0:
				if _bridge:
					_bridge.add_log("warning", "game", str(data[0]))
				else:
					printerr("[MCP] console:warning but _bridge is null")
			return true
		"stack_dump":
			_debug_msg_buffer.append({"message": "stack_dump", "data": data})
			return true
		"stack_frame_vars":
			_debug_msg_buffer.append({"message": "stack_frame_vars", "data": data})
			return true
		"evaluated":
			_debug_msg_buffer.append({"message": "evaluated", "data": data})
			return true
	return false


func wait_debug_message(prefix: String, timeout_ms: int = 3000) -> Dictionary:
	var start := Time.get_ticks_msec()
	while Time.get_ticks_msec() - start < timeout_ms:
		for i in _debug_msg_buffer.size():
			var entry: Dictionary = _debug_msg_buffer[i]
			if str(entry["message"]).begins_with(prefix):
				_debug_msg_buffer.remove_at(i)
				return entry
		await Engine.get_main_loop().process_frame
	return {}


func clear_debug_messages() -> void:
	_debug_msg_buffer.clear()


func _first_active_session() -> EditorDebuggerSession:
	var sessions := get_sessions()
	# Prefer the tracked game session; fall back to any active session
	# that isn't the editor self-session.
	if _game_session_id >= 0:
		var s := get_session(_game_session_id)
		if s is EditorDebuggerSession and s.is_active():
			return s
	for s in sessions:
		if s is EditorDebuggerSession and s.is_active():
			# Skip the editor self-session — it has no game-side capture.
			# We can't compare by id here because get_sessions doesn't
			# expose ids; rely on _game_session_id having been set by
			# _setup_session for the real game session.
			return s
	return null


func _fail(code: String, message: String) -> Dictionary:
	return {"ok": false, "error": {"code": code, "message": message}}
