"""Error codes used across all tools.

Matches the error code table in Docs/02-Tools/Index.md §錯誤回傳格式.
Codes are machine-readable strings; ``error.message`` is human-readable.
The list is NOT closed — tools may emit codes not listed here.
"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class McpError(Exception):
    """Tool-level error carrying a machine-readable ``code`` and ``message``."""

    code: str
    message: str

    def to_dict(self) -> dict[str, str]:
        return {"code": self.code, "message": self.message}


# Common codes documented in Index.md
NODE_NOT_FOUND = "NODE_NOT_FOUND"
SCENE_NOT_LOADED = "SCENE_NOT_LOADED"
RUNTIME_NOT_CONNECTED = "RUNTIME_NOT_CONNECTED"
PORT_CONFLICT = "PORT_CONFLICT"
AMBIGUOUS_MATCH = "AMBIGUOUS_MATCH"
NOT_FOUND = "NOT_FOUND"
RESOURCE_NOT_FOUND = "RESOURCE_NOT_FOUND"
VALIDATION_ERROR = "VALIDATION_ERROR"
PERMISSION_DENIED = "PERMISSION_DENIED"
UNSUPPORTED_FILE_TYPE = "UNSUPPORTED_FILE_TYPE"
BRIDGE_NOT_CONNECTED = "BRIDGE_NOT_CONNECTED"
TIMEOUT = "TIMEOUT"
INVALID_ARGUMENT = "INVALID_ARGUMENT"
INVALID_PATH = "INVALID_PATH"
TOOL_DISABLED = "TOOL_DISABLED"
INSTANCE_NOT_FOUND = "INSTANCE_NOT_FOUND"
HANDSHAKE_FAILED = "HANDSHAKE_FAILED"
RATE_LIMITED = "RATE_LIMITED"
QUOTA_EXHAUSTED = "QUOTA_EXHAUSTED"
AUTH_FAILED = "AUTH_FAILED"
API_ERROR = "API_ERROR"
UPLOAD_FAILED = "UPLOAD_FAILED"
INTERNAL_ERROR = "INTERNAL_ERROR"


def err(code: str, message: str) -> McpError:
    """Convenience constructor."""
    return McpError(code=code, message=message)


def ok(**payload) -> dict:
    """Build a successful response ``{"ok": True, ...payload}``."""
    out: dict = {"ok": True}
    out.update(payload)
    return out


def fail(code: str, message: str) -> dict:
    """Build a failure response ``{"ok": False, "error": {"code", "message"}}``."""
    return {"ok": False, "error": {"code": code, "message": message}}
