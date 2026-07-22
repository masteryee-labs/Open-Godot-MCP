extends RefCounted

## Screenshot cleanup utility — rotation (keep last N) + expiry (delete older than X hours).
## Shared by editor handler and runtime autoload.
##
## Config (ProjectSettings, user-editable):
##   open_godot_mcp/screenshot_max_count     default 50  (0 = no rotation)
##   open_godot_mcp/screenshot_max_age_hours default 24  (0 = no expiry)

const DEFAULT_MAX_COUNT := 50
const DEFAULT_MAX_AGE_HOURS := 24

const _SETTING_MAX_COUNT := "open_godot_mcp/screenshot_max_count"
const _SETTING_MAX_AGE := "open_godot_mcp/screenshot_max_age_hours"


## Clean up *dir_abs_path*. Pass negative values to fall back to ProjectSettings defaults.
## Returns {deleted_count, remaining_count}.
static func cleanup(dir_abs_path: String, max_count: int = -1, max_age_hours: float = -1.0) -> Dictionary:
	if max_count < 0:
		max_count = int(ProjectSettings.get_setting(_SETTING_MAX_COUNT, DEFAULT_MAX_COUNT))
	if max_age_hours < 0.0:
		max_age_hours = float(ProjectSettings.get_setting(_SETTING_MAX_AGE, DEFAULT_MAX_AGE_HOURS))

	var d := DirAccess.open(dir_abs_path)
	if d == null:
		return {"deleted_count": 0, "remaining_count": 0}

	var files: Array = []
	d.list_dir_begin()
	var fname := d.get_next()
	while fname != "":
		if not d.current_is_dir():
			var fpath := dir_abs_path + "/" + fname
			var mt := FileAccess.get_modified_time(fpath)
			files.append({"path": fpath, "mtime": mt})
		fname = d.get_next()
	d.list_dir_end()

	if files.is_empty():
		return {"deleted_count": 0, "remaining_count": 0}

	files.sort_custom(_cmp_mtime)

	var now := Time.get_unix_time_from_system()
	var deleted := 0

	if max_age_hours > 0.0:
		var cutoff := now - max_age_hours * 3600.0
		var survivors: Array = []
		for f in files:
			if f["mtime"] < cutoff:
				if DirAccess.remove_absolute(f["path"]) == OK:
					deleted += 1
			else:
				survivors.append(f)
		files = survivors

	if max_count > 0 and files.size() > max_count:
		var to_delete := files.size() - max_count
		for i in to_delete:
			if DirAccess.remove_absolute(files[i]["path"]) == OK:
				deleted += 1
		files = files.slice(to_delete)

	return {"deleted_count": deleted, "remaining_count": files.size()}


static func _cmp_mtime(a: Dictionary, b: Dictionary) -> bool:
	return int(a["mtime"]) < int(b["mtime"])
