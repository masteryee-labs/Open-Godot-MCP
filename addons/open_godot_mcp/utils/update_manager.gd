@tool
class_name McpUpdateManager
extends Node

## Self-update manager for Open Godot MCP.
##
## Checks GitHub Releases for a newer version, downloads the plugin ZIP,
## and hands off to update_reload_runner.gd for extract + plugin reload.
##
## The dock owns banner rendering and forwards button clicks. The split
## exists because the dock script is one of the files overwritten on disk
## during install — keeping pipeline state on a separate Node lets the dock
## tear down cleanly without losing the in-flight gate.

const RELEASES_URL := (
	"https://api.github.com/repos/masteryee-labs/Open-Godot-MCP/releases/latest"
)
const RELEASES_PAGE := "https://github.com/masteryee-labs/Open-Godot-MCP/releases/latest"
const UPDATE_TEMP_DIR := "user://open_godot_mcp_update/"
const UPDATE_TEMP_ZIP := "user://open_godot_mcp_update/update.zip"
const PLUGIN_CFG_PATH := "res://addons/open_godot_mcp/plugin.cfg"

## Host -> required path prefix for self-update downloads.
const _TRUSTED_DOWNLOAD_HOSTS := {
	"github.com": "/masteryee-labs/Open-Godot-MCP/releases/download/",
	"www.github.com": "/masteryee-labs/Open-Godot-MCP/releases/download/",
	"objects.githubusercontent.com": "/github-production-release-asset-",
	"release-assets.githubusercontent.com": "/github-production-release-asset-",
}

## Emitted after check_for_updates() resolves a newer remote version.
signal update_check_completed(result: Dictionary)

## Emitted at every UI-relevant step of the install pipeline.
signal install_state_changed(state: Dictionary)

var _plugin
var _dock

var _http_request: HTTPRequest
var _download_request: HTTPRequest
var _latest_download_url: String = ""
var _latest_remote_version: String = ""
var _install_in_flight: bool = false


# ---- Setup -------------------------------------------------------------

func setup(plugin, dock) -> void:
	_plugin = plugin
	_dock = dock


# ---- Public API --------------------------------------------------------

func check_for_updates() -> void:
	if _http_request == null:
		_http_request = HTTPRequest.new()
		_http_request.request_completed.connect(_on_update_check_completed)
		add_child(_http_request)
	_http_request.request(RELEASES_URL, ["Accept: application/vnd.github+json"])


func cancel_check() -> void:
	if _http_request != null:
		_http_request.cancel_request()


func is_install_in_flight() -> bool:
	return _install_in_flight


# ---- Version helpers ---------------------------------------------------

static func get_plugin_version() -> String:
	var cfg := ConfigFile.new()
	if cfg.load(PLUGIN_CFG_PATH) == OK:
		return String(cfg.get_value("plugin", "version", "0.0.0"))
	return "0.0.0"


static func _is_newer(remote: String, local: String) -> bool:
	var r := remote.split(".")
	var l := local.split(".")
	for i in range(max(r.size(), l.size())):
		var rv := int(r[i]) if i < r.size() else 0
		var lv := int(l[i]) if i < l.size() else 0
		if rv > lv:
			return true
		if rv < lv:
			return false
	return false


# ---- Releases-API parse (pure, testable) -------------------------------

static func parse_releases_response(
	result: int, response_code: int, body: PackedByteArray
) -> Dictionary:
	var out := {
		"has_update": false,
		"version": "",
		"label_text": "",
		"download_url": "",
	}
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		return out
	var parsed = JSON.parse_string(body.get_string_from_utf8())
	if parsed == null or not (parsed is Dictionary):
		return out
	var json: Dictionary = parsed
	var tag: String = String(json.get("tag_name", ""))
	if tag.is_empty():
		return out
	var remote_version := tag.trim_prefix("v")
	var local_version := get_plugin_version()
	if not _is_newer(remote_version, local_version):
		return out

	var url := ""
	var assets: Array = json.get("assets", [])
	for asset in assets:
		var asset_dict: Dictionary = asset
		var asset_name := String(asset_dict.get("name", ""))
		if asset_name == "open-godot-mcp-plugin.zip":
			url = String(asset_dict.get("browser_download_url", ""))

	var label_text := "Update available: v%s" % remote_version

	out["has_update"] = true
	out["version"] = remote_version
	out["label_text"] = label_text
	out["download_url"] = url
	return out


# ---- URL trust guard ---------------------------------------------------

static func _is_trusted_download_url(url: String) -> bool:
	const SCHEME := "https://"
	if not url.begins_with(SCHEME):
		return false
	if url.find("\\") >= 0:
		return false
	var rest := url.substr(SCHEME.length())
	var authority := rest
	var path := ""
	var slash := rest.find("/")
	if slash >= 0:
		authority = rest.substr(0, slash)
		path = rest.substr(slash)
	var at := authority.rfind("@")
	if at >= 0:
		authority = authority.substr(at + 1)
	var colon := authority.find(":")
	if colon >= 0:
		authority = authority.substr(0, colon)
	var host := authority.to_lower()
	if not _TRUSTED_DOWNLOAD_HOSTS.has(host):
		return false
	var qmark := path.find("?")
	if qmark >= 0:
		path = path.substr(0, qmark)
	var lower_path := path.to_lower()
	for needle in ["/../", "/..", "%2e", "%2f", "%5c"]:
		if lower_path.contains(needle):
			return false
	return path.begins_with(String(_TRUSTED_DOWNLOAD_HOSTS[host]))


# ---- HTTPRequest callbacks ---------------------------------------------

func _on_update_check_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	var parsed := parse_releases_response(result, response_code, body)
	if not bool(parsed.get("has_update", false)):
		return
	_latest_download_url = String(parsed.get("download_url", ""))
	_latest_remote_version = String(parsed.get("version", ""))
	update_check_completed.emit(parsed)


# ---- Install pipeline --------------------------------------------------

func start_install() -> void:
	if _latest_download_url.is_empty():
		OS.shell_open(RELEASES_PAGE)
		return

	if not _is_trusted_download_url(_latest_download_url):
		push_error(
			"[Open Godot MCP] refusing self-update download from untrusted URL: %s"
			% _latest_download_url
		)
		OS.shell_open(RELEASES_PAGE)
		install_state_changed.emit({
			"button_text": "Update via download page",
			"button_disabled": false,
		})
		return

	install_state_changed.emit({
		"button_text": "Downloading...",
		"button_disabled": true,
	})

	if _download_request != null:
		_download_request.queue_free()
	_download_request = HTTPRequest.new()
	var global_zip := ProjectSettings.globalize_path(UPDATE_TEMP_ZIP)
	var global_dir := ProjectSettings.globalize_path(UPDATE_TEMP_DIR)
	DirAccess.make_dir_recursive_absolute(global_dir)
	_download_request.download_file = global_zip
	_download_request.max_redirects = 10
	_download_request.request_completed.connect(_on_download_completed)
	add_child(_download_request)
	var err := _download_request.request(_latest_download_url)
	if err != OK:
		_download_request.queue_free()
		_download_request = null
		DirAccess.remove_absolute(global_zip)
		install_state_changed.emit({
			"button_text": "Request failed",
			"button_disabled": false,
		})


func _on_download_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	_body: PackedByteArray
) -> void:
	if _download_request != null:
		_download_request.queue_free()
		_download_request = null

	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		print("[Open Godot MCP] update download failed: result=%d code=%d" % [result, response_code])
		DirAccess.remove_absolute(ProjectSettings.globalize_path(UPDATE_TEMP_ZIP))
		install_state_changed.emit({
			"button_text": "Download failed (%d)" % response_code,
			"button_disabled": false,
		})
		return

	install_state_changed.emit({"button_text": "Installing..."})
	_install_zip.call_deferred()


func _install_zip() -> void:
	_install_in_flight = true
	if _dock != null and _dock.has_method("prepare_for_self_update_drain"):
		_dock.prepare_for_self_update_drain()

	var has_runner: bool = (
		_plugin != null
		and _plugin.has_method("install_downloaded_update")
	)
	if has_runner:
		install_state_changed.emit({"button_text": "Reloading..."})
		_plugin.install_downloaded_update(UPDATE_TEMP_ZIP, UPDATE_TEMP_DIR, _dock)
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(UPDATE_TEMP_ZIP))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(UPDATE_TEMP_DIR))
	_install_in_flight = false
	install_state_changed.emit({
		"button_text": "Reload runner missing",
		"button_disabled": false,
	})
