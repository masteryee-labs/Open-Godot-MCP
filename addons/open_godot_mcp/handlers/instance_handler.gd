extends RefCounted

## Instance handler — godot_instance (editor instance management).
## Docs: 02-Tools/Instance.md
##
## Editor instance management is handled by the Python MCP server's
## InstanceManager. The bridge reports info about itself.

const _EC = preload("res://addons/open_godot_mcp/utils/error_codes.gd")

var _bridge: Node


func handle(tool: String, action: String, params: Dictionary) -> Dictionary:
	match action:
		"list":
			return _list()
		_:
			return _EC.fail("INTERNAL_ERROR", "Editor instance management is handled by the MCP server. Only 'list' is available on the bridge.")


func _list() -> Dictionary:
	# Report this bridge's info
	var info := {
		"instance_id": "local",
		"project_path": ProjectSettings.globalize_path("res://"),
		"ports": {
			"bridge": _bridge.port if _bridge else 6970,
			"dap": 6006,
			"lsp": 6005,
		},
		"active": true,
	}
	return _EC.ok({"instances": [info]})
