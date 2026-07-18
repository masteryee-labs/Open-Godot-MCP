@tool
class_name OgmScenePath
extends RefCounted

## Utility for converting between Godot internal node paths and clean
## scene-relative paths like /Main/Camera3D.
##
## Accepts forms relative to the edited scene root:
##   "/Main"          — explicit root prefix (canonical)
##   "/Main/Camera3D" — descendant path
##   "Camera3D"       — bare relative to scene_root
##   "/root/Main"     — SceneTree-style alias for the scene root


## Resolve a clean scene path like "/Main/Camera3D" to the actual node.
static func resolve(scene_path: String, scene_root: Node) -> Node:
	if scene_root == null:
		return null

	# Bare "/" alias: the scene root itself.
	if scene_path == "/":
		return scene_root

	# /root/<scene_root_name>[/...] alias: strip the /root prefix and recurse.
	var alias_prefix := "/root/" + scene_root.name
	if scene_path == alias_prefix or scene_path.begins_with(alias_prefix + "/"):
		return resolve(scene_path.substr(5), scene_root)  # keep leading slash

	var root_prefix := "/" + scene_root.name
	if scene_path == root_prefix:
		return scene_root
	if scene_path.begins_with(root_prefix + "/"):
		var relative := scene_path.substr(root_prefix.length() + 1)
		return scene_root.get_node_or_null(relative)

	# Try as-is (relative path, or absolute SceneTree path).
	return scene_root.get_node_or_null(scene_path)


## Return a clean path relative to the scene root (e.g. /Main/Camera3D).
static func from_node(node: Node, scene_root: Node) -> String:
	if scene_root == null or node == null:
		return ""
	if node == scene_root:
		return "/" + scene_root.name
	if not scene_root.is_ancestor_of(node):
		return ""
	var relative := scene_root.get_path_to(node)
	return "/" + scene_root.name + "/" + str(relative)


## Format a "node not found" error that names the path convention.
static func format_node_error(path: String, scene_root: Node) -> String:
	if scene_root == null:
		return "Node not found: %s. No edited scene is open." % path
	var root_name := str(scene_root.name)
	var suggestion := ""
	if path.begins_with("/root/"):
		var after_root := path.substr(6)
		var first_seg := after_root.split("/")[0]
		if first_seg != root_name and not first_seg.is_empty():
			suggestion = "/" + root_name + "/" + after_root
	elif not path.begins_with("/") and not path.is_empty():
		suggestion = "/" + root_name + "/" + path
	if suggestion.is_empty():
		return "Node not found: %s. Paths are relative to the edited scene root (e.g. \"/%s/Child\"), not runtime /root/... paths. Scene root is \"/%s\"." % [path, root_name, root_name]
	return "Node not found: %s. Did you mean \"%s\"? Paths are relative to the edited scene root, not runtime /root/... paths. Scene root is \"/%s\"." % [path, suggestion, root_name]
