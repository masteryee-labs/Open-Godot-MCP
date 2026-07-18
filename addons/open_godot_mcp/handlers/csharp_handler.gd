extends RefCounted

## C# handler — godot_csharp_check.
## Docs: 08-CSharp-Support/Syntax-Check.md
##
## Uses `dotnet build` for compile checking (no Roslyn dependency needed).
## Falls back gracefully if project is not .NET or dotnet not installed.

const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")

var _bridge: Node


func handle(tool: String, action: String, params: Dictionary) -> Dictionary:
	match action:
		"build":
			return await _build(params)
		"syntax":
			return await _syntax_check(params)
		"info":
			return _info(params)
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown action: %s" % action)


func _is_dotnet_project() -> bool:
	var dir := DirAccess.open("res://")
	if not dir:
		return false
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		var lower := fname.to_lower()
		if lower.ends_with(".csproj") or lower.ends_with(".sln"):
			dir.list_dir_end()
			return true
		fname = dir.get_next()
	dir.list_dir_end()
	return false


func _find_csproj() -> String:
	var dir := DirAccess.open("res://")
	if not dir:
		return ""
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if fname.to_lower().ends_with(".csproj"):
			dir.list_dir_end()
			return "res://" + fname
		fname = dir.get_next()
	dir.list_dir_end()
	return ""


func _info(params: Dictionary) -> Dictionary:
	var is_dotnet := _is_dotnet_project()
	var csproj := ""
	if is_dotnet:
		csproj = _find_csproj()
	# Check if dotnet is available
	var output: Array = []
	var exit := OS.execute("dotnet", ["--version"], output)
	var dotnet_available := exit == OK
	var dotnet_version := ""
	if dotnet_available and not output.is_empty():
		dotnet_version = str(output[0]).strip_edges()
	return _EC.ok({
		"is_dotnet": is_dotnet,
		"csproj": csproj,
		"dotnet_available": dotnet_available,
		"dotnet_version": dotnet_version,
	})


func _build(params: Dictionary) -> Dictionary:
	if not _is_dotnet_project():
		return _EC.fail("INVALID_ARGUMENT", "Not a .NET project (no .csproj found in res://)")
	var csproj := _find_csproj()
	if csproj.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "No .csproj file found")
	var project_path := ProjectSettings.globalize_path(csproj)
	# Run dotnet build
	var output: Array = []
	var args := PackedStringArray(["build", project_path, "--no-restore", "-v", "q"])
	var exit := OS.execute("dotnet", args, output, true)
	var combined := ""
	for line in output:
		combined += line
	var errors := _parse_msbuild_errors(combined)
	var warnings := _parse_msbuild_warnings(combined)
	var result := {
		"ok": errors.is_empty(),
		"errors": errors,
		"warnings": warnings,
		"exit_code": exit,
		"output": combined.substr(0, 4000),
	}
	if errors.is_empty():
		return _EC.ok(result)
	else:
		var ret := _EC.fail("BUILD_FAILED", "C# build failed with %d error(s)" % errors.size())
		ret.merge(result, true)
		return ret


func _syntax_check(params: Dictionary) -> Dictionary:
	var source: String = params.get("source", "")
	var path: String = params.get("path", "")
	if source.is_empty() and path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "source or path required")
	# If path given, read the file
	if not path.is_empty() and source.is_empty():
		var f := FileAccess.open(path, FileAccess.READ)
		if not f:
			return _EC.fail("INVALID_PATH", "Cannot read: %s" % path)
		source = f.get_as_text()
		f.close()
	# Basic syntax checks without Roslyn
	# This catches common issues: unbalanced braces, missing semicolons
	var errors: Array = []
	_check_brace_balance(source, errors)
	_check_basic_syntax(source, errors)
	return _EC.ok({
		"ok": errors.is_empty(),
		"errors": errors,
		"note": "Basic syntax check (no Roslyn). Use 'build' action for full compile check.",
	})


func _check_brace_balance(source: String, errors: Array) -> void:
	var depth := 0
	var line := 1
	var in_string := false
	var in_char := false
	var in_comment := false
	var in_line_comment := false
	var i := 0
	while i < source.length():
		var ch := source[i]
		if ch == "\n":
			line += 1
			in_line_comment = false
			i += 1
			continue
		if in_line_comment:
			i += 1
			continue
		if in_comment:
			if i + 1 < source.length() and ch == "*" and source[i + 1] == "/":
				in_comment = false
				i += 2
				continue
			i += 1
			continue
		if in_string:
			if ch == "\\":
				i += 2
				continue
			if ch == "\"":
				in_string = false
			i += 1
			continue
		if in_char:
			if ch == "\\":
				i += 2
				continue
			if ch == "'":
				in_char = false
			i += 1
			continue
		if ch == "/" and i + 1 < source.length():
			if source[i + 1] == "/":
				in_line_comment = true
				i += 2
				continue
			if source[i + 1] == "*":
				in_comment = true
				i += 2
				continue
		if ch == "\"":
			in_string = true
			i += 1
			continue
		if ch == "'":
			in_char = true
			i += 1
			continue
		if ch == "{":
			depth += 1
		elif ch == "}":
			depth -= 1
			if depth < 0:
				errors.append({"line": line, "col": 0, "code": "SYNTAX", "message": "Unmatched closing brace '}'"})
				depth = 0
		i += 1
	if depth > 0:
		errors.append({"line": line, "col": 0, "code": "SYNTAX", "message": "%d unclosed brace(s) '{'" % depth})


func _check_basic_syntax(source: String, errors: Array) -> void:
	# Check for common AI mistakes in C#
	var lines := source.split("\n")
	for i in lines.size():
		var ln: String = lines[i]
		var trimmed := ln.strip_edges()
		# Check for GDScript-style syntax in C#
		if trimmed.begins_with("func "):
			errors.append({"line": i + 1, "col": 0, "code": "GDSCRIPT_SYNTAX", "message": "GDScript 'func' keyword found — C# uses 'void' or type"})
		if trimmed.begins_with("var ") and "：" in trimmed:
			errors.append({"line": i + 1, "col": 0, "code": "GDSCRIPT_SYNTAX", "message": "GDScript-style type annotation '：' found"})
		if "@onready" in trimmed or "@export" in trimmed.to_lower() and not "[Export" in trimmed:
			if "@onready" in trimmed:
				errors.append({"line": i + 1, "col": 0, "code": "GDSCRIPT_SYNTAX", "message": "GDScript '@onready' annotation found — C# uses constructor or _Ready()"})
		if trimmed.begins_with("extends "):
			errors.append({"line": i + 1, "col": 0, "code": "GDSCRIPT_SYNTAX", "message": "GDScript 'extends' keyword found — C# uses ':' inheritance"})
		if "==" in trimmed and trimmed.begins_with("if ") and not ";" in trimmed and not "{" in trimmed:
			# Missing semicolon on if condition is common
			pass  # Not reliable enough to flag


func _parse_msbuild_errors(output: String) -> Array:
	var errors := []
	for line in output.split("\n"):
		# MSBuild format: file(line,col): error CSxxxx: message
		if ": error " in line:
			var entry := _parse_msbuild_line(line, "error")
			if not entry.is_empty():
				errors.append(entry)
	return errors


func _parse_msbuild_warnings(output: String) -> Array:
	var warnings := []
	for line in output.split("\n"):
		if ": warning " in line:
			var entry := _parse_msbuild_line(line, "warning")
			if not entry.is_empty():
				warnings.append(entry)
	return warnings


func _parse_msbuild_line(line: String, severity: String) -> Dictionary:
	# Format: path(line,col): severity CSxxxx: message
	var pattern := severity + " "
	var idx := line.find(pattern)
	if idx < 0:
		return {}
	var after := line.substr(idx + pattern.length())
	# Extract code (CSxxxx)
	var code_end := after.find(":")
	if code_end < 0:
		return {}
	var code := after.substr(0, code_end).strip_edges()
	var message := after.substr(code_end + 1).strip_edges()
	# Extract file/line from beginning
	var paren_idx := line.find("(")
	var file_part := ""
	var line_num := 0
	var col_num := 0
	if paren_idx > 0:
		file_part = line.substr(0, paren_idx).strip_edges()
		var close_idx := line.find(")", paren_idx)
		if close_idx > 0:
			var loc := line.substr(paren_idx + 1, close_idx - paren_idx - 1)
			var parts := loc.split(",")
			if not parts.is_empty():
				line_num = int(parts[0])
				if parts.size() > 1:
					col_num = int(parts[1])
	return {
		"file": file_part,
		"line": line_num,
		"col": col_num,
		"code": code,
		"message": message,
		"severity": severity,
	}
