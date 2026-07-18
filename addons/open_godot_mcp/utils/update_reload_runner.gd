@tool
extends Node

## Self-update reload runner for Open Godot MCP.
##
## Owns the install-and-reload sequence from start(zip_path, temp_dir, dock)
## onward: extract files into addons/open_godot_mcp/ with rollback bookkeeping,
## scan the filesystem, re-enable the plugin, and clean up the detached dock.
##
## This node is deliberately tiny and not parented under the EditorPlugin:
## it survives set_plugin_enabled(false), extracts the downloaded release,
## waits for Godot's filesystem scan, then enables the plugin again.

const PLUGIN_CFG_PATH := "res://addons/open_godot_mcp/plugin.cfg"
const PRE_DISABLE_DRAIN_FRAMES := 8
const POST_DISABLE_DRAIN_FRAMES := 2
const POST_ENABLE_FREE_FRAMES := 8
const INSTALL_BASE_PATH := "res://"
const ZIP_ADDON_PREFIX := "addons/open_godot_mcp/"
const TEMP_FILE_SUFFIX := ".ogm_update_tmp"
const INSTALL_BACKUP_SUFFIX := ".update_backup"
const SCAN_WATCHDOG_SECS := 30.0

enum InstallStatus { OK, FAILED_CLEAN, FAILED_MIXED }

var _zip_path := ""
var _temp_dir := ""
var _detached_dock = null
var _started := false
var _next_step := ""
var _frames_remaining := 0
var _waiting_for_scan := false
var _scan_next_step := ""
var _scan_watchdog_timer = null
var _scan_timed_out := false
var _new_file_paths = []
var _existing_file_paths = []
var _paths_written = []
var _restore_failed := false


func start(zip_path: String, temp_dir: String, detached_dock) -> void:
	if _started:
		return
	_started = true
	_zip_path = zip_path
	_temp_dir = temp_dir
	_detached_dock = detached_dock
	_wait_frames(PRE_DISABLE_DRAIN_FRAMES, "_disable_old_plugin")


func _process(_delta: float) -> void:
	if _frames_remaining <= 0:
		set_process(false)
		return
	_frames_remaining -= 1
	if _frames_remaining <= 0:
		var step := _next_step
		_next_step = ""
		set_process(false)
		call(step)


func _wait_frames(frame_count: int, next_step: String) -> void:
	_next_step = next_step
	_frames_remaining = max(1, frame_count)
	set_process(true)


func _disable_old_plugin() -> void:
	print("[Open Godot MCP] update runner disabling old plugin")
	EditorInterface.set_plugin_enabled(PLUGIN_CFG_PATH, false)
	_wait_frames(POST_DISABLE_DRAIN_FRAMES, "_extract_and_scan")


func _extract_and_scan() -> void:
	if not _read_update_manifest():
		EditorInterface.set_plugin_enabled(PLUGIN_CFG_PATH, true)
		_wait_frames(POST_ENABLE_FREE_FRAMES, "_cleanup_and_finish")
		return

	var install_paths := []
	install_paths.append_array(_new_file_paths)
	install_paths.append_array(_existing_file_paths)

	var status := _install_zip_paths(install_paths)
	if status != InstallStatus.OK:
		_handle_install_failure(status)
		return

	_finalize_install_success()
	_cleanup_update_temp()
	_start_filesystem_scan("_enable_new_plugin")


func _start_filesystem_scan(next_step: String = "_enable_new_plugin") -> void:
	var fs := EditorInterface.get_resource_filesystem()
	var deferred_step := next_step if not next_step.is_empty() else "_enable_new_plugin"
	if fs == null:
		call_deferred(deferred_step)
		return

	if _scan_timed_out:
		call_deferred(deferred_step)
		return

	_waiting_for_scan = true
	_scan_next_step = deferred_step
	if not fs.filesystem_changed.is_connected(_on_filesystem_changed):
		fs.filesystem_changed.connect(_on_filesystem_changed, CONNECT_ONE_SHOT)
	_arm_scan_watchdog()
	fs.scan()


func _arm_scan_watchdog() -> void:
	if _scan_watchdog_timer == null:
		_scan_watchdog_timer = Timer.new()
		_scan_watchdog_timer.one_shot = true
		_scan_watchdog_timer.timeout.connect(_on_scan_watchdog_timeout)
		add_child(_scan_watchdog_timer)
	_scan_watchdog_timer.start(SCAN_WATCHDOG_SECS)


func _stop_scan_watchdog() -> void:
	if _scan_watchdog_timer != null:
		_scan_watchdog_timer.stop()


func _on_scan_watchdog_timeout() -> void:
	if not _waiting_for_scan:
		return
	push_warning(
		"[Open Godot MCP] filesystem_changed didn't fire within %ds; proceeding without scan confirmation"
		% int(SCAN_WATCHDOG_SECS)
	)
	_scan_timed_out = true
	var fs := EditorInterface.get_resource_filesystem()
	if fs != null and fs.filesystem_changed.is_connected(_on_filesystem_changed):
		fs.filesystem_changed.disconnect(_on_filesystem_changed)
	_finish_scan_wait()


func _read_update_manifest() -> bool:
	var zip_path := ProjectSettings.globalize_path(_zip_path)
	var install_base := ProjectSettings.globalize_path(INSTALL_BASE_PATH)

	var reader := ZIPReader.new()
	if reader.open(zip_path) != OK:
		print("[Open Godot MCP] update extract failed: could not open %s" % zip_path)
		return false

	_new_file_paths.clear()
	_existing_file_paths.clear()
	var has_plugin_cfg := false
	var has_plugin_script := false
	var files := reader.get_files()
	for file_path in files:
		if not file_path.begins_with(ZIP_ADDON_PREFIX):
			continue
		var rel_path := file_path.trim_prefix(ZIP_ADDON_PREFIX)
		if rel_path.is_empty() or file_path.ends_with("/"):
			continue
		if not _is_safe_zip_addon_file(file_path):
			print("[Open Godot MCP] update extract failed: unsafe zip path %s" % file_path)
			reader.close()
			return false
		if rel_path == "plugin.cfg":
			has_plugin_cfg = true
		elif rel_path == "plugin.gd":
			has_plugin_script = true
		var target_path := install_base.path_join(file_path)
		if FileAccess.file_exists(target_path):
			_existing_file_paths.append(file_path)
		else:
			_new_file_paths.append(file_path)
	reader.close()
	if not has_plugin_cfg:
		print("[Open Godot MCP] update extract failed: zip is missing plugin.cfg")
		return false
	if not has_plugin_script:
		print("[Open Godot MCP] update extract failed: zip is missing plugin.gd")
		return false
	return true


func _handle_install_failure(status: int) -> void:
	if status == InstallStatus.FAILED_MIXED:
		push_error(
			"[Open Godot MCP] self-update failed mid-install AND rollback could not"
			+ " restore the previous addons/open_godot_mcp/ contents. The plugin"
			+ " is left disabled. Inspect addons/open_godot_mcp/ for"
			+ " *.update_backup / *.ogm_update_tmp files and restore"
			+ " manually before re-enabling the plugin."
		)
		print("[Open Godot MCP] self-update aborted: mixed state; plugin left disabled.")
		_wait_frames(POST_ENABLE_FREE_FRAMES, "_cleanup_and_finish")
		return
	print("[Open Godot MCP] self-update rolled back; re-enabling previous plugin version")
	EditorInterface.set_plugin_enabled(PLUGIN_CFG_PATH, true)
	_wait_frames(POST_ENABLE_FREE_FRAMES, "_cleanup_and_finish")


func _is_safe_zip_addon_file(file_path: String) -> bool:
	if file_path.is_absolute_path() or file_path.contains("\\"):
		return false
	if not file_path.begins_with(ZIP_ADDON_PREFIX):
		return false
	var rel_path := file_path.trim_prefix(ZIP_ADDON_PREFIX)
	if rel_path.is_empty() or rel_path.ends_with("/"):
		return false
	if rel_path.ends_with(TEMP_FILE_SUFFIX) or rel_path.ends_with(INSTALL_BACKUP_SUFFIX):
		return false
	for segment in rel_path.split("/", true):
		if segment.is_empty() or segment == "." or segment == "..":
			return false
	return true


func _install_zip_paths(paths: Array) -> int:
	if paths.is_empty():
		return InstallStatus.OK

	var zip_path := ProjectSettings.globalize_path(_zip_path)
	var reader := ZIPReader.new()
	if reader.open(zip_path) != OK:
		print("[Open Godot MCP] update extract failed: could not reopen %s" % zip_path)
		return _rollback_paths_written()

	var install_base := ProjectSettings.globalize_path(INSTALL_BASE_PATH)
	for file_path in paths:
		var record := _install_zip_file(reader, String(file_path), install_base)
		if record.is_empty():
			reader.close()
			return _rollback_paths_written()
		_paths_written.append(record)
	reader.close()
	return InstallStatus.OK


func _install_zip_file(
	reader: ZIPReader, file_path: String, install_base: String
) -> Dictionary:
	var target_path := install_base.path_join(file_path)
	var dir := target_path.get_base_dir()
	if DirAccess.make_dir_recursive_absolute(dir) != OK:
		print("[Open Godot MCP] update extract failed: could not create %s" % dir)
		return {}

	var temp_path := target_path + TEMP_FILE_SUFFIX
	DirAccess.remove_absolute(temp_path)
	var content := reader.read_file(file_path)
	var f := FileAccess.open(temp_path, FileAccess.WRITE)
	if f == null:
		print("[Open Godot MCP] update extract failed: could not write %s (error %d)" % [
			temp_path,
			FileAccess.get_open_error(),
		])
		return {}
	var stored := f.store_buffer(content)
	f.flush()
	var write_error := f.get_error()
	f.close()
	var written_size := -1
	var verify := FileAccess.open(temp_path, FileAccess.READ)
	if verify != null:
		written_size = verify.get_length()
		verify.close()
	if not stored or write_error != OK or written_size != content.size():
		print("[Open Godot MCP] update extract failed: write validation failed for %s" % target_path)
		DirAccess.remove_absolute(temp_path)
		return {}

	var had_original := FileAccess.file_exists(target_path)
	var backup_path := target_path + INSTALL_BACKUP_SUFFIX
	if had_original:
		DirAccess.remove_absolute(backup_path)
		if DirAccess.copy_absolute(target_path, backup_path) != OK:
			DirAccess.remove_absolute(temp_path)
			print("[Open Godot MCP] update extract failed: could not back up %s" % target_path)
			return {}

	if DirAccess.rename_absolute(temp_path, target_path) != OK:
		DirAccess.remove_absolute(target_path)
		if DirAccess.rename_absolute(temp_path, target_path) != OK:
			DirAccess.remove_absolute(temp_path)
			if had_original:
				if (
					FileAccess.file_exists(backup_path)
					and DirAccess.copy_absolute(backup_path, target_path) == OK
				):
					DirAccess.remove_absolute(backup_path)
				else:
					_restore_failed = true
			print("[Open Godot MCP] update extract failed: could not replace %s" % target_path)
			return {}
	return {
		"target_path": target_path,
		"backup_path": backup_path,
		"had_original": had_original,
	}


func _rollback_paths_written() -> int:
	var any_failed := false
	var i := _paths_written.size() - 1
	while i >= 0:
		var record = _paths_written[i]
		var target := String(record.get("target_path", ""))
		var backup := String(record.get("backup_path", ""))
		var had_original := bool(record.get("had_original", false))
		if had_original:
			if not FileAccess.file_exists(backup):
				print("[Open Godot MCP] update rollback failed: backup missing for %s" % target)
				any_failed = true
			else:
				DirAccess.remove_absolute(target)
				if DirAccess.copy_absolute(backup, target) != OK:
					print("[Open Godot MCP] update rollback failed: could not restore %s" % target)
					any_failed = true
				else:
					DirAccess.remove_absolute(backup)
		else:
			if FileAccess.file_exists(target):
				if DirAccess.remove_absolute(target) != OK:
					print("[Open Godot MCP] update rollback failed: could not delete %s" % target)
					any_failed = true
		i -= 1
	_paths_written.clear()
	if any_failed or _restore_failed:
		return InstallStatus.FAILED_MIXED
	return InstallStatus.FAILED_CLEAN


func _finalize_install_success() -> void:
	for record in _paths_written:
		if record.get("had_original", false):
			DirAccess.remove_absolute(String(record.get("backup_path", "")))
	_paths_written.clear()


func _cleanup_update_temp() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(_zip_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(_temp_dir))


func _on_filesystem_changed() -> void:
	_finish_scan_wait()


func _finish_scan_wait() -> void:
	if not _waiting_for_scan:
		return
	_waiting_for_scan = false
	_stop_scan_watchdog()
	var next_step := _scan_next_step
	_scan_next_step = ""
	set_process(false)
	if next_step.is_empty():
		next_step = "_enable_new_plugin"
	call_deferred(next_step)


func _enable_new_plugin() -> void:
	print("[Open Godot MCP] update runner enabling new plugin")
	EditorInterface.set_plugin_enabled(PLUGIN_CFG_PATH, true)
	_wait_frames(POST_ENABLE_FREE_FRAMES, "_cleanup_and_finish")


func _cleanup_and_finish() -> void:
	_cleanup_detached_dock()
	queue_free()


func _cleanup_detached_dock() -> void:
	if _detached_dock != null and is_instance_valid(_detached_dock):
		_detached_dock.queue_free()
	_detached_dock = null
