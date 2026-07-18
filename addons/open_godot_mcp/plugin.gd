@tool
extends EditorPlugin

## Open Godot MCP — EditorPlugin entry point.
##
## Per Docs/01-Architecture/Runtime-Autoload.md §Editor Bridge 啟動:
##   1. Plugin._enter_tree() — read port (env > EditorSettings > default)
##   2. Detect Windows port reservation, avoid if needed
##   3. Start WebSocket server
##   4. Wait for MCP Server connection
##   5. Handshake
##   6. Handle tool_invoke

const _BridgeServer = preload("res://addons/open_godot_mcp/bridge/websocket_server.gd")
const _DockScene = preload("res://addons/open_godot_mcp/dock/mcp_dock.tscn")
const _ExportPlugin = preload("res://addons/open_godot_mcp/export/mcp_export_plugin.gd")
const _DebuggerPlugin = preload("res://addons/open_godot_mcp/debugger/mcp_debugger_plugin.gd")

var _server: Node
var _dock: Control
var _export_plugin: EditorExportPlugin
var _debugger_plugin: EditorDebuggerPlugin
var _editor_logger: Logger = null

# Runtime autoload management
const _RUNTIME_AUTOLOAD_NAME = "McpRuntimeAutoload"
const _RUNTIME_AUTOLOAD_PATH = "res://addons/open_godot_mcp/runtime/runtime_autoload.gd"
var _runtime_injected: bool = false


func _enter_tree() -> void:
	# Register EditorSettings with defaults (Installation Guide §進階設定)
	_ensure_editor_settings()

	# Start the WebSocket bridge server
	_server = _BridgeServer.new()
	add_child(_server)
	_server.start_server()

	# Add the connection-status dock (Connection-Stability.md §對策 5)
	_dock = _DockScene.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, _dock)
	_dock.set_server(_server)

	# Export plugin — strips runtime on export (Runtime-Autoload.md §匯出)
	_export_plugin = _ExportPlugin.new()
	add_export_plugin(_export_plugin)

	# Debugger plugin — bridges editor ↔ game runtime over debugger channel
	_debugger_plugin = _DebuggerPlugin.new()
	_debugger_plugin.set_bridge(_server)
	_server.set_debugger_plugin(_debugger_plugin)
	add_debugger_plugin(_debugger_plugin)

	# Register editor logger to capture editor Output panel logs
	_editor_logger = _EditorLogger.new(_server)
	OS.add_logger(_editor_logger)

	print("[Open Godot MCP] Plugin enabled — bridge on port %d" % _server.port)

	# Inject runtime autoload immediately so it's ready when the game starts.
	# add_autoload_singleton must happen before play for Godot to pick it up.
	inject_runtime_autoload()


func _exit_tree() -> void:
	# Remove editor logger
	if _editor_logger:
		OS.remove_logger(_editor_logger)
		_editor_logger = null

	# Clean up runtime autoload if we injected it
	if _runtime_injected:
		_remove_runtime_autoload()

	if _debugger_plugin:
		remove_debugger_plugin(_debugger_plugin)
		_debugger_plugin = null

	if _export_plugin:
		remove_export_plugin(_export_plugin)
		_export_plugin = null

	if _dock:
		remove_control_from_docks(_dock)
		_dock.queue_free()
		_dock = null

	if _server:
		_server.stop_server()
		_server.queue_free()
		_server = null


func _ensure_editor_settings() -> void:
	# EditorSettings is not a static class — get the instance via EditorInterface
	var es := EditorInterface.get_editor_settings()
	if not es:
		return
	# Create the settings category with defaults if not present
	var defs := {
		"open_godot_mcp/bridge/port": 6970,
		"open_godot_mcp/bridge/auto_port": true,
		"open_godot_mcp/bridge/heartbeat_interval": 5,
		"open_godot_mcp/bridge/reconnect_max": 20,
		"open_godot_mcp/runtime/auto_inject": true,
		"open_godot_mcp/runtime/strip_on_export": true,
		"open_godot_mcp/security/allow_eval": true,
		"open_godot_mcp/security/read_only": false,
		"open_godot_mcp/security/auth_token": "",
	}
	for key in defs:
		if not es.has_setting(key):
			es.set_setting(key, defs[key])


# ---- Runtime autoload injection (Runtime-Autoload.md §啟動流程) ----

func inject_runtime_autoload() -> void:
	if _runtime_injected:
		return
	if not _is_runtime_auto_inject_enabled():
		return
	# Write directly to ProjectSettings + save to disk.
	# EditorPlugin.add_autoload_singleton only mutates in-memory settings —
	# the on-disk project.godot is only persisted when the editor saves
	# (e.g. on quit). A game subprocess spawned before any save fires
	# never sees the autoload and the runtime beacon never arrives.
	var key := "autoload/" + _RUNTIME_AUTOLOAD_NAME
	var value := "*" + _RUNTIME_AUTOLOAD_PATH  # "*" prefix = singleton
	if ProjectSettings.get_setting(key, "") == value:
		_runtime_injected = false  # already registered with right target
		return
	ProjectSettings.set_setting(key, value)
	ProjectSettings.set_as_basic(key, true)
	var err := ProjectSettings.save()
	if err != OK:
		push_warning("[Open Godot MCP] failed to save project.godot after registering %s autoload (error %d)" % [_RUNTIME_AUTOLOAD_NAME, err])
	_runtime_injected = true


func _remove_runtime_autoload() -> void:
	if not _runtime_injected:
		return
	var key := "autoload/" + _RUNTIME_AUTOLOAD_NAME
	if ProjectSettings.has_setting(key):
		ProjectSettings.clear(key)
		ProjectSettings.save()
	_runtime_injected = false


func _is_runtime_auto_inject_enabled() -> bool:
	var es := EditorInterface.get_editor_settings()
	if not es:
		return true
	var v = es.get_setting("open_godot_mcp/runtime/auto_inject")
	if v == null:
		return true
	return bool(v)


# ---- Editor logger — captures editor Output panel logs ----

class _EditorLogger extends Logger:
	var _bridge: Node

	func _init(bridge: Node) -> void:
		_bridge = bridge

	func _log_message(message: String, error: bool) -> void:
		if not _bridge or not is_instance_valid(_bridge):
			return
		var msg := message.strip_edges()
		if msg.is_empty():
			return
		var level := "error" if error else "info"
		_bridge.add_log(level, "editor", msg)

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
		if not _bridge or not is_instance_valid(_bridge):
			return
		var msg := rationale
		if msg.is_empty():
			msg = code
		if msg.is_empty() and not function.is_empty():
			msg = "%s at %s:%d" % [function, file.get_file(), line]
		if msg.is_empty():
			return
		_bridge.add_log("error", "editor", msg.strip_edges())
