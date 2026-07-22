extends RefCounted
## Dock i18n — loads language JSON from res://addons/open_godot_mcp/dock/i18n/<lang>.json
## Provides t(key) lookup with English fallback for missing keys.

const _DIR := "res://addons/open_godot_mcp/dock/i18n/"
const _FALLBACK := "en"
const _SETTING_KEY := "open_godot_mcp/ui/language"

var _current: String = "en"
var _tables: Dictionary = {}  # lang -> Dictionary of keys

signal language_changed(lang: String)


func _init() -> void:
	_load(_FALLBACK)
	var lang: String = _read_saved_language()
	set_language(lang)


func available_languages() -> Array[String]:
	# Fixed list — matches README translations.
	var out: Array[String] = [
		"en", "zh-TW", "zh-CN", "ar", "de", "es", "fr", "hi", "id", "it",
		"ja", "ko", "nl", "pl", "pt-BR", "ru", "th", "tr", "uk", "vi",
	]
	return out


func current_language() -> String:
	return _current


func set_language(lang: String) -> void:
	if lang == _current and _tables.has(lang):
		return
	if not _tables.has(lang):
		if not _load(lang):
			lang = _FALLBACK
	_current = lang
	_write_saved_language(lang)
	language_changed.emit(lang)


func t(key: String) -> String:
	var tbl: Dictionary = _tables.get(_current, {})
	if tbl.has(key):
		return String(tbl[key])
	var fb: Dictionary = _tables.get(_FALLBACK, {})
	if fb.has(key):
		return String(fb[key])
	return key


func _load(lang: String) -> bool:
	var path := _DIR + lang + ".json"
	if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
		return false
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return false
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if parsed == null or not (parsed is Dictionary):
		return false
	_tables[lang] = parsed
	return true


func _read_saved_language() -> String:
	var es := EditorInterface.get_editor_settings()
	if es == null:
		return "en"
	var v = es.get_setting(_SETTING_KEY)
	if v == null or str(v).is_empty():
		return "en"
	return str(v)


func _write_saved_language(lang: String) -> void:
	var es := EditorInterface.get_editor_settings()
	if es == null:
		return
	es.set_setting(_SETTING_KEY, lang)
