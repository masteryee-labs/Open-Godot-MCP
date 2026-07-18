extends RefCounted

## Editor handler — godot_editor_read / godot_editor_edit.
## Docs: 02-Tools/Editor.md

const _VC = preload("res://addons/open_godot_mcp/utils/variant_codec.gd")
const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")
const _SP = preload("res://addons/open_godot_mcp/utils/scene_path.gd")

var _bridge: Node


func handle(tool: String, action: String, params: Dictionary) -> Dictionary:
	match action:
		"state":
			return _state()
		"selection":
			return _selection()
		"open_scenes":
			return _open_scenes()
		"viewport":
			return _viewport(params)
		"performance":
			return _performance()
		"open_scene":
			return _open_scene(params)
		"save_scene":
			return _save_scene(params)
		"save_all":
			return _save_all()
		"set_selection":
			return _set_selection(params)
		"focus_node":
			return _focus_node(params)
		"quit":
			return _quit(params)
		_:
			return _EC.fail("INVALID_ARGUMENT", "Unknown action: %s" % action)


func _state() -> Dictionary:
	var current_scene_path: String = ""
	var scene_root := EditorInterface.get_edited_scene_root()
	if scene_root:
		current_scene_path = scene_root.scene_file_path
	return _EC.ok({
		"godot_version": Engine.get_version_info()["string"],
		"current_scene": current_scene_path if not current_scene_path.is_empty() else null,
		"is_playing": EditorInterface.is_playing_scene(),
		"project_path": ProjectSettings.globalize_path("res://"),
	})


func _selection() -> Dictionary:
	var nodes := EditorInterface.get_selection().get_selected_nodes()
	var arr := []
	for n in nodes:
		arr.append({"path": str(n.get_path()), "type": n.get_class(), "name": n.name})
	return _EC.ok({"nodes": arr})


func _open_scenes() -> Dictionary:
	var scenes := []
	for i in EditorInterface.get_open_scenes():
		scenes.append(i)
	return _EC.ok({"scenes": scenes})


func _viewport(params: Dictionary) -> Dictionary:
	var vp: String = params.get("viewport", "2d")
	var size := Vector2i(1920, 1080)  # fallback
	var editor_main_screen := EditorInterface.get_editor_main_screen()
	if editor_main_screen:
		for child in editor_main_screen.get_children():
			if child is Control:
				size = (child as Control).size
				break
	var result := {"size": {"width": size.x, "height": size.y}}
	if vp == "2d":
		result["transform"] = {
			"rotation": 0.0,
			"scale": {"x": 1.0, "y": 1.0},
			"origin": {"x": 0.0, "y": 0.0},
		}
	return _EC.ok(result)


func _performance() -> Dictionary:
	return _EC.ok({
		"fps": Engine.get_frames_per_second(),
		"memory": OS.get_static_memory_usage(),
		"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"object_count": Performance.get_custom_monitor("object/instance_count") if Performance.has_custom_monitor("object/instance_count") else 0,
	})


func _open_scene(params: Dictionary) -> Dictionary:
	var path: String = params.get("path", "")
	if path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "path required (res://...)")
	if not ResourceLoader.exists(path):
		return _EC.fail("RESOURCE_NOT_FOUND", "Scene not found: %s" % path)
	EditorInterface.open_scene_from_path(path)
	return _EC.ok()


func _save_scene(params: Dictionary) -> Dictionary:
	var path: String = params.get("path", "")
	var scene := EditorInterface.get_edited_scene_root()
	if not scene:
		return _EC.fail("SCENE_NOT_LOADED", "No scene currently open")
	if path.is_empty():
		if scene.scene_file_path.is_empty():
			return _EC.fail("INVALID_ARGUMENT", "Current scene has no path; provide path= for save_as")
		EditorInterface.save_scene()
	else:
		# save_scene_as returns void in Godot 4
		EditorInterface.save_scene_as(path, false)
	return _EC.ok()


func _save_all() -> Dictionary:
	var saved := []
	for scene_path in EditorInterface.get_open_scenes():
		EditorInterface.open_scene_from_path(scene_path)
		EditorInterface.save_scene()
		saved.append(scene_path)
	return _EC.ok({"saved": saved})


func _set_selection(params: Dictionary) -> Dictionary:
	var node_paths: Array = params.get("node_paths", [])
	if node_paths.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "node_paths required")
	var sel := EditorInterface.get_selection()
	sel.clear()
	var scene := EditorInterface.get_edited_scene_root()
	if not scene:
		return _EC.fail("SCENE_NOT_LOADED", "No scene open")
	for np in node_paths:
		var node := _SP.resolve(str(np), scene)
		if node:
			sel.add_node(node)
	return _EC.ok()


func _focus_node(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	if node_path.is_empty():
		return _EC.fail("INVALID_ARGUMENT", "node_path required")
	var scene := EditorInterface.get_edited_scene_root()
	if not scene:
		return _EC.fail("SCENE_NOT_LOADED", "No scene open")
	var node := _SP.resolve(node_path, scene)
	if not node:
		return _EC.fail("NODE_NOT_FOUND", "Node not found: %s" % node_path)
	EditorInterface.get_selection().clear()
	EditorInterface.get_selection().add_node(node)
	EditorInterface.edit_node(node)
	return _EC.ok()


func _quit(params: Dictionary) -> Dictionary:
	var save: bool = params.get("save", false)
	if save:
		EditorInterface.save_all_scenes()
	var tree := Engine.get_main_loop() as SceneTree
	if tree:
		tree.quit()
	return _EC.ok()
