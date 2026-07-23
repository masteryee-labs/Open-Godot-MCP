"""Tests for game instance routing — ctx.call() prefers active game instance."""

import asyncio
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from open_godot_mcp.context import ServerContext, _RUNTIME_TOOLS
from open_godot_mcp.game_instance_manager import GameInstance, GameInstanceManager
from open_godot_mcp.utils.error_codes import ok


def _make_mock_bridge(connected: bool = True) -> MagicMock:
    bridge = MagicMock()
    bridge.connected = connected
    bridge.call_tool = AsyncMock(return_value=ok(mock=True))
    return bridge


def _make_game_instance(iid: str, bridge: MagicMock) -> GameInstance:
    return GameInstance(
        instance_id=iid,
        role="host",
        game_port=7070,
        project_path="/fake",
        scene="res://Main.tscn",
        args={},
        bridge=bridge,
    )


@pytest.fixture
def ctx_with_game_instance():
    ctx = ServerContext()
    mgr = ctx.game_instance_manager
    bridge = _make_mock_bridge()
    inst = _make_game_instance("game_1", bridge)
    mgr._instances["game_1"] = inst
    mgr._active_id = "game_1"
    return ctx, bridge


@pytest.fixture
def ctx_no_game_instance():
    ctx = ServerContext()
    return ctx, None


def test_runtime_tools_set_contains_expected():
    assert "godot_exec" in _RUNTIME_TOOLS
    assert "godot_game" in _RUNTIME_TOOLS
    assert "godot_game_time" in _RUNTIME_TOOLS
    assert "godot_input" in _RUNTIME_TOOLS
    assert "godot_runtime_state" in _RUNTIME_TOOLS
    assert "godot_screenshot" in _RUNTIME_TOOLS
    assert "godot_profiler" in _RUNTIME_TOOLS
    assert "godot_log" in _RUNTIME_TOOLS


def test_editor_tools_not_in_runtime_set():
    assert "godot_editor_read" not in _RUNTIME_TOOLS
    assert "godot_scene" not in _RUNTIME_TOOLS
    assert "godot_node_read" not in _RUNTIME_TOOLS
    assert "godot_script" not in _RUNTIME_TOOLS
    assert "godot_project" not in _RUNTIME_TOOLS


@pytest.mark.asyncio
async def test_runtime_tool_routes_to_active_game_instance(ctx_with_game_instance):
    ctx, gi_bridge = ctx_with_game_instance
    result = await ctx.call("godot_exec", "eval", {"code": "return 1"})
    gi_bridge.call_tool.assert_awaited_once_with(
        "godot_exec", "eval", {"code": "return 1"}, timeout=30.0
    )
    assert result.get("ok") is True


@pytest.mark.asyncio
async def test_editor_tool_does_not_route_to_game_instance(ctx_with_game_instance):
    ctx, gi_bridge = ctx_with_game_instance
    editor_bridge = _make_mock_bridge()
    ctx.instance_manager._bridges = {None: editor_bridge}
    ctx._adopted = True
    with patch.object(ctx.instance_manager, "get_bridge", return_value=editor_bridge):
        await ctx.call("godot_editor_read", "state", {})
    gi_bridge.call_tool.assert_not_awaited()
    editor_bridge.call_tool.assert_awaited_once()


@pytest.mark.asyncio
async def test_no_game_instance_falls_back_to_editor(ctx_no_game_instance):
    ctx, _ = ctx_no_game_instance
    editor_bridge = _make_mock_bridge()
    ctx._adopted = True
    with patch.object(ctx.instance_manager, "get_bridge", return_value=editor_bridge):
        result = await ctx.call("godot_exec", "eval", {"code": "return 1"})
    editor_bridge.call_tool.assert_awaited_once()
    assert result.get("ok") is True


@pytest.mark.asyncio
async def test_explicit_instance_id_overrides_active(ctx_with_game_instance):
    ctx, gi_bridge = ctx_with_game_instance
    other_bridge = _make_mock_bridge()
    other_inst = _make_game_instance("game_2", other_bridge)
    ctx.game_instance_manager._instances["game_2"] = other_inst
    result = await ctx.call(
        "godot_exec", "eval", {"code": "return 1"}, instance_id="game_2"
    )
    other_bridge.call_tool.assert_awaited_once()
    gi_bridge.call_tool.assert_not_awaited()
    assert result.get("ok") is True


def test_clear_active_resets_active_id():
    mgr = GameInstanceManager()
    bridge = _make_mock_bridge()
    inst = _make_game_instance("game_1", bridge)
    mgr._instances["game_1"] = inst
    mgr._active_id = "game_1"
    assert mgr.active_id == "game_1"
    mgr.clear_active()
    assert mgr.active_id is None
    assert inst.active is False


def test_switch_to_editor_clears_active():
    from open_godot_mcp.tools.network import register_network_tools
    from open_godot_mcp.context import ServerContext
    from fastmcp import FastMCP

    ctx = ServerContext()
    mgr = ctx.game_instance_manager
    bridge = _make_mock_bridge()
    inst = _make_game_instance("game_1", bridge)
    mgr._instances["game_1"] = inst
    mgr._active_id = "game_1"

    mcp = FastMCP("test")
    register_network_tools(mcp, ctx)

    tools = asyncio.run(mcp.list_tools())
    net_tool = [t for t in tools if t.name == "godot_network"][0]
    result = asyncio.run(net_tool.fn("switch", {"instance_id": "editor"}))
    assert result.get("ok") is True
    assert mgr.active_id is None


def test_read_enet_port_finds_port(tmp_path):
    from open_godot_mcp.game_instance_manager import _read_enet_port

    csv_dir = tmp_path / "Data" / "CSV"
    csv_dir.mkdir(parents=True)
    (csv_dir / "game_settings.csv").write_text(
        "category,key,value,type,desc\nnetwork,default_port,8910,int,test\n",
        encoding="utf-8",
    )
    assert _read_enet_port(tmp_path) == 8910


def test_read_enet_port_missing_file(tmp_path):
    from open_godot_mcp.game_instance_manager import _read_enet_port

    assert _read_enet_port(tmp_path) is None


def test_read_enet_port_missing_row(tmp_path):
    from open_godot_mcp.game_instance_manager import _read_enet_port

    csv_dir = tmp_path / "Data" / "CSV"
    csv_dir.mkdir(parents=True)
    (csv_dir / "game_settings.csv").write_text(
        "category,key,value,type,desc\naudio,volume,80,int,test\n",
        encoding="utf-8",
    )
    assert _read_enet_port(tmp_path) is None
