@tool
extends Control

## MCP Dock — connection status UI, language selector, Agnes/NVIDIA API config,
## and update notification banner.
##
## Agnes/NVIDIA tools are NOT registered in the MCP server unless the user
## enables them here. This prevents AI from using lower-tier vision when the
## model itself has vision capability. Config is stored in the user's home
## folder (~/.open_godot_mcp/config.json), outside any project repo, so API
## keys are never committed accidentally.
##
## Docs: 01-Architecture/Connection-Stability.md §對策 5
##       02-Tools/Agnes-NVIDIA.md

const _PortResolver = preload("res://addons/open_godot_mcp/utils/port_resolver.gd")
const _UpdateManagerScript = preload("res://addons/open_godot_mcp/utils/update_manager.gd")
const _I18n = preload("res://addons/open_godot_mcp/dock/i18n.gd")

const _CONFIG_DIR_NAME = ".open_godot_mcp"
const _CONFIG_FILENAME = "config.json"
const _SETTING_PROJECT_CONFIG = "open_godot_mcp/config/use_project_config"
const _DEFAULT_AGNES_BASE_URL = "https://apihub.agnes-ai.com/v1"
const _DEFAULT_TEXT_MODEL = "agnes-2.0-flash"
const _DEFAULT_IMAGE_MODEL = "agnes-image-2.0-flash"
const _DEFAULT_VIDEO_MODEL = "agnes-video-v2.0"
const _DEFAULT_NVIDIA_VLM_URL = "https://integrate.api.nvidia.com/v1"
const _DEFAULT_NVIDIA_VLM_MODEL = "meta/llama-3.2-90b-vision-instruct"
const _DEFAULT_NVIDIA_IMGGEN_URL = "https://ai.api.nvidia.com/v1/genai"
const _DEFAULT_NVIDIA_IMGGEN_MODEL = "black-forest-labs/flux.2-klein-4b"

var _server: Node = null
var _log_buffer: Array = []
var _log_buffer_max: int = 200
var _update_manager: Node = null
var _i18n: RefCounted = null
var _loading_config: bool = false  # guard against signals firing while we populate UI

@onready var _status_label: Label = $Scroll/VBox/StatusLabel
@onready var _info_label: Label = $Scroll/VBox/InfoLabel
@onready var _reconnect_btn: Button = $Scroll/VBox/ReconnectBtn
@onready var _lang_option: OptionButton = $Scroll/VBox/LangRow/LangOption
@onready var _update_banner: VBoxContainer = $Scroll/VBox/UpdateBanner
@onready var _update_label: Label = $Scroll/VBox/UpdateBanner/UpdateLabel
@onready var _update_btn: Button = $Scroll/VBox/UpdateBanner/UpdateBtnRow/UpdateBtn
@onready var _release_notes_btn: Button = $Scroll/VBox/UpdateBanner/UpdateBtnRow/ReleaseNotesBtn

@onready var _agnes_enable: CheckButton = $Scroll/VBox/AgnesSection/AgnesEnable
@onready var _agnes_key_edit: TextEdit = $Scroll/VBox/AgnesSection/AgnesKeyEdit
@onready var _agnes_vision: CheckButton = $Scroll/VBox/AgnesSection/AgnesVision
@onready var _agnes_image_gen: CheckButton = $Scroll/VBox/AgnesSection/AgnesImageGen
@onready var _agnes_video_gen: CheckButton = $Scroll/VBox/AgnesSection/AgnesVideoGen

@onready var _nvidia_enable: CheckButton = $Scroll/VBox/NvidiaSection/NvidiaEnable
@onready var _nvidia_key_edit: TextEdit = $Scroll/VBox/NvidiaSection/NvidiaKeyEdit
@onready var _nvidia_vision: CheckButton = $Scroll/VBox/NvidiaSection/NvidiaVision
@onready var _nvidia_image_gen: CheckButton = $Scroll/VBox/NvidiaSection/NvidiaImageGen

@onready var _screenshot_title: Label = $Scroll/VBox/ScreenshotSection/ScreenshotTitle
@onready var _max_count_label: Label = $Scroll/VBox/ScreenshotSection/ScreenshotRow1/MaxCountLabel
@onready var _max_count_spin: SpinBox = $Scroll/VBox/ScreenshotSection/ScreenshotRow1/MaxCountSpin
@onready var _max_age_label: Label = $Scroll/VBox/ScreenshotSection/ScreenshotRow2/MaxAgeLabel
@onready var _max_age_spin: SpinBox = $Scroll/VBox/ScreenshotSection/ScreenshotRow2/MaxAgeSpin

@onready var _config_location_title: Label = $Scroll/VBox/ConfigLocationSection/ConfigLocationTitle
@onready var _project_config_check: CheckButton = $Scroll/VBox/ConfigLocationSection/ProjectConfigCheck
@onready var _config_path_label: Label = $Scroll/VBox/ConfigLocationSection/ConfigPathLabel

@onready var _save_btn: Button = $Scroll/VBox/SaveBtn
@onready var _save_status_label: Label = $Scroll/VBox/SaveStatusLabel
@onready var _git_warning_label: Label = $Scroll/VBox/GitWarningLabel
@onready var _config_help_label: Label = $Scroll/VBox/ConfigHelpLabel


func _ready() -> void:
	_i18n = _I18n.new()
	_i18n.language_changed.connect(_on_language_changed)
	_populate_lang_option()
	if _reconnect_btn:
		_reconnect_btn.pressed.connect(_on_reconnect_btn_pressed)
	if _update_btn:
		_update_btn.pressed.connect(_on_update_pressed)
	if _release_notes_btn:
		_release_notes_btn.pressed.connect(_on_release_notes_pressed)
	if _save_btn:
		_save_btn.pressed.connect(_on_save_pressed)
	if _lang_option:
		_lang_option.item_selected.connect(_on_LangOption_item_selected)
	if _project_config_check:
		_project_config_check.toggled.connect(_on_project_config_toggled)
	# Allow buttons/checkbuttons to shrink below text width at narrow dock widths.
	# Without this, long CheckButton labels (e.g. "視覺（看圖，base64 直傳）")
	# force the VBox to their minimum width, causing right-edge clipping.
	_apply_text_overrun($Scroll/VBox)
	_load_config_into_ui()
	_load_screenshot_settings()
	_load_config_location()
	_apply_strings()
	_update_runtime_status()


func _apply_text_overrun(node: Node) -> void:
	if node is Button:
		(node as Button).text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	for child in node.get_children():
		_apply_text_overrun(child)


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


# ---- screenshot settings (ProjectSettings) ----

const _SETTING_MAX_COUNT := "open_godot_mcp/screenshot_max_count"
const _SETTING_MAX_AGE := "open_godot_mcp/screenshot_max_age_hours"


func _load_screenshot_settings() -> void:
	var mc := int(ProjectSettings.get_setting(_SETTING_MAX_COUNT, 50))
	var ma := float(ProjectSettings.get_setting(_SETTING_MAX_AGE, 24.0))
	if _max_count_spin:
		_max_count_spin.value = mc
	if _max_age_spin:
		_max_age_spin.value = ma


func _save_screenshot_settings() -> void:
	var mc := int(_max_count_spin.value) if _max_count_spin else 50
	var ma := float(_max_age_spin.value) if _max_age_spin else 24.0
	ProjectSettings.set_setting(_SETTING_MAX_COUNT, mc)
	ProjectSettings.set_setting(_SETTING_MAX_AGE, ma)
	ProjectSettings.set_as_basic(_SETTING_MAX_COUNT, true)
	ProjectSettings.set_as_basic(_SETTING_MAX_AGE, true)
	ProjectSettings.save()


# ---- config location (EditorSettings) ----

func _load_config_location() -> void:
	var enabled := _is_project_config_enabled()
	if _project_config_check:
		_project_config_check.set_pressed_no_signal(enabled)
	_update_config_path_label()


func _save_config_location() -> void:
	var es := EditorInterface.get_editor_settings()
	if es == null:
		return
	var enabled := _project_config_check.button_pressed if _project_config_check else false
	es.set_setting(_SETTING_PROJECT_CONFIG, enabled)


func _on_project_config_toggled(_pressed: bool) -> void:
	_update_config_path_label()


func _update_config_path_label() -> void:
	if _config_path_label == null:
		return
	var path := _config_path()
	var enabled := _is_project_config_enabled()
	if _project_config_check:
		enabled = _project_config_check.button_pressed
	if _i18n:
		_config_path_label.text = _i18n.t("config_path_label") + path
	else:
		_config_path_label.text = "Path: " + path
	if _config_help_label and _i18n:
		if enabled:
			_config_help_label.text = _i18n.t("config_dir_help_project")
		else:
			_config_help_label.text = _i18n.t("config_dir_help")


# ---- i18n ----


func _populate_lang_option() -> void:
	if _lang_option == null:
		return
	_lang_option.clear()
	var langs: Array[String] = _i18n.available_languages()
	var cur: String = _i18n.current_language()
	var select: int = 0
	for i in range(langs.size()):
		_lang_option.add_item(langs[i], i)
		if langs[i] == cur:
			select = i
	_lang_option.select(select)


func _on_language_changed(_lang: String) -> void:
	_apply_strings()


func _apply_strings() -> void:
	if _i18n == null:
		return
	# Sync the OptionButton to the current language without re-firing the signal.
	if _lang_option:
		var cur: String = _i18n.current_language()
		for i in range(_lang_option.item_count):
			if _lang_option.get_item_text(i) == cur:
				if _lang_option.selected != i:
					_lang_option.selected = i
				break
	if _reconnect_btn:
		_reconnect_btn.text = _i18n.t("reconnect_btn")
	if _save_btn:
		_save_btn.text = _i18n.t("save_btn")
	# Labels
	$Scroll/VBox/Title.text = _i18n.t("title")
	$Scroll/VBox/LangRow/LangLabel.text = _i18n.t("language_label")
	$Scroll/VBox/AgnesSection/AgnesTitle.text = _i18n.t("agnes_section")
	_agnes_enable.text = _i18n.t("agnes_enable")
	$Scroll/VBox/AgnesSection/AgnesKeyLabel.text = _i18n.t("agnes_api_key_label")
	_agnes_key_edit.placeholder_text = _i18n.t("agnes_api_key_placeholder")
	_agnes_vision.text = _i18n.t("agnes_vision")
	_agnes_image_gen.text = _i18n.t("agnes_image_gen")
	_agnes_video_gen.text = _i18n.t("agnes_video_gen")
	$Scroll/VBox/NvidiaSection/NvidiaTitle.text = _i18n.t("nvidia_section")
	_nvidia_enable.text = _i18n.t("nvidia_enable")
	$Scroll/VBox/NvidiaSection/NvidiaKeyLabel.text = _i18n.t("nvidia_api_key_label")
	_nvidia_key_edit.placeholder_text = _i18n.t("nvidia_api_key_placeholder")
	_nvidia_vision.text = _i18n.t("nvidia_vision")
	_nvidia_image_gen.text = _i18n.t("nvidia_image_gen")
	_config_help_label.text = _i18n.t("config_dir_help")
	# Screenshot section
	if _screenshot_title:
		_screenshot_title.text = _i18n.t("screenshot_section")
	if _max_count_label:
		_max_count_label.text = _i18n.t("screenshot_max_count")
	if _max_age_label:
		_max_age_label.text = _i18n.t("screenshot_max_age")
	# Config location section
	if _config_location_title:
		_config_location_title.text = _i18n.t("config_location_section")
	if _project_config_check:
		_project_config_check.text = _i18n.t("project_config_enable")
	_update_config_path_label()
	# Re-render status text (it has a localized prefix)
	if _status_label and not _status_label.text.is_empty():
		var body := _status_label.text.substr(_status_label.text.find(":") + 1).strip_edges()
		_status_label.text = _i18n.t("status_label") + body


# ---- config load/save ----


func _config_path() -> String:
	if _is_project_config_enabled():
		var root := ProjectSettings.globalize_path("res://")
		return root.path_join(_CONFIG_DIR_NAME).path_join(_CONFIG_FILENAME)
	var home := OS.get_environment("USERPROFILE")
	if home.is_empty():
		home = OS.get_environment("HOME")
	if home.is_empty():
		home = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	return home.path_join(_CONFIG_DIR_NAME).path_join(_CONFIG_FILENAME)


func _is_project_config_enabled() -> bool:
	var es := EditorInterface.get_editor_settings()
	if es == null:
		return false
	var v = es.get_setting(_SETTING_PROJECT_CONFIG)
	if v == null:
		return false
	return bool(v)


func _load_config_into_ui() -> void:
	_loading_config = true
	var path := _config_path()
	var cfg: Dictionary = _read_config(path)
	var a: Dictionary = cfg.get("agnes", {})
	var n: Dictionary = cfg.get("nvidia", {})
	_agnes_enable.set_pressed_no_signal(bool(a.get("enabled", false)))
	_agnes_key_edit.text = _keys_to_text(a.get("api_keys", a.get("api_key", "")))
	_agnes_vision.set_pressed_no_signal(bool(a.get("vision", false)))
	_agnes_image_gen.set_pressed_no_signal(bool(a.get("image_generate", false)))
	_agnes_video_gen.set_pressed_no_signal(bool(a.get("video_generate", false)))
	_nvidia_enable.set_pressed_no_signal(bool(n.get("enabled", false)))
	_nvidia_key_edit.text = _keys_to_text(n.get("api_keys", n.get("api_key", "")))
	_nvidia_vision.set_pressed_no_signal(bool(n.get("vision", false)))
	_nvidia_image_gen.set_pressed_no_signal(bool(n.get("image_generate", false)))
	_loading_config = false


func _keys_to_text(val: Variant) -> String:
	if val is Array:
		return "\n".join(val)
	return String(val)


func _read_config(path: String) -> Dictionary:
	var defaults := _default_config()
	if not FileAccess.file_exists(path):
		return defaults
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return defaults
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if parsed == null or not (parsed is Dictionary):
		return defaults
	return _merge(defaults, parsed)


func _default_config() -> Dictionary:
	return {
		"agnes": {
			"enabled": false, "api_keys": [],
			"vision": false, "image_generate": false, "video_generate": false,
			"base_url": _DEFAULT_AGNES_BASE_URL,
			"text_model": _DEFAULT_TEXT_MODEL,
			"image_model": _DEFAULT_IMAGE_MODEL,
			"video_model": _DEFAULT_VIDEO_MODEL,
		},
		"nvidia": {
			"enabled": false, "api_keys": [],
			"vision": false, "image_generate": false,
			"vlm_base_url": _DEFAULT_NVIDIA_VLM_URL,
			"vlm_model": _DEFAULT_NVIDIA_VLM_MODEL,
			"imggen_base_url": _DEFAULT_NVIDIA_IMGGEN_URL,
			"imggen_model": _DEFAULT_NVIDIA_IMGGEN_MODEL,
		},
	}


func _merge(base: Dictionary, override: Dictionary) -> Dictionary:
	var out: Dictionary = base.duplicate(true)
	for k in override:
		var v = override[k]
		if v is Dictionary and out.get(k) is Dictionary:
			out[k] = _merge(out[k], v)
		else:
			out[k] = v
	return out


func _collect_config() -> Dictionary:
	var cfg := _default_config()
	cfg.agnes["enabled"] = _agnes_enable.button_pressed
	cfg.agnes["api_keys"] = _text_to_keys(_agnes_key_edit.text)
	cfg.agnes["vision"] = _agnes_vision.button_pressed
	cfg.agnes["image_generate"] = _agnes_image_gen.button_pressed
	cfg.agnes["video_generate"] = _agnes_video_gen.button_pressed
	cfg.nvidia["enabled"] = _nvidia_enable.button_pressed
	cfg.nvidia["api_keys"] = _text_to_keys(_nvidia_key_edit.text)
	cfg.nvidia["vision"] = _nvidia_vision.button_pressed
	cfg.nvidia["image_generate"] = _nvidia_image_gen.button_pressed
	return cfg


func _text_to_keys(text: String) -> Array:
	var out: Array = []
	for line in text.split("\n"):
		var s: String = line.strip_edges()
		if not s.is_empty():
			out.append(s)
	return out


func _on_save_pressed() -> void:
	if _loading_config:
		return
	var cfg := _collect_config()
	var path := _config_path()
	var dir := path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(dir)
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		_save_status_label.text = _i18n.t("save_failed") + str(FileAccess.get_open_error())
		_save_status_label.add_theme_color_override("font_color", Color.RED)
		return
	f.store_string(JSON.stringify(cfg, "\t"))
	f.close()
	# Restrictive permissions (POSIX no-op on Windows; user-home path is private).
	# Godot has no chmod API; the Python side applies 0o600 on its own writes.
	_check_git_safety(path)
	_save_screenshot_settings()
	_save_config_location()
	_update_config_path_label()
	_save_status_label.text = _i18n.t("saved_status")
	_save_status_label.add_theme_color_override("font_color", Color.GREEN)
	# Notify the MCP server to hot-reload its tool registrations.
	_notify_config_changed()
	# Warn if no MCP server is connected.
	if _server == null or (_server._clients as Array).is_empty():
		_save_status_label.text = _i18n.t("mcp_not_connected_warn")
		_save_status_label.add_theme_color_override("font_color", Color.YELLOW)


func _notify_config_changed() -> void:
	if _server and _server.has_method("send_event"):
		_server.send_event("agnes_config_changed", {"config_path": _config_path()})


# ---- git safety (warn only; never auto-modify .gitignore) ----


func _check_git_safety(path: String) -> void:
	_git_warning_label.visible = false
	_git_warning_label.text = ""
	var abs_path := ProjectSettings.globalize_path(path)
	# Walk parents looking for a .git directory.
	var dir := abs_path.get_base_dir()
	var found_git := false
	for _i in range(32):  # bounded walk
		if dir.is_empty():
			break
		var git_dir := dir.path_join(".git")
		if DirAccess.dir_exists_absolute(git_dir):
			found_git = true
			break
		var parent := dir.get_base_dir()
		if parent == dir:
			break
		dir = parent
	if not found_git:
		return
	# We are inside a git repo. Check whether .gitignore covers us (best-effort).
	# Godot has no gitignore parser; we just warn — the user is responsible.
	_git_warning_label.text = (
		_i18n.t("git_warning") + ": " + _i18n.t("git_warning_in_repo") + "\n"
		+ _i18n.t("git_warning_help")
	)
	_git_warning_label.add_theme_color_override("font_color", Color.ORANGE)
	_git_warning_label.visible = true


# ---- status / reconnect ----


func _on_status_changed(text: String) -> void:
	_update_status(text)
	_log("bridge: " + text)


func _update_status(text: String) -> void:
	if _status_label:
		_status_label.text = _i18n.t("status_label") + text if _i18n else ("Status: " + text)
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


# ---- language OptionButton ----


func _on_LangOption_item_selected(index: int) -> void:
	if _i18n == null or _lang_option == null:
		return
	var lang := _lang_option.get_item_text(index)
	_i18n.set_language(lang)


# ---- update banner ----


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
