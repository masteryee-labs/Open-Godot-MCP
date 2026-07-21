"""Test server builds with all 31 tools registered."""

import asyncio

from open_godot_mcp.server import build_mcp
from open_godot_mcp.context import ServerContext


def test_server_builds():
    ctx = ServerContext()
    mcp = build_mcp(ctx)
    assert mcp is not None


def test_all_31_tools_registered():
    ctx = ServerContext()
    mcp = build_mcp(ctx)
    tools = asyncio.run(mcp.list_tools())
    tool_names = {t.name for t in tools}
    expected = {
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
    assert tool_names == expected, f"Missing: {expected - tool_names}, Extra: {tool_names - expected}"


def test_read_only_mode_blocks_writes():
    ctx = ServerContext(read_only=True)
    mcp = build_mcp(ctx)
    tools = asyncio.run(mcp.list_tools())
    assert len(tools) == 31
