@tool
extends Control

## MCP Dock — connection status UI + update notification banner.
## Docs: 01-Architecture/Connection-Stability.md §對策 5

const _PortResolver = preload("res://addons/open_godot_mcp/utils/port_resolver.gd")
const _UpdateManagerScript = preload("res://addons/open_godot_mcp/utils/update_manager.gd")

var _server: Node = null
var _log_buffer: Array = []
var _log_buffer_max: int = 200
var _update_manager: Node = null

@onready var _status_label: Label = $Scroll/VBox/StatusLabel
@onready var _info_label: Label = $Scroll/VBox/InfoLabel
@onready var _reconnect_btn: Button = $Scroll/VBox/ReconnectBtn
@onready var _settings_btn: Button = $Scroll/VBox/SettingsBtn
@onready var _log_btn: Button = $Scroll/VBox/LogBtn
@onready var _update_banner: VBoxContainer = $Scroll/VBox/UpdateBanner
@onready var _update_label: Label = $Scroll/VBox/UpdateBanner/UpdateLabel
@onready var _update_btn: Button = $Scroll/VBox/UpdateBanner/UpdateBtnRow/UpdateBtn
@onready var _release_notes_btn: Button = $Scroll/VBox/UpdateBanner/UpdateBtnRow/ReleaseNotesBtn


func _ready() -> void:
	if _reconnect_btn:
		_reconnect_btn.pressed.connect(_on_reconnect_btn_pressed)
	if _settings_btn:
		_settings_btn.pressed.connect(_on_settings_btn_pressed)
	if _log_btn:
		_log_btn.pressed.connect(_on_log_btn_pressed)
	if _update_btn:
		_update_btn.pressed.connect(_on_update_pressed)
	if _release_notes_btn:
		_release_notes_btn.pressed.connect(_on_release_notes_pressed)
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


func set_plugin(plugin: Node) -> void:
	if _update_manager == null:
		_update_manager = _UpdateManagerScript.new()
		_update_manager.setup(plugin, self)
		_update_manager.update_check_completed.connect(_on_update_check_result)
		_update_manager.install_state_changed.connect(_on_install_state_changed)
		add_child(_update_manager)
	_update_manager.check_for_updates.call_deferred()


func prepare_for_self_update_drain() -> void:
	pass


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
	_log("settings: Editor > Editor Settings > Open Godot MCP (no programmatic open in Godot 4.7)")
	print("[Open Godot MCP] Configure via Editor > Editor Settings > Open Godot MCP")


func _on_log_btn_pressed() -> void:
	if _log_buffer.is_empty():
		print("[Open Godot MCP] (no log entries yet)")
		return
	for entry in _log_buffer:
		print("[Open Godot MCP] " + entry)


func _on_update_pressed() -> void:
	if _update_manager != null:
		_update_manager.start_install()


func _on_release_notes_pressed() -> void:
	OS.shell_open(_UpdateManagerScript.RELEASES_PAGE)


func _on_update_check_result(result: Dictionary) -> void:
	if _update_label:
		_update_label.text = String(result.get("label_text", ""))
	if _update_banner:
		_update_banner.visible = true


func _on_install_state_changed(state: Dictionary) -> void:
	if state.has("button_text") and _update_btn != null:
		_update_btn.text = String(state["button_text"])
	if state.has("button_disabled") and _update_btn != null:
		_update_btn.disabled = bool(state["button_disabled"])
	if state.has("label_text") and _update_label != null:
		_update_label.text = String(state["label_text"])
	if state.has("banner_visible") and _update_banner != null:
		_update_banner.visible = bool(state["banner_visible"])
	if String(state.get("outcome", "")) == "success" and _update_label != null:
		_update_label.add_theme_color_override("font_color", Color.GREEN)


func _log(text: String) -> void:
	_log_buffer.append(text)
	if _log_buffer.size() > _log_buffer_max:
		_log_buffer = _log_buffer.slice(_log_buffer.size() - _log_buffer_max)
