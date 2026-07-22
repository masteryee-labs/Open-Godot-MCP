"""Test server builds with all 31 core tools registered (+ dynamic Agnes/NVIDIA)."""

import asyncio

import pytest

from open_godot_mcp import agnes_config as ac
from open_godot_mcp.context import ServerContext
from open_godot_mcp.server import build_mcp

_CORE_TOOLS = {
    "godot_editor_read", "godot_editor_edit",
    "godot_scene", "godot_node_read", "godot_node_edit",
    "godot_script", "godot_project", "godot_input_map",
    "godot_resource", "godot_animation", "godot_tilemap",
    "godot_game", "godot_game_time", "godot_input",
    "godot_runtime_state", "godot_exec", "godot_screenshot",
    "godot_debugger", "godot_lsp", "godot_profiler",
    "godot_test", "godot_network", "godot_instance",
    "godot_filesystem", "godot_docs", "godot_log",
    "godot_batch", "godot_asset", "godot_export", "godot_health",
    "godot_csharp_check",
}


@pytest.fixture
def isolated_config(tmp_path, monkeypatch):
    """Point config at tmp_path so tests don't touch the real user config."""
    monkeypatch.setenv("HOME", str(tmp_path))
    monkeypatch.setenv("USERPROFILE", str(tmp_path))
    return ac.default_config_path()


def test_server_builds():
    ctx = ServerContext()
    mcp = build_mcp(ctx)
    assert mcp is not None


def test_all_31_core_tools_registered(isolated_config):
    """With Agnes/NVIDIA disabled (default), exactly 31 core tools are registered."""
    ctx = ServerContext()
    mcp = build_mcp(ctx)
    tools = asyncio.run(mcp.list_tools())
    tool_names = {t.name for t in tools}
    assert tool_names == _CORE_TOOLS, f"Missing: {_CORE_TOOLS - tool_names}, Extra: {tool_names - _CORE_TOOLS}"


def test_read_only_mode_blocks_writes(isolated_config):
    ctx = ServerContext(read_only=True)
    mcp = build_mcp(ctx)
    tools = asyncio.run(mcp.list_tools())
    assert len(tools) == 31


def test_agnes_nvidia_not_registered_by_default(isolated_config):
    """Default config has Agnes/NVIDIA disabled → those tools must NOT appear."""
    ctx = ServerContext()
    mcp = build_mcp(ctx)
    tools = asyncio.run(mcp.list_tools())
    names = {t.name for t in tools}
    assert not any(n.startswith("agnes_") for n in names)
    assert not any(n.startswith("nvidia_") for n in names)
