## Error codes matching Docs/02-Tools/Index.md §錯誤回傳格式.
## Codes are machine-readable strings. The list is NOT closed.

class_name MCPErrorCodes

const NODE_NOT_FOUND := "NODE_NOT_FOUND"
const SCENE_NOT_LOADED := "SCENE_NOT_LOADED"
const RUNTIME_NOT_CONNECTED := "RUNTIME_NOT_CONNECTED"
const PORT_CONFLICT := "PORT_CONFLICT"
const AMBIGUOUS_MATCH := "AMBIGUOUS_MATCH"
const NOT_FOUND := "NOT_FOUND"
const RESOURCE_NOT_FOUND := "RESOURCE_NOT_FOUND"
const VALIDATION_ERROR := "VALIDATION_ERROR"
const PERMISSION_DENIED := "PERMISSION_DENIED"
const UNSUPPORTED_FILE_TYPE := "UNSUPPORTED_FILE_TYPE"
const BRIDGE_NOT_CONNECTED := "BRIDGE_NOT_CONNECTED"
const TIMEOUT := "TIMEOUT"
const INVALID_ARGUMENT := "INVALID_ARGUMENT"
const INVALID_PATH := "INVALID_PATH"
const TOOL_DISABLED := "TOOL_DISABLED"
const INSTANCE_NOT_FOUND := "INSTANCE_NOT_FOUND"
const HANDSHAKE_FAILED := "HANDSHAKE_FAILED"
const INTERNAL_ERROR := "INTERNAL_ERROR"
const ASSERT_FAILED := "ASSERT_FAILED"
const PARTIAL := "PARTIAL"


static func ok(payload: Dictionary = {}) -> Dictionary:
	var out := {"ok": true}
	out.merge(payload, true)
	return out


static func fail(code: String, message: String, extra: Dictionary = {}) -> Dictionary:
	var err := {"code": code, "message": message}
	err.merge(extra, true)
	return {"ok": false, "error": err}
