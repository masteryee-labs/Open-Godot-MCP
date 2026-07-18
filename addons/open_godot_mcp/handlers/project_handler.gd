extends RefCounted

## Project handler — godot_project / godot_input_map.
## Docs: 02-Tools/Project.md

const _VC = preload("res://addons/open_godot_mcp/utils/variant_codec.gd")
const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")

var _bridge: Node


func handle(tool: String, action: String, params: Dictionary) -> Dictionary:
	# Route based on tool name — godot_project vs godot_input_map
	if tool == "godot_input_map":
		return _handle_input_map(action, params)
	return _handle_project(action, params)


func _handle_project(action: String, params: Dictionary) -> Dictionary:
	match action:
		# Project actions
		"info":
			return _info()
		"get_setting":
			return _get_setting(params)
		"set_setting":
			return _set_setting(params)
		"list_settings":
			return _list_settings(params)
		"autoload_list":
			return _autoload_list()
		"autoload_add":
			return _autoload_add(params)
		"autoload_remove":
			return _autoload_remove(params)
		"rescan":
			return _rescan()
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown project action: %s" % action)


func _handle_input_map(action: String, params: Dictionary) -> Dictionary:
	match action:
		"list":
			return _im_list(params)
		"add":
			return _im_add(params)
		"remove":
			return _im_remove(params)
		"bind":
			return _im_bind(params)
		"ensure":
			return _im_ensure(params)
		"get":
			return _im_get(params)
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown input_map action: %s" % action)


func _info() -> Dictionary:
	var config := ConfigFile.new()
	config.load("res://project.godot")
	return _EC.ok({
		"name": config.get_value("application", "config/name", ""),
		"version": config.get_value("application", "config/version", "1.0.0"),
		"godot_version": Engine.get_version_info()["string"],
		"main_scene": config.get_value("application", "run/main_scene", null),
	})


func _get_setting(params: Dictionary) -> Dictionary:
	var key: String = params.get("key", "")
	if key.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "key required")
	var value := ProjectSettings.get_setting(key, null)
	return _EC.ok({"value": _VC.encode_variant(value) if value != null else null})


func _set_setting(params: Dictionary) -> Dictionary:
	var key: String = params.get("key", "")
	var value: Variant = params.get("value", null)
	if key.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "key required")
	ProjectSettings.set_setting(key, _VC.decode_variant(value))
	ProjectSettings.save()
	return _EC.ok()


func _list_settings(params: Dictionary) -> Dictionary:
	var category: String = params.get("category", "")
	var settings := {}
	var props := ProjectSettings.get_property_list()
	for p in props:
		var name: String = p["name"]
		if name.begins_with("open_godot_mcp/"):
			continue
		if not category.is_empty() and not name.begins_with(category):
			continue
		settings[name] = _VC.encode_variant(ProjectSettings.get_setting(name, null))
	return _EC.ok({"settings": settings})


func _autoload_list() -> Dictionary:
	var autoloads := []
	var props := ProjectSettings.get_property_list()
	for p in props:
		var name: String = p["name"]
		if name.begins_with("autoload/"):
			var short := name.substr("autoload/".length())
			var val: String = ProjectSettings.get_setting(name, "")
			var enabled := not val.begins_with("*")
			var path := val.lstrip("*")
			autoloads.append({"name": short, "path": path, "enabled": enabled})
	return _EC.ok({"autoloads": autoloads})


func _autoload_add(params: Dictionary) -> Dictionary:
	var name: String = params.get("name", "")
	var path: String = params.get("path", "")
	if name.is_empty() or path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "name, path required")
	ProjectSettings.set_setting("autoload/" + name, path)
	ProjectSettings.save()
	return _EC.ok()


func _autoload_remove(params: Dictionary) -> Dictionary:
	var name: String = params.get("name", "")
	if name.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "name required")
	ProjectSettings.set_setting("autoload/" + name, null)
	ProjectSettings.save()
	return _EC.ok()


func _rescan() -> Dictionary:
	EditorInterface.get_resource_filesystem().scan()
	return _EC.ok()


# ---- Input map actions ----

func _im_list(params: Dictionary) -> Dictionary:
	var include_builtin: bool = params.get("include_builtin", false)
	var actions := []
	var input_actions := InputMap.get_actions()
	for action in input_actions:
		var action_name: String = str(action)
		if not include_builtin and action_name.begins_with("ui_"):
			continue
		var events := []
		for event in InputMap.action_get_events(action):
			events.append(_encode_input_event(event))
		actions.append({"name": action_name, "deadzone": InputMap.action_get_deadzone(action), "events": events})
	return _EC.ok({"actions": actions})


func _im_add(params: Dictionary) -> Dictionary:
	var action: String = params.get("action", "")
	var deadzone: float = params.get("deadzone", 0.5)
	if action.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "action required")
	InputMap.add_action(action, deadzone)
	return _EC.ok()


func _im_remove(params: Dictionary) -> Dictionary:
	var action: String = params.get("action", "")
	if action.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "action required")
	InputMap.erase_action(action)
	return _EC.ok()


func _im_bind(params: Dictionary) -> Dictionary:
	var action: String = params.get("action", "")
	var event_type: String = params.get("event_type", "")
	var ep: Dictionary = params.get("params", {})
	if action.is_empty() or event_type.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "action, event_type required")
	var event := _decode_input_event(event_type, ep)
	if event == null:
		return _EC.fail("INVALID_ARGUMENT", "Failed to decode event")
	InputMap.action_add_event(action, event)
	return _EC.ok()


func _im_ensure(params: Dictionary) -> Dictionary:
	var action: String = params.get("action", "")
	var event_type: String = params.get("event_type", "")
	var ep: Dictionary = params.get("params", {})
	if action.is_empty() or event_type.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "action, event_type required")
	var event := _decode_input_event(event_type, ep)
	if event == null:
		return _EC.fail("INVALID_ARGUMENT", "Failed to decode event")
	# Check if already bound
	for existing in InputMap.action_get_events(action):
		if _events_equal(existing, event):
			return _EC.ok()  # Already bound
	InputMap.action_add_event(action, event)
	return _EC.ok()


func _im_get(params: Dictionary) -> Dictionary:
	var action: String = params.get("action", "")
	if action.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "action required")
	if not InputMap.has_action(action):
		return _EC.ok({"events": []})
	var events := []
	for event in InputMap.action_get_events(action):
		events.append(_encode_input_event(event))
	return _EC.ok({"events": events})


func _encode_input_event(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		var k := event as InputEventKey
		var mods := []
		if k.ctrl_pressed: mods.append("ctrl")
		if k.shift_pressed: mods.append("shift")
		if k.alt_pressed: mods.append("alt")
		if k.meta_pressed: mods.append("meta")
		return {"event_type": "key", "params": {"key": OS.get_keycode_string(k.keycode), "modifiers": mods}}
	elif event is InputEventMouseButton:
		var m := event as InputEventMouseButton
		return {"event_type": "mouse_button", "params": {"button": _mouse_button_string(m.button_index)}}
	elif event is InputEventJoypadButton:
		var j := event as InputEventJoypadButton
		return {"event_type": "joypad_button", "params": {"device": j.device, "button": _joy_button_string(j.button_index)}}
	elif event is InputEventJoypadMotion:
		var jm := event as InputEventJoypadMotion
		return {"event_type": "joypad_axis", "params": {"device": jm.device, "axis": _joy_axis_string(jm.axis), "axis_range": 1 if jm.axis_value > 0 else -1}}
	return {"event_type": "unknown"}


func _decode_input_event(event_type: String, p: Dictionary) -> InputEvent:
	match event_type:
		"key":
			var key_str: String = p.get("key", "")
			# Support: KEY_M, M, KEY_SPACE, Space, space, numeric keycode
			var key := 0
			if key_str.is_valid_int():
				key = key_str.to_int()
			else:
				# Try as-is first (handles "M", "Space", "SPACE")
				key = OS.find_keycode_from_string(key_str)
				# If that fails and it has KEY_ prefix, try without it
				if key == 0 and key_str.begins_with("KEY_"):
					key = OS.find_keycode_from_string(key_str.substr(4))
			var event := InputEventKey.new()
			event.keycode = key
			var mods: Array = p.get("modifiers", [])
			event.ctrl_pressed = "ctrl" in mods
			event.shift_pressed = "shift" in mods
			event.alt_pressed = "alt" in mods
			event.meta_pressed = "meta" in mods
			return event
		"mouse_button":
			var btn_str: String = p.get("button", "")
			var event := InputEventMouseButton.new()
			event.button_index = _mouse_button_index(btn_str)
			return event
		"joypad_button":
			var event := InputEventJoypadButton.new()
			event.device = p.get("device", 0)
			event.button_index = _joy_button_index(p.get("button", ""))
			return event
		"joypad_axis":
			var event := InputEventJoypadMotion.new()
			event.device = p.get("device", 0)
			event.axis = _joy_axis_index(p.get("axis", ""))
			event.axis_value = float(p.get("axis_range", 1))
			return event
	return null


func _events_equal(a: InputEvent, b: InputEvent) -> bool:
	if a.get_class() != b.get_class():
		return false
	return a.is_match(b)


func _mouse_button_string(idx: MouseButton) -> String:
	match idx:
		MOUSE_BUTTON_LEFT: return "MOUSE_BUTTON_LEFT"
		MOUSE_BUTTON_RIGHT: return "MOUSE_BUTTON_RIGHT"
		MOUSE_BUTTON_MIDDLE: return "MOUSE_BUTTON_MIDDLE"
		MOUSE_BUTTON_WHEEL_UP: return "MOUSE_BUTTON_WHEEL_UP"
		MOUSE_BUTTON_WHEEL_DOWN: return "MOUSE_BUTTON_WHEEL_DOWN"
		_: return "MOUSE_BUTTON_%d" % idx


func _mouse_button_index(s: String) -> MouseButton:
	match s:
		"MOUSE_BUTTON_LEFT": return MOUSE_BUTTON_LEFT
		"MOUSE_BUTTON_RIGHT": return MOUSE_BUTTON_RIGHT
		"MOUSE_BUTTON_MIDDLE": return MOUSE_BUTTON_MIDDLE
		"MOUSE_BUTTON_WHEEL_UP": return MOUSE_BUTTON_WHEEL_UP
		"MOUSE_BUTTON_WHEEL_DOWN": return MOUSE_BUTTON_WHEEL_DOWN
		_: return MOUSE_BUTTON_LEFT


func _joy_button_string(idx: JoyButton) -> String:
	match idx:
		JOY_BUTTON_A: return "JOY_BUTTON_A"
		JOY_BUTTON_B: return "JOY_BUTTON_B"
		JOY_BUTTON_X: return "JOY_BUTTON_X"
		JOY_BUTTON_Y: return "JOY_BUTTON_Y"
		_: return "JOY_BUTTON_%d" % idx


func _joy_button_index(s: String) -> JoyButton:
	match s:
		"JOY_BUTTON_A": return JOY_BUTTON_A
		"JOY_BUTTON_B": return JOY_BUTTON_B
		"JOY_BUTTON_X": return JOY_BUTTON_X
		"JOY_BUTTON_Y": return JOY_BUTTON_Y
		_: return JOY_BUTTON_A


func _joy_axis_string(idx: JoyAxis) -> String:
	match idx:
		JOY_AXIS_LEFT_X: return "JOY_AXIS_LEFT_X"
		JOY_AXIS_LEFT_Y: return "JOY_AXIS_LEFT_Y"
		JOY_AXIS_RIGHT_X: return "JOY_AXIS_RIGHT_X"
		JOY_AXIS_RIGHT_Y: return "JOY_AXIS_RIGHT_Y"
		_: return "JOY_AXIS_%d" % idx


func _joy_axis_index(s: String) -> JoyAxis:
	match s:
		"JOY_AXIS_LEFT_X": return JOY_AXIS_LEFT_X
		"JOY_AXIS_LEFT_Y": return JOY_AXIS_LEFT_Y
		"JOY_AXIS_RIGHT_X": return JOY_AXIS_RIGHT_X
		"JOY_AXIS_RIGHT_Y": return JOY_AXIS_RIGHT_Y
		_: return JOY_AXIS_LEFT_X
