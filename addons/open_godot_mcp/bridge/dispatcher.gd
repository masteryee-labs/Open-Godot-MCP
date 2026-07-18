extends RefCounted

## Dispatcher — routes tool_invoke to the right handler.
##
## Per Docs/02-Tools/Index.md, ~30 tools with action parameter.
## Each handler is a RefCounted object with a ``handle(action, params) -> Dictionary`` method.

const _EditorHandler = preload("res://addons/open_godot_mcp/handlers/editor_handler.gd")
const _SceneHandler = preload("res://addons/open_godot_mcp/handlers/scene_handler.gd")
const _NodeHandler = preload("res://addons/open_godot_mcp/handlers/node_handler.gd")
const _ScriptHandler = preload("res://addons/open_godot_mcp/handlers/script_handler.gd")
const _ProjectHandler = preload("res://addons/open_godot_mcp/handlers/project_handler.gd")
const _ResourceHandler = preload("res://addons/open_godot_mcp/handlers/resource_handler.gd")
const _AnimationHandler = preload("res://addons/open_godot_mcp/handlers/animation_handler.gd")
const _TilemapHandler = preload("res://addons/open_godot_mcp/handlers/tilemap_handler.gd")
const _GameHandler = preload("res://addons/open_godot_mcp/handlers/game_handler.gd")
const _InputHandler = preload("res://addons/open_godot_mcp/handlers/input_handler.gd")
const _RuntimeStateHandler = preload("res://addons/open_godot_mcp/handlers/runtime_state_handler.gd")
const _ExecHandler = preload("res://addons/open_godot_mcp/handlers/exec_handler.gd")
const _ScreenshotHandler = preload("res://addons/open_godot_mcp/handlers/screenshot_handler.gd")
const _DebuggerHandler = preload("res://addons/open_godot_mcp/handlers/debugger_handler.gd")
const _LspHandler = preload("res://addons/open_godot_mcp/handlers/lsp_handler.gd")
const _ProfilerHandler = preload("res://addons/open_godot_mcp/handlers/profiler_handler.gd")
const _TestHandler = preload("res://addons/open_godot_mcp/handlers/test_handler.gd")
const _NetworkHandler = preload("res://addons/open_godot_mcp/handlers/network_handler.gd")
const _InstanceHandler = preload("res://addons/open_godot_mcp/handlers/instance_handler.gd")
const _FilesystemHandler = preload("res://addons/open_godot_mcp/handlers/filesystem_handler.gd")
const _AssetHandler = preload("res://addons/open_godot_mcp/handlers/asset_handler.gd")
const _ExportHandler = preload("res://addons/open_godot_mcp/handlers/export_handler.gd")
const _UtilityHandler = preload("res://addons/open_godot_mcp/handlers/utility_handler.gd")
# CsharpHandler loaded at runtime to avoid preload issues
var _CsharpHandler: GDScript = null

var _bridge: Node  # websocket_server.gd
var _handlers: Dictionary = {}  # tool_name -> handler instance
var _handler_scripts: Dictionary = {}  # tool_name -> preload'd GDScript


func _init() -> void:
	_register("godot_editor_read", _EditorHandler)
	_register("godot_editor_edit", _EditorHandler)
	_register("godot_scene", _SceneHandler)
	_register("godot_node_read", _NodeHandler)
	_register("godot_node_edit", _NodeHandler)
	_register("godot_script", _ScriptHandler)
	_register("godot_project", _ProjectHandler)
	_register("godot_input_map", _ProjectHandler)
	_register("godot_resource", _ResourceHandler)
	_register("godot_animation", _AnimationHandler)
	_register("godot_tilemap", _TilemapHandler)
	_register("godot_game", _GameHandler)
	_register("godot_game_time", _GameHandler)
	_register("godot_input", _InputHandler)
	_register("godot_runtime_state", _RuntimeStateHandler)
	_register("godot_exec", _ExecHandler)
	_register("godot_screenshot", _ScreenshotHandler)
	_register("godot_debugger", _DebuggerHandler)
	_register("godot_lsp", _LspHandler)
	_register("godot_profiler", _ProfilerHandler)
	_register("godot_test", _TestHandler)
	_register("godot_network", _NetworkHandler)
	_register("godot_instance", _InstanceHandler)
	_register("godot_filesystem", _FilesystemHandler)
	_register("godot_docs", _FilesystemHandler)
	_register("godot_log", _FilesystemHandler)
	_register("godot_asset", _AssetHandler)
	_register("godot_export", _ExportHandler)
	_register("godot_health", _UtilityHandler)
	# Load csharp handler at runtime (preload may fail if script has issues)
	var csharp_script: GDScript = load("res://addons/open_godot_mcp/handlers/csharp_handler.gd")
	if csharp_script != null:
		_CsharpHandler = csharp_script
		_register("godot_csharp_check", _CsharpHandler)
	else:
		push_error("[MCP] Failed to load csharp_handler.gd")


func _register(tool_name: String, script: GDScript) -> void:
	_handler_scripts[tool_name] = script
	_handlers[tool_name] = script.new()


func set_bridge(bridge: Node) -> void:
	_bridge = bridge
	for tool_name in _handlers:
		if is_instance_valid(_handlers[tool_name]):
			_handlers[tool_name]._bridge = bridge


func dispatch(tool: String, action: String, params: Dictionary) -> Dictionary:
	if not _handler_scripts.has(tool):
		return {"ok": false, "error": {"code": "INVALID_ARGUMENT", "message": "Unknown tool: %s" % tool}}
	var handler: Object = _handlers.get(tool)
	# Re-create handler if the old instance was invalidated by a script reload
	if not is_instance_valid(handler) or not handler.has_method("handle"):
		# Use load() at runtime to get the freshest version of the script
		var script_path: String = _handler_scripts[tool].resource_path
		var script: GDScript = load(script_path)
		if script == null:
			return {"ok": false, "error": {"code": "INTERNAL_ERROR", "message": "Failed to load script: %s" % script_path}}
		handler = script.new()
		_handlers[tool] = handler
		_handler_scripts[tool] = script
	# Always ensure _bridge is set (survives script reloads)
	if _bridge and is_instance_valid(handler) and "_bridge" in handler:
		handler._bridge = _bridge
	if not handler.has_method("handle"):
		return {"ok": false, "error": {"code": "INTERNAL_ERROR", "message": "Handler missing handle()"}}
	var result: Dictionary = await handler.handle(tool, action, params)
	if result == null:
		return {"ok": false, "error": {"code": "INTERNAL_ERROR", "message": "Handler returned null"}}
	return result
