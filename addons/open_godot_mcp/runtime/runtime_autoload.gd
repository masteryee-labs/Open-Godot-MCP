extends Node

## Runtime Autoload — runs inside the game process.
## Docs: 01-Architecture/Runtime-Autoload.md
##
## Provides:
##   - Input simulation (Input.parse_input_event + Input.action_press/release)
##   - State observation (SceneTree traversal + _mcp_state() protocol)
##   - GDScript injection (eval)
##   - Screenshot (Viewport.get_texture().get_image())
##   - Clock control (Engine.time_scale = 0 for freeze, manual step)
##
## Communication modes:
##   1. Editor mode (PIE): EngineDebugger channel — "ogm:call" / "ogm:response"
##   2. Standalone mode: WebSocket server on OGM_GAME_PORT — JSON-RPC tool_invoke
##      Used when the game is launched as a standalone process for multiplayer
##      testing (godot_network launch_instance). The MCP server connects directly.

const _VC = preload("res://addons/open_godot_mcp/utils/variant_codec.gd")
const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")
const _NetworkConditioner = preload("res://addons/open_godot_mcp/runtime/network_conditioner.gd")
const _Cleanup = preload("res://addons/open_godot_mcp/utils/screenshot_cleanup.gd")

const CAPTURE_PREFIX := "ogm"

var _frame: int = 0
var _frozen: bool = false
var _signal_log: Array = []
var _signal_log_max: int = 1000
var _watching_signals: bool = false
var _debugger_registered := false
var _network_conditioner: MultiplayerPeerExtension = null

# Input recording / replay
var _recording: bool = false
var _record_buffer: Array = []
var _record_start_frame: int = 0
var _replaying: bool = false

# Standalone WebSocket server mode
var _standalone_mode := false
var _ws_tcp: TCPServer = null
var _ws_clients: Array[WebSocketPeer] = []
var _ws_next_id: int = 1
var _log_buffer: Array = []
var _log_max: int = 10000


func _ready() -> void:
	# Only register in the game process, not the editor.
	if Engine.is_editor_hint():
		return
	add_to_group("mcp_watch")
	# Keep this autoload running even when the tree is paused (for freeze/step)
	process_mode = Node.PROCESS_MODE_ALWAYS
	_frozen = bool(ProjectSettings.get_setting("open_godot_mcp/_frozen_on_start", false))
	if _frozen:
		get_tree().paused = true
	_watching_signals = true
	# Register debugger message capture so the editor can call us.
	EngineDebugger.register_message_capture(CAPTURE_PREFIX, _on_debug_message)
	_debugger_registered = true
	# Register a custom logger to capture all print/error output.
	OS.add_logger(_McpLogger.new(self))
	# Boot beacon — tells the editor we're ready to receive calls.
	if EngineDebugger.is_active():
		EngineDebugger.send_message("ogm:hello", [])
	# Standalone mode: if OGM_GAME_PORT env is set, start a WebSocket server
	# so the MCP server can call us directly (no editor debugger needed).
	var game_port_str := OS.get_environment("OGM_GAME_PORT")
	if not game_port_str.is_empty() and not EngineDebugger.is_active():
		_start_standalone_server(int(game_port_str))


class _McpLogger extends Logger:
	var _autoload: Node

	func _init(autoload: Node) -> void:
		_autoload = autoload

	func _log_message(message: String, error: bool) -> void:
		var level := "error" if error else "info"
		_autoload._capture_log(level, message)

	func _log_error(
		function: String,
		file: String,
		line: int,
		code: String,
		rationale: String,
		_editor_notify: bool,
		_error_type: int,
		_script_backtraces: Array
	) -> void:
		# Prefer rationale (human-readable), fall back to code, then function:file:line
		var msg := rationale
		if msg.is_empty():
			msg = code
		if msg.is_empty() and not function.is_empty():
			msg = "%s at %s:%d" % [function, file.get_file(), line]
		if msg.is_empty():
			return
		_autoload._capture_log("error", msg)


func _exit_tree() -> void:
	if _debugger_registered:
		EngineDebugger.unregister_message_capture(CAPTURE_PREFIX)
		_debugger_registered = false
	if _ws_tcp:
		_ws_tcp.stop()
		_ws_tcp = null


## Called by _McpLogger to capture print/error output.
func _capture_log(level: String, message: String) -> void:
	# Strip trailing newlines and skip empty messages
	message = message.strip_edges()
	if message.is_empty():
		return
	var entry := {
		"level": level,
		"source": "game",
		"message": message,
		"time_ms": Time.get_ticks_msec(),
	}
	_log_buffer.append(entry)
	if _log_buffer.size() > _log_max:
		_log_buffer.pop_front()
	# Forward to editor via debugger channel (PIE mode only)
	if EngineDebugger.is_active():
		EngineDebugger.send_message("ogm:log", [level, message])


## Returns captured log entries (called from _on_debug_message for "log" action).
func _get_logs_action(params: Dictionary) -> Dictionary:
	var count: int = int(params.get("count", 100))
	var offset: int = int(params.get("offset", 0))
	var source: String = params.get("source", "all")
	var since_ms: int = int(params.get("since_ms", 0))
	var filtered: Array = []
	for entry in _log_buffer:
		if not source.is_empty() and source != "all" and entry.get("source", "") != source:
			continue
		if since_ms > 0 and int(entry.get("time_ms", 0)) < since_ms:
			continue
		filtered.append(entry)
	var sliced := filtered.slice(offset, offset + count)
	return {"ok": true, "entries": sliced}


## Clears the log buffer.
func _clear_logs_action() -> Dictionary:
	_log_buffer.clear()
	return {"ok": true}


func _process(delta: float) -> void:
	if not _frozen:
		_frame += 1
	if _ws_tcp:
		_process_ws_server()


## Called by EngineDebugger when a message with prefix "ogm:" arrives.
func _on_debug_message(message: String, data: Array) -> bool:
	var action := message.trim_prefix("ogm:")
	match action:
		"call":
			_handle_call(data)
			return true
	return false


## Dispatch "ogm:call" → runtime method, reply with ogm:response/ogm:error.
func _handle_call(data: Array) -> Dictionary:
	var request_id: int = int(data[0]) if data.size() > 0 else 0
	var method: String = str(data[1]) if data.size() > 1 else ""
	var params_json: String = str(data[2]) if data.size() > 2 else "{}"
	if method.is_empty():
		_reply_error(request_id, "No method provided")
		return {}
	var parsed = JSON.parse_string(params_json)
	var params: Dictionary = parsed if parsed is Dictionary else {}
	var result: Dictionary
	match method:
		"state":
			result = await mcp_state(params.get("action", "digest"), params)
		"input":
			result = await mcp_input(params.get("action", ""), params)
		"exec":
			result = await mcp_exec(params.get("action", ""), params)
		"screenshot":
			var ss_action: String = params.get("action", "game")
			var ss_params: Dictionary = params.get("params", {})
			result = await mcp_screenshot(ss_action, ss_params, _screenshot_dir())
		"game_time":
			result = await mcp_handle(params.get("action", ""), params)
		"network":
			result = mcp_network(params.get("action", ""), params)
		"profiler":
			result = await mcp_profiler(params.get("action", ""), params)
		"log":
			var log_action: String = params.get("action", "get")
			match log_action:
				"get":
					result = _get_logs_action(params)
				"errors":
					result = _get_logs_action({"source": "error", "count": params.get("count", 100)})
				"clear":
					result = _clear_logs_action()
				_:
					result = {"ok": false, "error": {"code": "INVALID_ARGUMENT", "message": "Unknown log action: %s" % log_action}}
		_:
			_reply_error(request_id, "Unknown runtime method: %s" % method)
			return {}
	_reply_response(request_id, result)
	return {}


func _reply_response(request_id: int, result: Dictionary) -> void:
	# Encode variant values to JSON-safe types before stringifying.
	var encoded := _VC.encode_variant(result)
	EngineDebugger.send_message("ogm:response", [request_id, JSON.stringify(encoded)])


func _reply_error(request_id: int, message: String) -> void:
	EngineDebugger.send_message("ogm:error", [request_id, message])


func _screenshot_dir() -> String:
	return "user://mcp_screenshots"


# ---- Clock control (godot_game_time) ----

func mcp_handle(method: String, params: Dictionary) -> Dictionary:
	match method:
		"freeze":
			return _freeze()
		"unfreeze":
			return _unfreeze(params)
		"step":
			return await _step(params)
		"step_until":
			return await _step_until(params)
		"pause":
			get_tree().paused = true
			return _EC.ok()
		"resume":
			get_tree().paused = false
			return _EC.ok()
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown method: %s" % method)


func _freeze() -> Dictionary:
	get_tree().paused = true
	_frozen = true
	return _EC.ok({"frame": _frame})


func _unfreeze(params: Dictionary) -> Dictionary:
	var time_scale: float = params.get("time_scale", 1.0)
	Engine.time_scale = time_scale
	get_tree().paused = false
	_frozen = false
	return _EC.ok({"frame": _frame})


func _step(params: Dictionary) -> Dictionary:
	var ms: int = params.get("ms", 16)
	var inputs: Array = params.get("inputs", [])
	# Temporarily unfreeze to step
	var was_paused := get_tree().paused
	get_tree().paused = false
	# Process inputs at specified times
	for inp in inputs:
		var at_ms: int = inp.get("at_ms", 0)
		# Schedule input at specific time within the step
		_inject_input(inp)
	# Advance time by processing frames
	var frames_to_process := max(1, int(ms / 16.0))
	var start_frame := _frame
	for i in frames_to_process:
		await get_tree().process_frame
		_frame += 1
	get_tree().paused = was_paused
	var elapsed := float(_frame - start_frame) * 0.016  # approximate
	return _EC.ok({"frame": _frame, "elapsed": elapsed})


func _step_until(params: Dictionary) -> Dictionary:
	var condition: String = params.get("condition", "")
	var timeout_ms: int = params.get("timeout_ms", 10000)
	var interval_ms: int = params.get("interval_ms", 16)
	if condition.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "condition required")
	var was_paused := get_tree().paused
	get_tree().paused = false
	var start_time := Time.get_ticks_msec()
	var start_frame := _frame
	var condition_met := false
	while Time.get_ticks_msec() - start_time < timeout_ms:
		# Evaluate condition in the game context
		var result: Variant = _eval_expression(condition)
		if result is bool and result:
			condition_met = true
			break
		await get_tree().process_frame
		_frame += 1
	get_tree().paused = was_paused
	var elapsed := float(Time.get_ticks_msec() - start_time) / 1000.0
	return _EC.ok({"frame": _frame, "elapsed": elapsed, "condition_met": condition_met})


# ---- Input simulation (godot_input) ----

func mcp_input(action: String, params: Dictionary) -> Dictionary:
	# "action" param may carry input_type (from handler) or legacy "action" key.
	# handler now sends input_type to avoid collision with InputMap action name.
	var input_type: String = params.get("input_type", action)
	# Record input actions (except record/replay/sequence themselves)
	if _recording and input_type not in ["record_start", "record_stop", "replay", "sequence"]:
		_record_buffer.append({
			"frame": _frame - _record_start_frame,
			"input": {"type": input_type, "params": params.duplicate()},
		})
	match input_type:
		"action":
			return _input_action(params)
		"key":
			return _input_key(params)
		"mouse_button":
			return _input_mouse_button(params)
		"mouse_motion":
			return _input_mouse_motion(params)
		"joypad":
			return _input_joypad(params)
		"text":
			return _input_text(params)
		"record_start":
			return _record_start(params)
		"record_stop":
			return _record_stop(params)
		"replay":
			return await _replay(params)
		"sequence":
			return await _input_sequence(params)
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown input action: %s" % action)


func _inject_input(inp: Dictionary) -> void:
	var type: String = inp.get("type", "")
	var params: Dictionary = inp.get("params", inp)
	match type:
		"action":
			_input_action(params)
		"key":
			_input_key(params)
		"mouse_button":
			_input_mouse_button(params)
		"mouse_motion":
			_input_mouse_motion(params)
		"joypad":
			_input_joypad(params)
		"text":
			_input_text(params)


func _record_start(params: Dictionary) -> Dictionary:
	_recording = true
	_record_buffer.clear()
	_record_start_frame = _frame
	return _EC.ok({"started": true, "start_frame": _record_start_frame})


func _record_stop(params: Dictionary) -> Dictionary:
	if not _recording:
		return _EC.fail("INVALID_ARGUMENT", "Not recording")
	_recording = false
	return _EC.ok({
		"stopped": true,
		"events": _record_buffer.duplicate(),
		"event_count": _record_buffer.size(),
		"duration_frames": _frame - _record_start_frame,
	})


func _replay(params: Dictionary) -> Dictionary:
	var events: Array = params.get("events", [])
	if events.is_empty():
		if _record_buffer.is_empty():
			return _EC.fail("INVALID_ARGUMENT", "events required (or call record_stop first to use buffer)")
		events = _record_buffer
	if _replaying:
		return _EC.fail("INVALID_ARGUMENT", "Already replaying")
	_replaying = true
	var start_frame := _frame
	for entry in events:
		var target_frame: int = int(entry.get("frame", 0))
		var inp: Dictionary = entry.get("input", {})
		while _frame - start_frame < target_frame:
			await get_tree().process_frame
		_inject_input(inp)
	_replaying = false
	return _EC.ok({
		"replayed": events.size(),
		"duration_frames": _frame - start_frame,
	})


func _input_sequence(params: Dictionary) -> Dictionary:
	var steps: Array = params.get("steps", [])
	var frame_delay: int = params.get("frame_delay", 1)
	if steps.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "steps[] required (array of {type, params} dicts)")
	for step in steps:
		_inject_input(step)
		for i in frame_delay:
			await get_tree().process_frame
	return _EC.ok({"executed": steps.size()})


func _input_action(params: Dictionary) -> Dictionary:
	var action: String = params.get("action", "")
	var pressed: bool = params.get("pressed", true)
	var strength: float = params.get("strength", 1.0)
	if action.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "action required")
	if pressed:
		Input.action_press(action, strength)
	else:
		Input.action_release(action)
	return _EC.ok()


func _input_key(params: Dictionary) -> Dictionary:
	var key_str: String = params.get("key", "")
	var pressed: bool = params.get("pressed", true)
	var modifiers: Array = params.get("modifiers", [])
	if key_str.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "key required")
	var key := OS.find_keycode_from_string(key_str)
	var event := InputEventKey.new()
	event.keycode = key
	# Also set physical_keycode so InputMap actions bound via physical_keycode match
	# (Godot 4 InputMap matches physical_keycode first when present).
	event.physical_keycode = key
	event.pressed = pressed
	event.ctrl_pressed = "ctrl" in modifiers
	event.shift_pressed = "shift" in modifiers
	event.alt_pressed = "alt" in modifiers
	event.meta_pressed = "meta" in modifiers
	Input.parse_input_event(event)
	return _EC.ok()


func _input_mouse_button(params: Dictionary) -> Dictionary:
	var button_str: String = params.get("button", "MOUSE_BUTTON_LEFT")
	var position: Dictionary = params.get("position", {"x": 0, "y": 0})
	var pressed: bool = params.get("pressed", true)
	var event := InputEventMouseButton.new()
	event.button_index = _mouse_button_index(button_str)
	event.position = Vector2(float(position.get("x", 0)), float(position.get("y", 0)))
	event.pressed = pressed
	Input.parse_input_event(event)
	return _EC.ok()


func _input_mouse_motion(params: Dictionary) -> Dictionary:
	var delta: Dictionary = params.get("delta", {"x": 0, "y": 0})
	var button_mask: Array = params.get("button_mask", [])
	var event := InputEventMouseMotion.new()
	event.relative = Vector2(float(delta.get("x", 0)), float(delta.get("y", 0)))
	var mask := 0
	for b in button_mask:
		mask |= _mouse_button_mask(b)
	event.button_mask = mask
	Input.parse_input_event(event)
	return _EC.ok()


func _input_joypad(params: Dictionary) -> Dictionary:
	var device: int = params.get("device", 0)
	var control: String = params.get("control", "button")
	var index: String = params.get("index", "")
	var value: float = params.get("value", 0.0)
	if control == "button":
		var event := InputEventJoypadButton.new()
		event.device = device
		event.button_index = _joy_button_index(index)
		event.pressed = value > 0.0
		Input.parse_input_event(event)
	elif control == "axis":
		var event := InputEventJoypadMotion.new()
		event.device = device
		event.axis = _joy_axis_index(index)
		event.axis_value = value
		Input.parse_input_event(event)
	return _EC.ok()


func _input_text(params: Dictionary) -> Dictionary:
	var text: String = params.get("text", "")
	for ch in text:
		var event := InputEventKey.new()
		event.unicode = ch.unicode_at(0)
		event.pressed = true
		Input.parse_input_event(event)
		event.pressed = false
		Input.parse_input_event(event)
	return _EC.ok()


# ---- State observation (godot_runtime_state) ----

func mcp_state(action: String, params: Dictionary) -> Dictionary:
	match action:
		"digest":
			return _digest(params)
		"inspect":
			return _inspect(params)
		"watch":
			return await _watch(params)
		"signals":
			return _signals(params)
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown state action: %s" % action)


func _digest(params: Dictionary) -> Dictionary:
	var groups: Array = params.get("groups", ["mcp_watch"])
	var include_props: Array = params.get("include_properties", [])
	var nodes := {}
	for group in groups:
		for node in get_tree().get_nodes_in_group(group):
			var path := str(node.get_path())
			if node.has_method("_mcp_state"):
				var state: Dictionary = node._mcp_state()
				nodes[path] = state
			else:
				var props := {}
				if include_props.is_empty():
					props = _VC.encode_node_properties(node)
				else:
					props = _VC.encode_node_properties(node, PackedStringArray(include_props))
				nodes[path] = props
	return _EC.ok({"nodes": nodes, "frame": _frame})


func _inspect(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	var props: Array = params.get("properties", [])
	if node_path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "node_path required")
	var node := get_tree().root.get_node_or_null(NodePath(node_path))
	if not node:
		return _EC.fail("NODE_NOT_FOUND", "Node not found: %s" % node_path)
	var prop_dict := _VC.encode_node_properties(node, PackedStringArray(props))
	return _EC.ok({"properties": prop_dict})


func _watch(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	var property: String = params.get("property", "")
	var duration_ms: int = params.get("duration_ms", 1000)
	if node_path.is_empty() or property.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "node_path and property required")
	var node := get_tree().root.get_node_or_null(NodePath(node_path))
	if not node:
		return _EC.fail("NODE_NOT_FOUND", "Node not found: %s" % node_path)
	var samples := []
	var start := Time.get_ticks_msec()
	while Time.get_ticks_msec() - start < duration_ms:
		var t_ms := Time.get_ticks_msec() - start
		var value: Variant = node.get(property)
		samples.append({"t_ms": t_ms, "value": _VC.encode_variant(value)})
		await get_tree().process_frame
	return _EC.ok({"samples": samples})


func _signals(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	var since_ms: int = params.get("since_ms", 1000)
	var now := Time.get_ticks_msec()
	var result := []
	for sig in _signal_log:
		var age: int = now - int(sig.get("time_ms", 0))
		if age <= since_ms:
			if node_path.is_empty() or sig.get("node_path", "") == node_path:
				result.append(sig)
	return _EC.ok({"signals": result})


# ---- GDScript injection (godot_exec) ----

func mcp_exec(action: String, params: Dictionary) -> Dictionary:
	match action:
		"eval":
			return await _eval(params)
		"call":
			return _call(params)
		"assert":
			return await _assert(params)
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown exec action: %s" % action)


func _eval(params: Dictionary) -> Dictionary:
	var code: String = params.get("code", "")
	var use_await: bool = params.get("await", false)
	if code.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "code required")
	# Create a temporary script to eval the code
	var script := GDScript.new()
	var wrapped := "extends Node\nfunc _eval():\n\t" + code.replace("\n", "\n\t") + "\n"
	script.source_code = wrapped
	var err := script.reload()
	if err != OK:
		return _EC.ok({"result": null, "error": {"code": "VALIDATION_ERROR", "message": "Script parse error", "line": 0}})
	var node := Node.new()
	node.set_script(script)
	add_child(node)
	var result: Variant = null
	if use_await:
		result = await node._eval()
	else:
		result = node._eval()
	node.queue_free()
	return _EC.ok({"result": _VC.encode_variant(result)})


func _assert(params: Dictionary) -> Dictionary:
	var condition: String = params.get("condition", "")
	var description: String = params.get("description", "")
	var use_await: bool = params.get("await", false)
	if condition.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "condition required (GDScript expression that returns bool)")
	var script := GDScript.new()
	var wrapped := "extends Node\nfunc _check():\n\treturn " + condition.replace("\n", "\n\t") + "\n"
	script.source_code = wrapped
	var err := script.reload()
	if err != OK:
		return _EC.fail("VALIDATION_ERROR", "Condition parse error: %s" % condition)
	var node := Node.new()
	node.set_script(script)
	add_child(node)
	var result: bool = false
	if use_await:
		result = await node._check()
	else:
		result = node._check()
	node.queue_free()
	var entry := {
		"condition": condition,
		"passed": bool(result),
		"time_ms": Time.get_ticks_msec(),
	}
	if not description.is_empty():
		entry["description"] = description
	if result:
		return _EC.ok(entry)
	else:
		var ret := _EC.fail("ASSERT_FAILED", "Assertion failed: %s" % (description if not description.is_empty() else condition))
		ret["assertion"] = entry
		return ret


func _eval_expression(expr: String) -> Variant:
	"""Evaluate a single expression in the game context."""
	var script := GDScript.new()
	script.source_code = "extends Node\nfunc _eval():\n\treturn " + expr + "\n"
	var err := script.reload()
	if err != OK:
		return false
	var node := Node.new()
	node.set_script(script)
	add_child(node)
	var result: Variant = node._eval()
	node.queue_free()
	return result


func _call(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	var method: String = params.get("method", "")
	var args: Array = params.get("args", [])
	if node_path.is_empty() or method.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "node_path and method required")
	var node := get_tree().root.get_node_or_null(NodePath(node_path))
	if not node:
		return _EC.fail("NODE_NOT_FOUND", "Node not found: %s" % node_path)
	if not node.has_method(method):
		return _EC.fail("NOT_FOUND", "Method not found: %s" % method)
	# Decode args
	var decoded_args := []
	for a in args:
		decoded_args.append(_VC.decode_variant(a))
	var result: Variant = node.callv(method, decoded_args)
	return _EC.ok({"result": _VC.encode_variant(result)})


# ---- Screenshot (godot_screenshot) ----

func mcp_screenshot(action: String, params: Dictionary, save_dir: String) -> Dictionary:
	match action:
		"game":
			return _screenshot_game(params, save_dir)
		"region":
			return _screenshot_region(params, save_dir)
		"burst":
			return await _screenshot_burst(params, save_dir)
		"cleanup":
			return _screenshot_cleanup(params, save_dir)
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown screenshot action: %s" % action)


func _screenshot_game(params: Dictionary, save_dir: String) -> Dictionary:
	var max_width: int = params.get("max_width", 0)
	var fmt: String = params.get("format", "png")
	var quality: int = params.get("quality", 90)
	var vp := get_viewport()
	var img := vp.get_texture().get_image()
	img = _resize_img(img, max_width)
	var path := _save_img(img, save_dir, "game", fmt, quality)
	_auto_cleanup_screenshots(save_dir)
	return _EC.ok({"path": path, "size_bytes": _file_size(path), "dimensions": {"width": img.get_width(), "height": img.get_height()}})


func _screenshot_region(params: Dictionary, save_dir: String) -> Dictionary:
	var rect: Dictionary = params.get("rect", {})
	var max_width: int = params.get("max_width", 0)
	var vp := get_viewport()
	var img := vp.get_texture().get_image()
	var x := int(rect.get("x", 0))
	var y := int(rect.get("y", 0))
	var w := int(rect.get("width", img.get_width()))
	var h := int(rect.get("height", img.get_height()))
	var region_img := img.get_region(Rect2i(x, y, w, h))
	region_img = _resize_img(region_img, max_width)
	var path := _save_img(region_img, save_dir, "region", "png", 90)
	_auto_cleanup_screenshots(save_dir)
	return _EC.ok({"path": path, "size_bytes": _file_size(path), "dimensions": {"width": region_img.get_width(), "height": region_img.get_height()}})


func _screenshot_burst(params: Dictionary, save_dir: String) -> Dictionary:
	var count: int = params.get("count", 10)
	var duration_ms: int = params.get("duration_ms", 1000)
	var interval_ms: int = params.get("interval_ms", 0)
	var max_width: int = params.get("max_width", 0)
	var fmt: String = params.get("format", "png")
	var quality: int = params.get("quality", 90)
	if interval_ms == 0:
		interval_ms = duration_ms / count
	var paths := []
	var start := Time.get_ticks_msec()
	var dims := {"width": 0, "height": 0}
	for i in count:
		var vp := get_viewport()
		var img := vp.get_texture().get_image()
		img = _resize_img(img, max_width)
		if i == 0:
			dims = {"width": img.get_width(), "height": img.get_height()}
		var path := _save_img(img, save_dir, "burst_%d" % i, fmt, quality)
		paths.append(path)
		# Wait for interval
		if _frozen:
			# In frozen mode, step the game time
			var was_paused := get_tree().paused
			get_tree().paused = false
			await get_tree().process_frame
			get_tree().paused = was_paused
		else:
			var wait_ms := interval_ms
			await get_tree().create_timer(wait_ms / 1000.0).timeout
	var actual_duration := Time.get_ticks_msec() - start
	_auto_cleanup_screenshots(save_dir)
	return _EC.ok({"paths": paths, "dimensions": dims, "count": paths.size(), "duration_ms": actual_duration})


# ---- Network (godot_network) ----

func mcp_network(action: String, params: Dictionary) -> Dictionary:
	match action:
		"simulate_peer":
			return _network_simulate_peer(params)
		"network_condition":
			return _network_condition(params)
		"rpc_call":
			return _network_rpc_call(params)
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown network action: %s" % action)


func _network_simulate_peer(params: Dictionary) -> Dictionary:
	# Game-specific peer simulation; needs the game to expose a hook.
	# We call any node in the "mcp_watch" group that implements
	# `_mcp_simulate_peer(params)`.
	for node in get_tree().get_nodes_in_group("mcp_watch"):
		if node.has_method("_mcp_simulate_peer"):
			var r: Variant = node._mcp_simulate_peer(params)
			return _EC.ok({"result": _VC.encode_variant(r)})
	return _EC.fail("NOT_FOUND", "No mcp_watch node implements _mcp_simulate_peer")


func _network_condition(params: Dictionary) -> Dictionary:
	var latency: float = float(params.get("latency_ms", 0.0))
	var loss: float = float(params.get("loss_pct", 0.0))
	var jitter: float = float(params.get("jitter_ms", 0.0))
	var clear: bool = bool(params.get("clear", false))
	var mp := get_tree().get_multiplayer()
	if clear:
		if _network_conditioner:
			var inner_peer: MultiplayerPeer = _network_conditioner.get_inner()
			if inner_peer and mp.get_multiplayer_peer() == _network_conditioner:
				mp.set_multiplayer_peer(inner_peer)
			_network_conditioner.stop_driver()
			_network_conditioner = null
		return _EC.ok({"active": false})
	var current_peer := mp.get_multiplayer_peer()
	if current_peer == null:
		return _EC.fail("RUNTIME_NOT_CONNECTED", "No multiplayer peer active")
	if _network_conditioner == null:
		_network_conditioner = _NetworkConditioner.new()
		_network_conditioner.set_inner(current_peer)
		_network_conditioner.start_driver(self)
		mp.set_multiplayer_peer(_network_conditioner)
	elif _network_conditioner.get_inner() != current_peer:
		_network_conditioner.set_inner(current_peer)
		if mp.get_multiplayer_peer() != _network_conditioner:
			mp.set_multiplayer_peer(_network_conditioner)
	_network_conditioner.set_conditions(latency, loss, jitter)
	return _EC.ok({
		"active": true,
		"latency_ms": latency,
		"loss_pct": loss,
		"jitter_ms": jitter,
	})


func _network_rpc_call(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	var method: String = params.get("method", "")
	var args: Array = params.get("args", [])
	if node_path.is_empty() or method.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "node_path and method required")
	var node := get_tree().root.get_node_or_null(NodePath(node_path))
	if not node:
		return _EC.fail("NODE_NOT_FOUND", "Node not found: %s" % node_path)
	if not node.has_method(method):
		return _EC.fail("NOT_FOUND", "Method not found: %s" % method)
	var decoded_args := []
	for a in args:
		decoded_args.append(_VC.decode_variant(a))
	var result: Variant = node.rpcv(method, decoded_args)
	return _EC.ok({"result": _VC.encode_variant(result)})


# ---- Profiler (godot_profiler) ----

func mcp_profiler(action: String, params: Dictionary) -> Dictionary:
	match action:
		"snapshot":
			return _profiler_snapshot()
		"series":
			return await _profiler_series(params)
		"spikes":
			return await _profiler_spikes(params)
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown profiler action: %s" % action)


func _profiler_snapshot() -> Dictionary:
	return _EC.ok({
		"fps": Engine.get_frames_per_second(),
		"process_time": Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
		"physics_time": Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0,
		"memory": OS.get_static_memory_usage(),
		"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"object_count": Performance.get_custom_monitor("object/instance_count") if Performance.has_custom_monitor("object/instance_count") else 0,
		"frame": _frame,
	})


func _profiler_series(params: Dictionary) -> Dictionary:
	var duration_ms: int = int(params.get("duration_ms", 1000))
	var metrics: Array = params.get("metrics", [])
	if metrics.is_empty():
		metrics = ["fps", "process_time", "physics_time", "memory", "draw_calls", "object_count"]
	var frames := []
	var start := Time.get_ticks_msec()
	var frame_num := 0
	while Time.get_ticks_msec() - start < duration_ms:
		await get_tree().process_frame
		var frame_data := {"frame": frame_num}
		frame_num += 1
		if "fps" in metrics:
			frame_data["fps"] = Engine.get_frames_per_second()
		if "process_time" in metrics:
			frame_data["process_time"] = Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
		if "physics_time" in metrics:
			frame_data["physics_time"] = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
		if "memory" in metrics:
			frame_data["memory"] = OS.get_static_memory_usage()
		if "draw_calls" in metrics:
			frame_data["draw_calls"] = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		if "object_count" in metrics:
			frame_data["object_count"] = 0
		frames.append(frame_data)
	return _EC.ok({"frames": frames})


func _profiler_spikes(params: Dictionary) -> Dictionary:
	var threshold_ms: float = float(params.get("threshold_ms", 33.0))
	var duration_ms: int = int(params.get("duration_ms", 1000))
	var spikes := []
	var start := Time.get_ticks_msec()
	var frame_num := 0
	while Time.get_ticks_msec() - start < duration_ms:
		var frame_start := Time.get_ticks_msec()
		await get_tree().process_frame
		var duration := Time.get_ticks_msec() - frame_start
		if float(duration) > threshold_ms:
			spikes.append({"frame": frame_num, "time_ms": frame_start, "duration_ms": duration})
		frame_num += 1
	return _EC.ok({"spikes": spikes})


# ---- Helpers ----

func _resize_img(img: Image, max_width: int) -> Image:
	if max_width > 0 and img.get_width() > max_width:
		var ratio := float(max_width) / float(img.get_width())
		var new_h := int(img.get_height() * ratio)
		img.resize(max_width, new_h, Image.INTERPOLATE_LANCZOS)
	return img


func _save_img(img: Image, dir: String, prefix: String, fmt: String, quality: int) -> String:
	var ts := Time.get_ticks_msec()
	var abs_dir := ProjectSettings.globalize_path(dir)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var path := abs_dir + "/" + prefix + "_" + str(ts) + "." + fmt
	match fmt:
		"png":
			img.save_png(path)
		"jpeg", "jpg":
			img.save_jpg(path, quality)
		"webp":
			img.save_webp(path, quality)
	return path


func _file_size(path: String) -> int:
	var f := FileAccess.open(path, FileAccess.READ)
	if f:
		var s := f.get_length()
		f.close()
		return s
	return 0


func _screenshot_cleanup(params: Dictionary, save_dir: String) -> Dictionary:
	var max_count: int = int(params.get("max_count", -1))
	var max_age_hours: float = float(params.get("max_age_hours", -1.0))
	var abs_dir := ProjectSettings.globalize_path(save_dir)
	var r := _Cleanup.cleanup(abs_dir, max_count, max_age_hours)
	return _EC.ok(r)


func _auto_cleanup_screenshots(save_dir: String) -> void:
	var abs_dir := ProjectSettings.globalize_path(save_dir)
	_Cleanup.cleanup(abs_dir)


func _mouse_button_index(s: String) -> MouseButton:
	match s:
		"MOUSE_BUTTON_LEFT": return MOUSE_BUTTON_LEFT
		"MOUSE_BUTTON_RIGHT": return MOUSE_BUTTON_RIGHT
		"MOUSE_BUTTON_MIDDLE": return MOUSE_BUTTON_MIDDLE
		"MOUSE_BUTTON_WHEEL_UP": return MOUSE_BUTTON_WHEEL_UP
		"MOUSE_BUTTON_WHEEL_DOWN": return MOUSE_BUTTON_WHEEL_DOWN
		_: return MOUSE_BUTTON_LEFT


func _mouse_button_mask(s: String) -> int:
	match s:
		"MOUSE_BUTTON_LEFT": return MOUSE_BUTTON_MASK_LEFT
		"MOUSE_BUTTON_RIGHT": return MOUSE_BUTTON_MASK_RIGHT
		"MOUSE_BUTTON_MIDDLE": return MOUSE_BUTTON_MASK_MIDDLE
		_: return 0


func _joy_button_index(s: String) -> JoyButton:
	match s:
		"JOY_BUTTON_A": return JOY_BUTTON_A
		"JOY_BUTTON_B": return JOY_BUTTON_B
		"JOY_BUTTON_X": return JOY_BUTTON_X
		"JOY_BUTTON_Y": return JOY_BUTTON_Y
		_: return JOY_BUTTON_A


func _joy_axis_index(s: String) -> JoyAxis:
	match s:
		"JOY_AXIS_LEFT_X": return JOY_AXIS_LEFT_X
		"JOY_AXIS_LEFT_Y": return JOY_AXIS_LEFT_Y
		"JOY_AXIS_RIGHT_X": return JOY_AXIS_RIGHT_X
		"JOY_AXIS_RIGHT_Y": return JOY_AXIS_RIGHT_Y
		_: return JOY_AXIS_LEFT_X


# ---- Standalone WebSocket server (for multiplayer game instances) ----

func _start_standalone_server(port: int) -> void:
	_ws_tcp = TCPServer.new()
	var err := _ws_tcp.listen(port, "127.0.0.1")
	if err != OK:
		push_warning("[MCP Runtime] Failed to listen on port %d for standalone WS server" % port)
		_ws_tcp = null
		return
	_standalone_mode = true
	print("[MCP Runtime] Standalone WS server listening on port %d" % port)


func _process_ws_server() -> void:
	if _ws_tcp == null:
		return
	while _ws_tcp.is_connection_available():
		var conn: StreamPeerTCP = _ws_tcp.take_connection()
		var peer := WebSocketPeer.new()
		peer.accept_stream(conn)
		_ws_clients.append(peer)
	var still_connected: Array[WebSocketPeer] = []
	for peer in _ws_clients:
		peer.poll()
		var state := peer.get_ready_state()
		if state == WebSocketPeer.STATE_OPEN:
			_process_ws_peer(peer)
			still_connected.append(peer)
		elif state == WebSocketPeer.STATE_CLOSED:
			pass  # Drop closed peers
		else:
			# CONNECTING or CLOSING — keep polling
			still_connected.append(peer)
	_ws_clients = still_connected


func _process_ws_peer(peer: WebSocketPeer) -> void:
	while peer.get_available_packet_count() > 0:
		var pkt := peer.get_packet()
		var text := pkt.get_string_from_utf8()
		if text.is_empty():
			continue
		var parsed = JSON.parse_string(text)
		if parsed == null or not (parsed is Dictionary):
			continue
		await _handle_ws_message(peer, parsed)


func _handle_ws_message(peer: WebSocketPeer, msg: Dictionary) -> void:
	var method: String = msg.get("method", "")
	var id: Variant = msg.get("id", null)
	var params: Dictionary = msg.get("params", {})
	if method == "ping":
		_ws_send_response(peer, id, {"pong": true})
		return
	if method == "handshake":
		var result := {
			"session_id": str(_ws_next_id),
			"godot_version": Engine.get_version_info()["string"],
			"project_path": ProjectSettings.globalize_path("res://"),
			"plugin_version": "0.1.0",
			"role": OS.get_environment("OGM_ROLE"),
			"game_port": int(OS.get_environment("OGM_GAME_PORT")),
		}
		_ws_next_id += 1
		_ws_send_response(peer, id, result)
		return
	if method == "tool_invoke":
		var tool: String = params.get("tool", "")
		var action: String = params.get("action", "")
		var tool_params: Dictionary = params.get("params", {})
		var result := await _dispatch_standalone(tool, action, tool_params)
		_ws_send_response(peer, id, result)
		return
	_ws_send_error(peer, id, -32601, "Method not found: %s" % method)


func _dispatch_standalone(tool: String, action: String, params: Dictionary) -> Dictionary:
	# Route to the same handler methods used by the debugger channel.
	match tool:
		"godot_runtime_state":
			return await mcp_state(action, params)
		"godot_input":
			return await mcp_input(action, params)
		"godot_exec":
			return await mcp_exec(action, params)
		"godot_screenshot":
			return await mcp_screenshot(action, params, _screenshot_dir())
		"godot_game_time", "godot_game":
			return await mcp_handle(action, params)
		"godot_network":
			return mcp_network(action, params)
		"godot_profiler":
			return await mcp_profiler(action, params)
		"godot_log":
			return _handle_log_standalone(action, params)
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown tool in standalone mode: %s" % tool)


func _handle_log_standalone(action: String, params: Dictionary) -> Dictionary:
	match action:
		"get":
			var source: String = params.get("source", "all")
			var count: int = params.get("count", 100)
			var offset: int = params.get("offset", 0)
			var since_ms: int = params.get("since_ms", 0)
			var entries := []
			var now := Time.get_ticks_msec()
			for e in _log_buffer:
				var s: String = e.get("source", "")
				if source != "all" and s != source:
					continue
				if since_ms > 0 and now - int(e.get("time_ms", 0)) > since_ms:
					continue
				entries.append(e)
			return _EC.ok({"entries": entries.slice(offset, offset + count)})
		"errors":
			var max_entries: int = params.get("max", 50)
			var include_warnings: bool = params.get("include_warnings", false)
			var errors := []
			for e in _log_buffer:
				var level: String = e.get("level", "")
				if level == "error" or (include_warnings and level == "warning"):
					errors.append(e)
					if errors.size() >= max_entries:
						break
			return _EC.ok({"errors": errors})
		"clear":
			_log_buffer.clear()
			return _EC.ok()
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown log action: %s" % action)


func _ws_send_response(peer: WebSocketPeer, id: Variant, result: Variant) -> void:
	var msg := {"jsonrpc": "2.0", "id": id, "result": result}
	peer.send_text(JSON.stringify(msg))


func _ws_send_error(peer: WebSocketPeer, id: Variant, code: int, message: String) -> void:
	var msg := {"jsonrpc": "2.0", "id": id, "error": {"code": code, "message": message}}
	peer.send_text(JSON.stringify(msg))


func _add_log(level: String, message: String) -> void:
	if not _standalone_mode:
		return
	var entry := {
		"time": Time.get_datetime_string_from_system(true),
		"time_ms": Time.get_ticks_msec(),
		"level": level,
		"source": "game",
		"message": message,
	}
	_log_buffer.append(entry)
	if _log_buffer.size() > _log_max:
		_log_buffer.pop_front()
