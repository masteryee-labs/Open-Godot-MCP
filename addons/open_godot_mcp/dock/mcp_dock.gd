@tool
extends Control

## MCP Dock — connection status UI.
## Docs: 01-Architecture/Connection-Stability.md §對策 5

const _PortResolver = preload("res://addons/open_godot_mcp/utils/port_resolver.gd")

var _server: Node = null
var _log_buffer: Array = []
var _log_buffer_max: int = 200
@onready var _status_label: Label = $VBox/StatusLabel
@onready var _info_label: Label = $VBox/InfoLabel
@onready var _reconnect_btn: Button = $VBox/ReconnectBtn
@onready var _settings_btn: Button = $VBox/SettingsBtn
@onready var _log_btn: Button = $VBox/LogBtn


func _ready() -> void:
	if _reconnect_btn:
		_reconnect_btn.pressed.connect(_on_reconnect_btn_pressed)
	if _settings_btn:
		_settings_btn.pressed.connect(_on_settings_btn_pressed)
	if _log_btn:
		_log_btn.pressed.connect(_on_log_btn_pressed)
	# Surface bridge / runtime liveness to the dock so the user can see
	# whether the game-side autoload has beaconed without opening a tool.
	_update_runtime_status()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_update_runtime_status()


func set_server(server: Node) -> void:
	if _server and _server.status_changed.is_connected(_on_status_changed):
		_server.status_changed.disconnect(_on_status_changed)
	_server = server
	if _server:
		_server.status_changed.connect(_on_status_changed)
		_update_status("Listening on port %d" % _server.port)


func _on_status_changed(text: String) -> void:
	_update_status(text)
	_log("bridge: " + text)


func _update_status(text: String) -> void:
	if _status_label:
		_status_label.text = "Status: " + text
		if "ERROR" in text or "FATAL" in text:
			_status_label.add_theme_color_override("font_color", Color.RED)
		elif "Connected" in text:
			_status_label.add_theme_color_override("font_color", Color.GREEN)
		else:
			_status_label.add_theme_color_override("font_color", Color.YELLOW)


func _update_runtime_status() -> void:
	if _info_label == null:
		return
	var bridge_ok := _server != null and not (_server._clients as Array).is_empty()
	var runtime_ok := false
	if _server:
		var dbg: EditorDebuggerPlugin = _server.get_debugger()
		if dbg and dbg.has_method("is_game_ready"):
			runtime_ok = dbg.is_game_ready()
	var port: int = _server.port if _server else _PortResolver.DEFAULT_BRIDGE_PORT
	_info_label.text = "bridge:%s runtime:%s port:%d" % [str(bridge_ok), str(runtime_ok), port]


func _on_reconnect_btn_pressed() -> void:
	if _server:
		_log("reconnect: restarting bridge")
		_server.stop_server()
		_server.start_server()


func _on_settings_btn_pressed() -> void:
	# Godot 4.7 has no EditorInterface.open_settings() or
	# open_project_settings(). Print a hint pointing the user to the
	# right menu; the dock can't open dialogs that don't expose an API.
	_log("settings: Editor > Editor Settings > Open Godot MCP (no programmatic open in Godot 4.7)")
	print("[Open Godot MCP] Configure via Editor > Editor Settings > Open Godot MCP")


func _on_log_btn_pressed() -> void:
	# Dump the recent log buffer to the editor Output panel.
	if _log_buffer.is_empty():
		print("[Open Godot MCP] (no log entries yet)")
		return
	for entry in _log_buffer:
		print("[Open Godot MCP] " + entry)


func _log(text: String) -> void:
	_log_buffer.append(text)
	if _log_buffer.size() > _log_buffer_max:
		_log_buffer = _log_buffer.slice(_log_buffer.size() - _log_buffer_max)
