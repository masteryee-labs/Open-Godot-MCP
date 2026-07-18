extends RefCounted

## Debugger handler — godot_debugger (DAP integration).
## Docs: 02-Tools/Diagnostics.md §godot_debugger
##
## Uses Godot's built-in debugger via EditorDebuggerPlugin.
## stack_trace/variables scrape the editor's debug dock UI because Godot 4's
## built-in debugger handles stack_dump/stack_frame_vars/evaluated messages
## internally and does NOT pass them to EditorDebuggerPlugin._capture.
## evaluate uses call_runtime (game-side autoload) which works when the game
## is running but NOT when paused at a breakpoint.

const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")
const _VC = preload("res://addons/open_godot_mcp/utils/variant_codec.gd")

var _bridge: Node


func handle(tool: String, action: String, params: Dictionary) -> Dictionary:
	match action:
		"set_breakpoint":
			return _set_breakpoint(params)
		"remove_breakpoint":
			return _remove_breakpoint(params)
		"resume":
			return _debugger_command("continue")
		"continue":
			return _debugger_command("continue")
		"step_over":
			return _debugger_command("next")
		"step_into":
			return _debugger_command("into")
		"step_out":
			return _debugger_command("out")
		"stack_trace":
			return _stack_trace()
		"variables":
			return _variables(params)
		"evaluate":
			return await _evaluate(params)
		"sessions":
			return _sessions()
		"list_breakpoints":
			return _list_breakpoints(params)
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown action: %s" % action)


func _get_debugger() -> EditorDebuggerPlugin:
	if _bridge == null:
		return null
	return _bridge.get_debugger()


func _get_active_session() -> EditorDebuggerSession:
	var dbg := _get_debugger()
	if not dbg:
		return null
	for session in dbg.get_sessions():
		if session.has_method("is_session_active") and session.is_session_active():
			return session
		elif session.has_method("is_active") and session.is_active():
			return session
	return null


func _set_breakpoint(params: Dictionary) -> Dictionary:
	var script_path: String = params.get("script_path", "")
	var line: int = params.get("line", 0)
	if script_path.is_empty() or line < 1:
		return _EC.fail("INVALID_ARGUMENT", "script_path and line (1-based) required")
	var dbg := _get_debugger()
	if not dbg:
		return _EC.fail("NO_DEBUGGER", "No active debugger session")
	for session in dbg.get_sessions():
		session.set_breakpoint(script_path, line, true)
	return _EC.ok({"script_path": script_path, "line": line})


func _remove_breakpoint(params: Dictionary) -> Dictionary:
	var script_path: String = params.get("script_path", "")
	var line: int = params.get("line", 0)
	if script_path.is_empty() or line < 1:
		return _EC.fail("INVALID_ARGUMENT", "script_path and line required")
	var dbg := _get_debugger()
	if not dbg:
		return _EC.fail("NO_DEBUGGER", "No active debugger session")
	for session in dbg.get_sessions():
		session.set_breakpoint(script_path, line, false)
	return _EC.ok({"script_path": script_path, "line": line})


func _list_breakpoints(params: Dictionary) -> Dictionary:
	var dbg := _get_debugger()
	if not dbg:
		return _EC.ok({"breakpoints": []})
	return _EC.ok({"breakpoints": []})


func _is_session_active(session) -> bool:
	if session.has_method("is_session_active"):
		return session.is_session_active()
	if session.has_method("is_active"):
		return session.is_active()
	return false


func _debugger_command(cmd: String) -> Dictionary:
	var dbg := _get_debugger()
	if not dbg:
		return _EC.fail("NO_DEBUGGER", "No active debugger session")
	var sent := false
	for session in dbg.get_sessions():
		if _is_session_active(session):
			session.send_message("debug:" + cmd, [])
			sent = true
	if not sent:
		return _EC.fail("NO_DEBUGGER", "No active debug session (game not running or not paused)")
	return _EC.ok({"command": cmd})


## Scrape the editor's debug dock "Stack Trace" panel.
## Godot 4's built-in debugger handles stack_dump internally and does NOT
## pass it to EditorDebuggerPlugin._capture, so we read the Tree UI instead.
func _stack_trace() -> Dictionary:
	var dbg := _get_debugger()
	if not dbg:
		return _EC.ok({"frames": [], "paused": false})
	var session := _get_active_session()
	if not session:
		return _EC.ok({"frames": [], "paused": false})
	var is_paused := false
	if session.has_method("is_breaked"):
		is_paused = session.is_breaked()
	if not is_paused:
		return _EC.ok({"frames": [], "paused": false, "message": "Game is running, not paused at breakpoint"})
	var frames := _scrape_stack_frames()
	return _EC.ok({"frames": frames, "paused": true})


static func _scrape_stack_frames() -> Array:
	var base := EditorInterface.get_base_control()
	if base == null:
		return []
	var debuggers: Array[Node] = []
	_collect_nodes_of_class(base, "ScriptEditorDebugger", debuggers)
	for dbg in debuggers:
		var trees: Array[Node] = []
		_collect_nodes_of_class(dbg, "Tree", trees)
		for t in trees:
			var frames := _frames_from_stack_tree(t)
			if not frames.is_empty():
				return frames
	return []


static func _frames_from_stack_tree(tree: Tree) -> Array:
	var frames: Array = []
	var root: TreeItem = tree.get_root()
	if root == null:
		return frames
	var item: TreeItem = root.get_first_child()
	while item != null:
		var meta = item.get_metadata(0)
		if meta is Dictionary and meta.has("file") and meta.has("frame"):
			frames.append({
				"frame": int(meta.get("frame", 0)),
				"file": str(meta.get("file", "")),
				"line": int(meta.get("line", 0)),
				"function": str(meta.get("function", "")),
			})
		item = item.get_next()
	return frames


static func _collect_nodes_of_class(node: Node, klass: String, out: Array[Node]) -> void:
	if node.is_class(klass):
		out.append(node)
	for child in node.get_children():
		_collect_nodes_of_class(child, klass, out)


## Scrape the editor's debug dock "Local" variables panel.
func _variables(params: Dictionary) -> Dictionary:
	var frame_id: int = params.get("frame_id", 0)
	var dbg := _get_debugger()
	if not dbg:
		return _EC.ok({"variables": {}})
	var session := _get_active_session()
	if not session or not session.has_method("is_breaked") or not session.is_breaked():
		return _EC.fail("NO_DEBUGGER", "Game not paused at breakpoint")
	var variables := _scrape_local_variables()
	return _EC.ok({"variables": variables, "frame_id": frame_id})


static func _scrape_local_variables() -> Dictionary:
	var base := EditorInterface.get_base_control()
	if base == null:
		return {}
	var debuggers: Array[Node] = []
	_collect_nodes_of_class(base, "ScriptEditorDebugger", debuggers)
	for dbg in debuggers:
		var inspectors: Array[Node] = []
		_collect_nodes_of_class(dbg, "EditorDebuggerInspector", inspectors)
		for insp in inspectors:
			var vars := _vars_from_inspector(insp)
			if not vars.is_empty():
				return vars
	return {}


static func _vars_from_inspector(inspector: Node) -> Dictionary:
	var vars: Dictionary = {}
	_collect_inspector_vars(inspector, vars)
	return vars


static func _collect_inspector_vars(node: Node, vars: Dictionary) -> void:
	var cls: String = node.get_class()
	if cls.begins_with("EditorProperty"):
		var label: String = ""
		var value: String = ""
		if node.has_method("get_label"):
			label = node.get_label()
		# Try EditorProperty.get_value() — returns the current edited value
		if node.has_method("get_value"):
			var val = node.get_value()
			if val != null:
				value = str(val)
		# Fallback: try scraping child widgets
		if value.is_empty():
			value = _scrape_property_widget(node)
		if not label.is_empty():
			label = label.uri_decode()
			vars[label] = value
	for child in node.get_children():
		_collect_inspector_vars(child, vars)


static func _scrape_property_widget(prop: Node) -> String:
	for child in prop.get_children():
		var cls: String = child.get_class()
		if cls == "EditorSpinSlider" and child.has_method("get_value"):
			return str(child.get_value())
		if cls == "CheckBox" and child.has_method("is_pressed"):
			return str(child.is_pressed())
		if cls == "LineEdit" and child.has_method("get_text"):
			return child.get_text()
		if cls == "Label" and child.has_method("get_text"):
			return child.get_text()
		if cls == "Button" and child.has_method("get_text"):
			return child.get_text()
		# Recurse into nested containers
		if child is Container:
			var nested := _scrape_property_widget(child)
			if not nested.is_empty():
				return nested
	return ""


## Evaluate uses call_runtime (game-side autoload). Works when game is running
## but NOT when paused at a breakpoint (game idle loop is frozen).
func _evaluate(params: Dictionary) -> Dictionary:
	var expression: String = params.get("expression", "")
	if expression.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "expression required")
	var dbg := _get_debugger()
	if not dbg:
		return _EC.fail("NO_DEBUGGER", "No active debugger session")
	var session := _get_active_session()
	if not session:
		return _EC.fail("NO_DEBUGGER", "No active debug session")
	# Check if paused — call_runtime won't work when paused
	if session.has_method("is_breaked") and session.is_breaked():
		return _EC.fail("NOT_SUPPORTED", "Evaluate is not available when game is paused at a breakpoint. Resume the game first, or use stack_trace/variables to inspect state.")
	# Use call_runtime to evaluate in the game context
	var result: Dictionary = await dbg.call_runtime("exec", {"action": "eval", "code": expression})
	return result


func _sessions() -> Dictionary:
	var dbg := _get_debugger()
	if not dbg:
		return _EC.ok({"sessions": []})
	var sessions := []
	for session in dbg.get_sessions():
		var is_paused := false
		if session.has_method("is_breaked"):
			is_paused = session.is_breaked()
		sessions.append({
			"active": _is_session_active(session),
			"paused": is_paused,
		})
	return _EC.ok({"sessions": sessions})
