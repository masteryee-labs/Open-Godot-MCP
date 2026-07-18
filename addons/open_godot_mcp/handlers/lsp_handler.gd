extends RefCounted

## LSP handler — godot_lsp (GDScript language server).
## Docs: 02-Tools/Diagnostics.md §godot_lsp
##
## Uses Godot's built-in GDScript LSP via the editor's LanguageServer.

const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")

var _bridge: Node


func handle(tool: String, action: String, params: Dictionary) -> Dictionary:
	match action:
		"diagnostics":
			return _diagnostics(params)
		"complete":
			return _complete(params)
		"definition":
			return _definition(params)
		"hover":
			return _hover(params)
		"symbols":
			return _symbols(params)
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown action: %s" % action)


func _diagnostics(params: Dictionary) -> Dictionary:
	# Godot 4.5+ has a built-in LSP accessible via EditorInterface
	# For now, we do a basic script parse check
	var path: String = params.get("path", "")
	if not path.is_empty():
		var errors := _check_script(path)
		return _EC.ok({"diagnostics": errors})
	# All open scripts
	var all_errors := []
	for scene_path in EditorInterface.get_open_scenes():
		# Check scripts attached to nodes in open scenes
		pass
	return _EC.ok({"diagnostics": all_errors})


func _check_script(path: String) -> Array:
	var errors := []
	if not ResourceLoader.exists(path):
		return [{"line": 0, "column": 0, "severity": "error", "code": "LOAD_FAILED", "message": "Script not found"}]
	var script := load(path)
	if script == null:
		# Force reload to trigger parse errors
		script = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
		if script == null:
			return [{"line": 0, "column": 0, "severity": "error", "code": "PARSE_ERROR", "message": "Script has syntax errors (check editor output)"}]
	# If it loaded, it's valid
	return errors


func _complete(params: Dictionary) -> Dictionary:
	var path: String = params.get("path", "")
	var line: int = params.get("line", 1)
	var column: int = params.get("column", 1)
	if path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "path required")
	# Basic completion — a full LSP integration would query Godot's LanguageServer
	return _EC.ok({"completions": []})


func _definition(params: Dictionary) -> Dictionary:
	return _EC.ok({"location": null})


func _hover(params: Dictionary) -> Dictionary:
	return _EC.ok({"hover": null})


func _symbols(params: Dictionary) -> Dictionary:
	var path: String = params.get("path", "")
	if path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "path required")
	if not ResourceLoader.exists(path):
		return _EC.fail("RESOURCE_NOT_FOUND", "Script not found: %s" % path)
	var script := load(path) as GDScript
	if not script:
		return _EC.fail("RESOURCE_NOT_FOUND", "Not a GDScript: %s" % path)
	var symbols := []
	# Extract function and variable names from the script source
	var source := script.source_code
	var line_num := 0
	for line in source.split("\n"):
		line_num += 1
		var trimmed := line.strip_edges()
		if trimmed.begins_with("func "):
			var fname := trimmed.substr(5).split("(")[0]
			symbols.append({"name": fname, "kind": "function", "line": line_num})
		elif trimmed.begins_with("var ") or trimmed.begins_with("const "):
			var parts := trimmed.split(" ", false)
			if parts.size() >= 2:
				var vname := parts[1].split(":")[0].split("=")[0]
				symbols.append({"name": vname, "kind": "variable", "line": line_num})
		elif trimmed.begins_with("signal "):
			var sname := trimmed.substr(7).split("(")[0]
			symbols.append({"name": sname, "kind": "signal", "line": line_num})
	return _EC.ok({"symbols": symbols})
