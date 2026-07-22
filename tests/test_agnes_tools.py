"""Tests for agnes/nvidia tools: dynamic registration + HTTP error classification.

HTTP calls are mocked — no real network access.
"""

from __future__ import annotations

import asyncio
import json
from unittest.mock import patch

import pytest

from open_godot_mcp import agnes_config as ac
from open_godot_mcp.context import ServerContext
from open_godot_mcp.server import build_mcp
from open_godot_mcp.tools import agnes as agnes_mod
from open_godot_mcp.tools import nvidia as nvidia_mod


@pytest.fixture
def isolated_config(tmp_path, monkeypatch):
    monkeypatch.setenv("HOME", str(tmp_path))
    monkeypatch.setenv("USERPROFILE", str(tmp_path))
    return ac.default_config_path()


def _write_cfg(path, agnes=None, nvidia=None):
    cfg = {"agnes": ac.DEFAULTS["agnes"] | (agnes or {}), "nvidia": ac.DEFAULTS["nvidia"] | (nvidia or {})}
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(cfg), encoding="utf-8")
    return cfg


def test_no_agnes_tools_when_disabled(isolated_config):
    _write_cfg(isolated_config)  # all defaults = disabled
    ctx = ServerContext()
    mcp = build_mcp(ctx)
    tools = asyncio.run(mcp.list_tools())
    names = {t.name for t in tools}
    assert not any(n.startswith("agnes_") for n in names)
    assert not any(n.startswith("nvidia_") for n in names)


def test_agnes_vision_registered_when_enabled(isolated_config):
    _write_cfg(isolated_config, agnes={"enabled": True, "api_keys": ["k"], "vision": True})
    ctx = ServerContext()
    mcp = build_mcp(ctx)
    tools = asyncio.run(mcp.list_tools())
    names = {t.name for t in tools}
    assert "agnes_vision" in names
    assert "agnes_image_generate" not in names
    assert "agnes_video_generate" not in names


def test_all_five_tools_when_fully_enabled(isolated_config):
    _write_cfg(
        isolated_config,
        agnes={"enabled": True, "api_keys": ["k"], "vision": True, "image_generate": True, "video_generate": True},
        nvidia={"enabled": True, "api_keys": ["k"], "vision": True, "image_generate": True},
    )
    ctx = ServerContext()
    mcp = build_mcp(ctx)
    tools = asyncio.run(mcp.list_tools())
    names = {t.name for t in tools}
    assert {"agnes_vision", "agnes_image_generate", "agnes_video_generate", "nvidia_vision", "nvidia_image_generate"} <= names


def test_hot_reload_removes_tools(isolated_config):
    _write_cfg(isolated_config, agnes={"enabled": True, "api_keys": ["k"], "vision": True})
    ctx = ServerContext()
    mcp = build_mcp(ctx)
    assert "agnes_vision" in {t.name for t in asyncio.run(mcp.list_tools())}
    # Disable on disk
    _write_cfg(isolated_config, agnes={"enabled": False, "api_keys": []})
    ctx.sync_agnes_tools()
    names = {t.name for t in asyncio.run(mcp.list_tools())}
    assert "agnes_vision" not in names


def test_hot_reload_adds_tools(isolated_config):
    _write_cfg(isolated_config)  # disabled
    ctx = ServerContext()
    mcp = build_mcp(ctx)
    assert "agnes_vision" not in {t.name for t in asyncio.run(mcp.list_tools())}
    _write_cfg(isolated_config, agnes={"enabled": True, "api_keys": ["k"], "vision": True})
    ctx.sync_agnes_tools()
    assert "agnes_vision" in {t.name for t in asyncio.run(mcp.list_tools())}


def test_disabled_tool_returns_tool_disabled(isolated_config):
    _write_cfg(isolated_config)  # disabled
    ctx = ServerContext()
    build_mcp(ctx)
    # Call the function directly (bypass MCP layer) — it should refuse.
    result = asyncio.run(agnes_mod._agnes_vision("analyze", {"image": "x.png", "question": "q"}))
    assert result["ok"] is False
    assert result["error"]["code"] == "TOOL_DISABLED"


def test_agnes_vision_url_passthrough(isolated_config):
    _write_cfg(isolated_config, agnes={"enabled": True, "api_keys": ["k"], "vision": True})
    fake_resp = {"choices": [{"message": {"content": "a cat"}}]}
    with patch.object(agnes_mod, "_call_with_retry", return_value={"ok": True, "response": fake_resp}):
        result = asyncio.run(
            agnes_mod._agnes_vision("analyze", {"image": "https://example.com/x.png", "question": "what?"})
        )
    assert result["ok"] is True
    assert result["content"] == "a cat"
    assert result["image_url"] == "https://example.com/x.png"


def test_agnes_vision_local_file_uploads_via_uguu(isolated_config, tmp_path):
    _write_cfg(isolated_config, agnes={"enabled": True, "api_keys": ["k"], "vision": True})
    img = tmp_path / "shot.png"
    img.write_bytes(b"\x89PNG\r\n\x1a\n")  # minimal PNG header
    fake_resp = {"choices": [{"message": {"content": "described"}}]}
    with patch.object(agnes_mod, "_upload_uguu", return_value="https://n.uguu.se/abc.png"), \
         patch.object(agnes_mod, "_call_with_retry", return_value={"ok": True, "response": fake_resp}):
        result = asyncio.run(agnes_mod._agnes_vision("analyze", {"image": str(img)}))
    assert result["ok"] is True
    assert result["image_url"] == "https://n.uguu.se/abc.png"


def test_agnes_vision_missing_file(isolated_config):
    _write_cfg(isolated_config, agnes={"enabled": True, "api_keys": ["k"], "vision": True})
    result = asyncio.run(agnes_mod._agnes_vision("analyze", {"image": "/nope/missing.png"}))
    assert result["ok"] is False
    assert result["error"]["code"] in ("INVALID_ARGUMENT", "UPLOAD_FAILED")


def test_agnes_429_retries_then_rate_limited(isolated_config):
    _write_cfg(isolated_config, agnes={"enabled": True, "api_keys": ["k"], "vision": True})
    with patch.object(agnes_mod, "_post_json", return_value=(429, '{"error":"rate"}')), \
         patch.object(agnes_mod.time, "sleep", lambda s: None):
        result = asyncio.run(
            agnes_mod._agnes_vision("analyze", {"image": "https://example.com/x.png"})
        )
    assert result["ok"] is False
    assert result["error"]["code"] == "RATE_LIMITED"


def test_agnes_402_quota_exhausted(isolated_config):
    """402 with a single key: retries with backoff (key rotation has no other key)."""
    _write_cfg(isolated_config, agnes={"enabled": True, "api_keys": ["k"], "vision": True})
    call_count = {"n": 0}

    def fake_post(*a, **kw):
        call_count["n"] += 1
        return (402, '{"error":"no balance"}')

    with patch.object(agnes_mod, "_post_json", side_effect=fake_post), \
         patch.object(agnes_mod.time, "sleep", lambda s: None):
        result = asyncio.run(
            agnes_mod._agnes_vision("analyze", {"image": "https://example.com/x.png"})
        )
    assert result["ok"] is False
    assert result["error"]["code"] == "QUOTA_EXHAUSTED"


def test_agnes_429_key_rotation(isolated_config):
    """With 3 keys, 429 on first two should rotate; success on third."""
    _write_cfg(isolated_config, agnes={"enabled": True, "api_keys": ["k1", "k2", "k3"], "vision": True})
    call_count = {"n": 0}

    def fake_post(url, headers, payload, timeout=180):
        call_count["n"] += 1
        key = headers.get("Authorization", "")
        if "k1" in key or "k2" in key:
            return (429, '{"error":"rate"}')
        return (200, {"choices": [{"message": {"content": "ok"}}]})

    with patch.object(agnes_mod, "_post_json", side_effect=fake_post):
        result = asyncio.run(
            agnes_mod._agnes_vision("analyze", {"image": "https://example.com/x.png"})
        )
    assert result["ok"] is True
    assert result["content"] == "ok"
    assert call_count["n"] == 3  # k1→429, k2→429, k3→200


def test_nvidia_vision_base64_local_file(isolated_config, tmp_path):
    _write_cfg(isolated_config, nvidia={"enabled": True, "api_keys": ["k"], "vision": True})
    img = tmp_path / "shot.png"
    img.write_bytes(b"\x89PNG\r\n\x1a\nfake")
    fake_resp = {"choices": [{"message": {"content": "described via nvidia"}}]}
    with patch.object(nvidia_mod, "_call_with_retry", return_value={"ok": True, "response": fake_resp}):
        result = asyncio.run(nvidia_mod._nvidia_vision("analyze", {"image": str(img)}))
    assert result["ok"] is True
    assert result["content"] == "described via nvidia"


def test_nvidia_image_generate_saves_to_disk(isolated_config, tmp_path):
    _write_cfg(isolated_config, nvidia={"enabled": True, "api_keys": ["k"], "image_generate": True})
    import base64 as b64
    fake_resp = {"artifacts": [{"base64": b64.b64encode(b"PNGDATA").decode(), "finishReason": "SUCCESS"}]}
    out = tmp_path / "out" / "gen.png"
    with patch.object(nvidia_mod, "_call_with_retry", return_value={"ok": True, "response": fake_resp}):
        result = asyncio.run(
            nvidia_mod._nvidia_image_generate("generate", {"prompt": "a cat", "output_path": str(out)})
        )
    assert result["ok"] is True
    assert result["saved"] == str(out)
    assert out.read_bytes() == b"PNGDATA"


def test_nvidia_image_generate_quota_error(isolated_config):
    _write_cfg(isolated_config, nvidia={"enabled": True, "api_keys": ["k"], "image_generate": True})
    with patch.object(nvidia_mod, "_post_json", return_value=(402, "no balance")):
        result = asyncio.run(nvidia_mod._nvidia_image_generate("generate", {"prompt": "x"}))
    assert result["ok"] is False
    assert result["error"]["code"] == "QUOTA_EXHAUSTED"
