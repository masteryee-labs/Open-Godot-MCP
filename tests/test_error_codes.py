"""Test error codes and response builders."""

from open_godot_mcp.utils.error_codes import McpError, err, ok, fail


def test_ok_basic():
    r = ok()
    assert r == {"ok": True}


def test_ok_with_payload():
    r = ok(foo="bar", count=42)
    assert r == {"ok": True, "foo": "bar", "count": 42}


def test_fail_basic():
    r = fail("NODE_NOT_FOUND", "Node '/root/Foo' not found")
    assert r == {"ok": False, "error": {"code": "NODE_NOT_FOUND", "message": "Node '/root/Foo' not found"}}


def test_mcp_error_to_dict():
    e = err("TIMEOUT", "timed out after 5s")
    assert isinstance(e, McpError)
    assert e.code == "TIMEOUT"
    assert e.message == "timed out after 5s"
    assert e.to_dict() == {"code": "TIMEOUT", "message": "timed out after 5s"}
