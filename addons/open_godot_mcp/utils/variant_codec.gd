## Variant codec — encode/decode Godot Variant <-> JSON-compatible dict.
##
## Implements the JSON encoding table in Docs/02-Tools/Index.md §Godot 型別的 JSON 編碼.
## Vector2 -> {"x":float,"y":float}, Vector3 -> {"x","y","z"}, Color -> {"r","g","b","a"},
## Rect2 -> {"x","y","width","height"}, etc.
##
## encode_variant(v) -> JSON-safe value
## decode_variant(v) -> Godot Variant (for inbound params from JSON)

class_name VariantCodec

# ---- encode: Godot Variant -> JSON-safe ----

static func encode_variant(v: Variant) -> Variant:
	var t := typeof(v)
	match t:
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING:
			return v
		TYPE_VECTOR2:
			return {"x": v.x, "y": v.y}
		TYPE_VECTOR2I:
			return {"x": v.x, "y": v.y}
		TYPE_VECTOR3:
			return {"x": v.x, "y": v.y, "z": v.z}
		TYPE_VECTOR3I:
			return {"x": v.x, "y": v.y, "z": v.z}
		TYPE_VECTOR4:
			return {"x": v.x, "y": v.y, "z": v.z, "w": v.w}
		TYPE_VECTOR4I:
			return {"x": v.x, "y": v.y, "z": v.z, "w": v.w}
		TYPE_COLOR:
			return {"r": v.r, "g": v.g, "b": v.b, "a": v.a}
		TYPE_RECT2:
			return {"x": v.position.x, "y": v.position.y, "width": v.size.x, "height": v.size.y}
		TYPE_RECT2I:
			return {"x": v.position.x, "y": v.position.y, "width": v.size.x, "height": v.size.y}
		TYPE_QUATERNION:
			return {"x": v.x, "y": v.y, "z": v.z, "w": v.w}
		TYPE_TRANSFORM2D:
			return {
				"rotation": v.get_rotation(),
				"scale": {"x": v.get_scale().x, "y": v.get_scale().y},
				"origin": {"x": v.get_origin().x, "y": v.get_origin().y},
			}
		TYPE_BASIS:
			return {
				"x": {"x": v.x.x, "y": v.x.y, "z": v.x.z},
				"y": {"x": v.y.x, "y": v.y.y, "z": v.y.z},
				"z": {"x": v.z.x, "y": v.z.y, "z": v.z.z},
			}
		TYPE_TRANSFORM3D:
			return {
				"basis": encode_variant(v.basis),
				"origin": encode_variant(v.origin),
			}
		TYPE_PLANE:
			return {"x": v.x, "y": v.y, "z": v.z, "d": v.d}
		TYPE_NODE_PATH:
			return str(v)
		TYPE_STRING_NAME:
			return str(v)
		TYPE_ARRAY:
			var arr := []
			for item in v:
				arr.append(encode_variant(item))
			return arr
		TYPE_PACKED_INT32_ARRAY, TYPE_PACKED_INT64_ARRAY:
			var ia := []
			for item in v:
				ia.append(item)
			return ia
		TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_FLOAT64_ARRAY:
			var fa := []
			for item in v:
				fa.append(item)
			return fa
		TYPE_PACKED_STRING_ARRAY:
			var sa := []
			for item in v:
				sa.append(item)
			return sa
		TYPE_PACKED_VECTOR2_ARRAY:
			var a := []
			for item in v:
				a.append(encode_variant(item))
			return a
		TYPE_PACKED_VECTOR3_ARRAY:
			var a2 := []
			for item in v:
				a2.append(encode_variant(item))
			return a2
		TYPE_PACKED_COLOR_ARRAY:
			var a3 := []
			for item in v:
				a3.append(encode_variant(item))
			return a3
		TYPE_DICTIONARY:
			var d := {}
			for key in v:
				# JSON keys must be strings; stringify non-string keys
				d[str(key)] = encode_variant(v[key])
			return d
		TYPE_OBJECT:
			if v == null:
				return null
			if v is Resource:
				return v.resource_path if not v.resource_path.is_empty() else str(v)
			if v is Node:
				return (v as Node).get_path()
			# Fallback: try property dict
			return _encode_object_properties(v)
		TYPE_CALLABLE, TYPE_SIGNAL:
			return str(v)
		_:
			return str(v)


static func _encode_object_properties(obj: Object) -> Dictionary:
	var d := {}
	for prop in obj.get_property_list():
		var name: String = prop["name"]
		if name.begins_with("_") or name in ["script", "_meta", "resource_path"]:
			continue
		d[name] = encode_variant(obj.get(name))
	return d


# ---- decode: JSON-safe -> Godot Variant ----

static func decode_variant(v: Variant) -> Variant:
	if v == null:
		return null
	if v is bool or v is int or v is float or v is String:
		return v
	if v is Array:
		var arr := []
		for item in v:
			arr.append(decode_variant(item))
		return arr
	if v is Dictionary:
		# Detect Godot-type dicts by their keys
		var keys: Array = v.keys()
		var key_set := {}
		for k in keys:
			key_set[k] = true
		# Vector2
		if key_set.has("x") and key_set.has("y") and not key_set.has("z") and not key_set.has("width"):
			return Vector2(float(v["x"]), float(v["y"]))
		# Vector3
		if key_set.has("x") and key_set.has("y") and key_set.has("z") and not key_set.has("w"):
			return Vector3(float(v["x"]), float(v["y"]), float(v["z"]))
		# Vector4 / Quaternion
		if key_set.has("x") and key_set.has("y") and key_set.has("z") and key_set.has("w"):
			if key_set.size() == 4:
				return Quaternion(float(v["x"]), float(v["y"]), float(v["z"]), float(v["w"]))
		# Color
		if key_set.has("r") and key_set.has("g") and key_set.has("b"):
			return Color(float(v["r"]), float(v["g"]), float(v["b"]), float(v.get("a", 1.0)))
		# Rect2
		if key_set.has("x") and key_set.has("y") and key_set.has("width") and key_set.has("height"):
			return Rect2(float(v["x"]), float(v["y"]), float(v["width"]), float(v["height"]))
		# Plane
		if key_set.has("x") and key_set.has("y") and key_set.has("z") and key_set.has("d"):
			return Plane(float(v["x"]), float(v["y"]), float(v["z"]), float(v["d"]))
		# Generic dict
		var d := {}
		for k in keys:
			d[k] = decode_variant(v[k])
		return d
	return v


# ---- Node property serialization (used by inspect/tree) ----

static func encode_node_properties(node: Node, prop_names: PackedStringArray = []) -> Dictionary:
	var d := {}
	var props := node.get_property_list()
	var prop_map := {}
	for p in props:
		prop_map[p["name"]] = p
	if prop_names.is_empty():
		prop_names = _default_properties_for(node)
	for name in prop_names:
		if prop_map.has(name):
			d[name] = encode_variant(node.get(name))
		else:
			# Property doesn't exist on this node — skip
			pass
	return d


static func _default_properties_for(node: Node) -> PackedStringArray:
	var defaults: PackedStringArray = []
	if node is Node2D:
		defaults = PackedStringArray(["position", "rotation", "scale", "visible", "name"])
	elif node is Node3D:
		defaults = PackedStringArray(["position", "rotation", "scale", "visible", "name"])
	elif node is Control:
		defaults = PackedStringArray(["position", "size", "visible", "name"])
	elif node is CanvasItem:
		defaults = PackedStringArray(["visible", "modulate", "z_index", "name"])
	else:
		defaults = PackedStringArray(["name"])
	return defaults
