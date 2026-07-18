extends RefCounted

## Animation handler — godot_animation (AnimationPlayer ops).
## Docs: 02-Tools/Resource.md §godot_animation

const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")
const _VC = preload("res://addons/open_godot_mcp/utils/variant_codec.gd")
const _SP = preload("res://addons/open_godot_mcp/utils/scene_path.gd")

var _bridge: Node


func handle(tool: String, action: String, params: Dictionary) -> Dictionary:
	match action:
		"list":
			return _list(params)
		"get":
			return _get_animation_data(params)
		"create":
			return _create(params)
		"add_track":
			return _add_track(params)
		"delete":
			return _delete(params)
		"play":
			return _play(params)
		"stop":
			return _stop(params)
		"preset":
			return _preset(params)
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown action: %s" % action)


func _get_player(params: Dictionary) -> AnimationPlayer:
	var player_path: String = params.get("player_path", "")
	if player_path.is_empty():
		return null
	var scene := EditorInterface.get_edited_scene_root()
	if not scene:
		return null
	return _SP.resolve(player_path, scene) as AnimationPlayer


func _list(params: Dictionary) -> Dictionary:
	var player := _get_player(params)
	if not player:
		return _EC.fail("NODE_NOT_FOUND", "AnimationPlayer not found at player_path")
	var anims := player.get_animation_list()
	var list := []
	for a in anims:
		if not str(a).begins_with("RESET"):
			list.append(str(a))
	return _EC.ok({"animations": list})


func _get_animation_data(params: Dictionary) -> Dictionary:
	var player := _get_player(params)
	if not player:
		return _EC.fail("NODE_NOT_FOUND", "AnimationPlayer not found")
	var name: String = params.get("name", "")
	if not player.has_animation(name):
		return _EC.fail("NOT_FOUND", "Animation not found: %s" % name)
	var anim := player.get_animation(name)
	var tracks := []
	for i in anim.get_track_count():
		var track_type := anim.track_get_type(i)
		var track_path := anim.track_get_path(i)
		var keyframes := []
		for j in anim.track_get_key_count(i):
			var t := anim.track_get_key_time(i, j)
			var v := anim.track_get_key_value(i, j)
			keyframes.append({"time": t, "value": _VC.encode_variant(v)})
		tracks.append({"type": _track_type_string(track_type), "path": str(track_path), "keyframes": keyframes})
	return _EC.ok({"tracks": tracks, "length": anim.length, "loop": anim.loop_mode == Animation.LOOP_LINEAR})


func _track_type_string(t: int) -> String:
	match t:
		Animation.TYPE_VALUE: return "value"
		1: return "transform"
		Animation.TYPE_BEZIER: return "bezier"
		Animation.TYPE_METHOD: return "method"
		Animation.TYPE_AUDIO: return "audio"
		Animation.TYPE_ANIMATION: return "animation"
		_: return "unknown"


func _create(params: Dictionary) -> Dictionary:
	var player := _get_player(params)
	if not player:
		return _EC.fail("NODE_NOT_FOUND", "AnimationPlayer not found")
	var name: String = params.get("name", "")
	var length: float = params.get("length", 1.0)
	var loop: bool = params.get("loop", false)
	if name.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "name required")
	if player.has_animation(name):
		return _EC.fail("INVALID_ARGUMENT", "Animation already exists: %s" % name)
	var anim := Animation.new()
	anim.length = length
	if loop:
		anim.loop_mode = Animation.LOOP_LINEAR
	var lib: AnimationLibrary
	if player.has_animation_library(""):
		lib = player.get_animation_library("")
	else:
		lib = AnimationLibrary.new()
		player.add_animation_library("", lib)
	lib.add_animation(name, anim)
	return _EC.ok()


func _add_track(params: Dictionary) -> Dictionary:
	var player := _get_player(params)
	if not player:
		return _EC.fail("NODE_NOT_FOUND", "AnimationPlayer not found")
	var anim_name: String = params.get("anim", "")
	var track_type: String = params.get("track_type", "value")
	var path: String = params.get("path", "")
	var keyframes: Array = params.get("keyframes", [])
	if not player.has_animation(anim_name):
		return _EC.fail("NOT_FOUND", "Animation not found: %s" % anim_name)
	var anim := player.get_animation(anim_name)
	var type_int := _track_type_int(track_type)
	var track_idx := anim.add_track(type_int)
	anim.track_set_path(track_idx, NodePath(path))
	for kf in keyframes:
		var time: float = float(kf.get("time", 0.0))
		match track_type:
			"value":
				var value := _VC.decode_variant(kf.get("value", null))
				anim.track_insert_key(track_idx, time, value)
			"transform":
				var pos := _VC.decode_variant(kf.get("position", {"x": 0, "y": 0, "z": 0}))
				var rot: float = float(kf.get("rotation_deg", 0.0))
				var scale := _VC.decode_variant(kf.get("scale", {"x": 1, "y": 1, "z": 1}))
				anim.track_insert_key(track_idx, time, {"position": pos, "rotation_degrees": rot, "scale": scale})
			_:
				var value := _VC.decode_variant(kf.get("value", null))
				anim.track_insert_key(track_idx, time, value)
	return _EC.ok()


func _track_type_int(t: String) -> int:
	match t:
		"value": return Animation.TYPE_VALUE
		"transform": return 1
		"bezier": return Animation.TYPE_BEZIER
		"method": return Animation.TYPE_METHOD
		"audio": return Animation.TYPE_AUDIO
		"animation": return Animation.TYPE_ANIMATION
		_: return Animation.TYPE_VALUE


func _delete(params: Dictionary) -> Dictionary:
	var player := _get_player(params)
	if not player:
		return _EC.fail("NODE_NOT_FOUND", "AnimationPlayer not found")
	var name: String = params.get("name", "")
	if not player.has_animation(name):
		return _EC.fail("NOT_FOUND", "Animation not found: %s" % name)
	if not player.has_animation_library(""):
		return _EC.fail("NOT_FOUND", "No default library")
	player.get_animation_library("").remove_animation(name)
	return _EC.ok()


func _play(params: Dictionary) -> Dictionary:
	var player := _get_player(params)
	if not player:
		return _EC.fail("NODE_NOT_FOUND", "AnimationPlayer not found")
	var name: String = params.get("name", "")
	player.play(name)
	return _EC.ok()


func _stop(params: Dictionary) -> Dictionary:
	var player := _get_player(params)
	if not player:
		return _EC.fail("NODE_NOT_FOUND", "AnimationPlayer not found")
	player.stop()
	return _EC.ok()


func _preset(params: Dictionary) -> Dictionary:
	var player := _get_player(params)
	if not player:
		return _EC.fail("NODE_NOT_FOUND", "AnimationPlayer not found")
	var anim_name: String = params.get("anim", "")
	var preset: String = params.get("preset", "")
	var target: String = params.get("target", "")
	if anim_name.is_empty() or preset.is_empty() or target.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "anim, preset, target required")
	# Create animation if needed
	if not player.has_animation(anim_name):
		var anim := Animation.new()
		anim.length = 1.0
		if not player.has_animation_library(""):
			player.add_animation_library("", AnimationLibrary.new())
		player.get_animation_library("").add_animation(anim_name, anim)
	var anim := player.get_animation(anim_name)
	match preset:
		"fade":
			# modulate:a 1->0->1
			var track_idx := anim.add_track(Animation.TYPE_VALUE)
			anim.track_set_path(track_idx, NodePath(target + ":modulate:a"))
			anim.track_insert_key(track_idx, 0.0, 1.0)
			anim.track_insert_key(track_idx, 0.5, 0.0)
			anim.track_insert_key(track_idx, 1.0, 1.0)
		"slide":
			# position current -> +50px -> back
			var track_idx2 := anim.add_track(Animation.TYPE_VALUE)
			anim.track_set_path(track_idx2, NodePath(target + ":position"))
			anim.track_insert_key(track_idx2, 0.0, {"x": 0, "y": 0})
			anim.track_insert_key(track_idx2, 0.5, {"x": 50, "y": 0})
			anim.track_insert_key(track_idx2, 1.0, {"x": 0, "y": 0})
		"shake":
			# position random 5px for 0.3s
			var track_idx3 := anim.add_track(Animation.TYPE_VALUE)
			anim.track_set_path(track_idx3, NodePath(target + ":position"))
			var steps := 6
			for i in steps:
				var t := float(i) / float(steps) * 0.3
				var x := randf_range(-5.0, 5.0)
				var y := randf_range(-5.0, 5.0)
				anim.track_insert_key(track_idx3, t, {"x": x, "y": y})
			anim.track_insert_key(track_idx3, 0.3, {"x": 0, "y": 0})
		"pulse":
			# scale 1->1.2->1
			var track_idx4 := anim.add_track(Animation.TYPE_VALUE)
			anim.track_set_path(track_idx4, NodePath(target + ":scale"))
			anim.track_insert_key(track_idx4, 0.0, {"x": 1.0, "y": 1.0})
			anim.track_insert_key(track_idx4, 0.5, {"x": 1.2, "y": 1.2})
			anim.track_insert_key(track_idx4, 1.0, {"x": 1.0, "y": 1.0})
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown preset: %s" % preset)
	return _EC.ok()
