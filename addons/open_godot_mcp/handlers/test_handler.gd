extends RefCounted

## Test handler — godot_test (built-in test framework).
## Docs: 02-Tools/Test.md

const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")

var _bridge: Node
var _last_results: Dictionary = {}


func handle(tool: String, action: String, params: Dictionary) -> Dictionary:
	if action == "list":
		return _list()
	if action == "run":
		return await _run(params)
	if action == "results":
		return _results(params)
	if action == "create":
		return _create(params)
	return _EC.fail("INVALID_ARGUMENT", "Unknown action: %s" % action)


func _list() -> Dictionary:
	var suites := []
	var tests := []
	var d := DirAccess.open("res://tests/")
	if d:
		d.list_dir_begin()
		var file := d.get_next()
		while not file.is_empty():
			if file.ends_with(".gd"):
				var path := "res://tests/" + file
				var script := load(path) as GDScript
				if script:
					var suite_name := file.get_basename()
					var test_count := 0
					var source := script.source_code
					for line in source.split("\n"):
						var stripped := line.strip_edges()
						if stripped.begins_with("func test_"):
							var fname := stripped.substr(5).split("(")[0]
							tests.append({"suite": suite_name, "name": fname})
							test_count += 1
					suites.append({"name": suite_name, "file": path, "test_count": test_count})
			file = d.get_next()
		d.list_dir_end()
	return _EC.ok({"suites": suites, "tests": tests})


func _run(params: Dictionary) -> Dictionary:
	var suite_filter: String = params.get("suite", "")
	var test_name_filter: String = params.get("test_name", "")
	var exclude: Array = params.get("exclude", [])

	var passed := 0
	var failed := 0
	var skipped := 0
	var details := []

	var d := DirAccess.open("res://tests/")
	if d == null:
		_last_results = {"passed": 0, "failed": 0, "skipped": 0, "details": []}
		return _EC.ok({"results": _last_results})

	var suite_files: Array = []
	d.list_dir_begin()
	var file := d.get_next()
	while not file.is_empty():
		if file.ends_with(".gd"):
			suite_files.append(file)
		file = d.get_next()
	d.list_dir_end()

	for sf in suite_files:
		var suite_name: String = sf.get_basename()
		if not suite_filter.is_empty() and suite_name != suite_filter:
			continue
		var path: String = "res://tests/" + sf
		var script := load(path) as GDScript
		if script == null:
			continue
		# Find test methods in source
		var test_methods: Array = []
		for line in script.source_code.split("\n"):
			var stripped := line.strip_edges()
			if stripped.begins_with("func test_"):
				var fname := stripped.substr(5).split("(")[0]
				test_methods.append(fname)
		# Instantiate and run
		for tname in test_methods:
			if not test_name_filter.is_empty() and tname != test_name_filter:
				continue
			if tname in exclude:
				skipped += 1
				details.append({"suite": suite_name, "name": tname, "status": "skipped", "message": "excluded"})
				continue
			var result := await _run_single_test(script, suite_name, tname)
			if result["status"] == "passed":
				passed += 1
			else:
				failed += 1
			details.append(result)

	_last_results = {"passed": passed, "failed": failed, "skipped": skipped, "details": details}
	return _EC.ok({"results": _last_results})


func _run_single_test(script: GDScript, suite_name: String, test_name: String) -> Dictionary:
	var instance: Object = script.new()
	if instance == null:
		return {"suite": suite_name, "name": test_name, "status": "failed", "message": "Failed to instantiate suite"}
	_reset_test_state(instance)
	if instance.has_method("set_up"):
		instance.call("set_up")
		var setup_err := _get_test_error(instance)
		if not setup_err.is_empty():
			if instance.has_method("tear_down"):
				instance.call("tear_down")
			return {"suite": suite_name, "name": test_name, "status": "failed", "message": "set_up: " + setup_err}
	if not instance.has_method(test_name):
		return {"suite": suite_name, "name": test_name, "status": "failed", "message": "Method not found"}
	_reset_test_state(instance)
	var _test_result: Variant = await instance.call(test_name)
	var err_msg := _get_test_error(instance)
	if instance.has_method("tear_down"):
		instance.call("tear_down")
	if not err_msg.is_empty():
		return {"suite": suite_name, "name": test_name, "status": "failed", "message": err_msg}
	return {"suite": suite_name, "name": test_name, "status": "passed"}


func _reset_test_state(instance: Object) -> void:
	if instance.get("_last_error") != null:
		instance.set("_last_error", "")
	if instance.get("_failed") != null:
		instance.set("_failed", false)
	if instance.get("_message") != null:
		instance.set("_message", "")


func _get_test_error(instance: Object) -> String:
	if instance.get("_failed") != null and instance.get("_failed") == true:
		return str(instance.get("_message"))
	if instance.get("_last_error") != null:
		var le := str(instance.get("_last_error"))
		if not le.is_empty():
			return le
	return ""


func _results(params: Dictionary) -> Dictionary:
	var verbose: bool = params.get("verbose", false)
	if _last_results.is_empty():
		return _EC.ok({"results": {"passed": 0, "failed": 0, "skipped": 0, "details": []}})
	if verbose:
		return _EC.ok({"results": _last_results})
	# Non-verbose: only failed and skipped
	var filtered_details := []
	for d in _last_results.get("details", []):
		var status: String = d.get("status", "")
		if status == "failed" or status == "skipped":
			filtered_details.append(d)
	var filtered := {
		"passed": _last_results.get("passed", 0),
		"failed": _last_results.get("failed", 0),
		"skipped": _last_results.get("skipped", 0),
		"details": filtered_details,
	}
	return _EC.ok({"results": filtered})


func _create(params: Dictionary) -> Dictionary:
	var path: String = params.get("path", "")
	var test_name: String = params.get("test_name", "")
	if path.is_empty() or test_name.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "path and test_name required")
	if not path.begins_with("res://tests/"):
		return _EC.fail("INVALID_ARGUMENT", "path must be under res://tests/")
	if not path.ends_with(".gd"):
		return _EC.fail("INVALID_ARGUMENT", "path must end with .gd")
	var content := """extends OgmTestSuite

## Test: %s

func test_%s() -> void:
\tpass
""" % [test_name, test_name]
	var fs_path := ProjectSettings.globalize_path(path)
	var dir := path.get_base_dir()
	var d := DirAccess.open(dir)
	if not d:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var f := FileAccess.open(fs_path, FileAccess.WRITE)
	if not f:
		return _EC.fail("INTERNAL_ERROR", "Cannot write: %s" % fs_path)
	f.store_string(content)
	f.close()
	EditorInterface.get_resource_filesystem().scan()
	return _EC.ok()
