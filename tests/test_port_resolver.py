"""Test port resolver logic."""

from open_godot_mcp.utils.port_resolver import (
    env_port,
    DEFAULT_BRIDGE_PORT,
    DEFAULT_DAP_PORT,
    DEFAULT_LSP_PORT,
    allocate_instance_ports,
    resolve_port,
    is_port_free,
)


def test_defaults():
    assert DEFAULT_BRIDGE_PORT == 6970
    assert DEFAULT_DAP_PORT == 6006
    assert DEFAULT_LSP_PORT == 6005


def test_env_port_valid():
    assert env_port("OPEN_GODOT_MCP_PORT", 6970) in [6970, int(__import__("os").environ.get("OPEN_GODOT_MCP_PORT", 6970))]


def test_env_port_invalid():
    assert env_port("NONEXISTENT_VAR_XYZ", 6970) == 6970


def test_is_port_free_high_port():
    # Port 65535 is likely free (or not, but the function should return a bool)
    result = is_port_free(65531, "127.0.0.1")
    assert isinstance(result, bool)


def test_resolve_port_returns_valid():
    p = resolve_port(0, 65531, host="127.0.0.1")
    assert 1 <= p <= 65535


def test_allocate_instance_ports():
    ports = allocate_instance_ports(0, host="127.0.0.1")
    assert "bridge" in ports
    assert "dap" in ports
    assert "lsp" in ports
    assert "game" in ports
    assert all(1 <= p <= 65535 for p in ports.values())
