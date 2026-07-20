"""Regression tests for bridge reconnect / on-demand connect.

Covers the bug where a long-idle MCP server process permanently lost its
WebSocket to the Godot editor bridge after ``reconnect()`` exhausted its
20 attempts, requiring a full process restart to recover.
"""

from __future__ import annotations

import asyncio
import json
from unittest.mock import AsyncMock, MagicMock

import pytest

from open_godot_mcp.bridge import BridgeClient


class _FakeWS:
    """Minimal stand-in for a websockets connection."""

    def __init__(self) -> None:
        self.sent: list[str] = []
        self._closed = False

    async def send(self, text: str) -> None:
        self.sent.append(text)

    async def recv(self) -> str:
        # First recv is the handshake response.
        return json.dumps({"jsonrpc": "2.0", "id": 1, "result": {"godot_version": "x"}})

    async def close(self) -> None:
        self._closed = True

    def __aiter__(self):
        return self

    async def __anext__(self):
        # No further messages — block forever until cancelled.
        await asyncio.sleep(3600)
        raise StopAsyncIteration


def _patch_connect_to_succeed_after(monkeypatch, fail_count: int):
    """Make ``_do_connect`` fail ``fail_count`` times then succeed."""
    calls = {"n": 0}

    async def fake_do_connect(self: BridgeClient) -> bool:
        calls["n"] += 1
        if calls["n"] <= fail_count:
            return False
        self._ws = _FakeWS()
        self._connected = True
        self._reconnect_attempts = 0
        # Don't start real recv/heartbeat loops — they'd run forever.
        return True

    monkeypatch.setattr(BridgeClient, "_do_connect", fake_do_connect)
    return calls


@pytest.mark.asyncio
async def test_call_tool_reconnects_on_demand(monkeypatch):
    """A disconnected bridge should try ``connect()`` before failing."""
    _patch_connect_to_succeed_after(monkeypatch, fail_count=0)
    bridge = BridgeClient(host="127.0.0.1", port=6970)
    # Replace the real send/recv with a fake that returns a tool_result.
    fake_ws = _FakeWS()

    async def fake_do_connect(self):
        self._ws = fake_ws
        self._connected = True
        self._reconnect_attempts = 0
        self._recv_task = asyncio.create_task(self._recv_loop())
        self._heartbeat_task = asyncio.create_task(self._heartbeat_loop())
        return True

    monkeypatch.setattr(BridgeClient, "_do_connect", fake_do_connect)

    # Simulate the recv loop delivering the tool_result for id=1.
    async def fake_recv_loop(self):
        # Wait for a pending request to appear, then resolve it.
        for _ in range(200):
            if self._pending:
                break
            await asyncio.sleep(0.01)
        for fut in list(self._pending.values()):
            if not fut.done():
                fut.set_result({"ok": True, "result": {}})
        self._pending.clear()

    monkeypatch.setattr(BridgeClient, "_recv_loop", fake_recv_loop)
    monkeypatch.setattr(BridgeClient, "_heartbeat_loop", AsyncMock(return_value=None))

    result = await bridge.call_tool("editor", "state")
    assert result == {"ok": True, "result": {}}
    assert bridge.connected is True


@pytest.mark.asyncio
async def test_reconnect_does_not_give_up_after_max_attempts(monkeypatch):
    """``reconnect()`` must keep retrying past RECONNECT_MAX_ATTEMPTS."""
    calls = _patch_connect_to_succeed_after(monkeypatch, fail_count=25)
    bridge = BridgeClient(host="127.0.0.1", port=6970)

    # Speed up the test: collapse backoff + slow-stream to near-zero.
    import open_godot_mcp.bridge as bmod

    monkeypatch.setattr(bmod, "RECONNECT_BACKOFF", [0.01] * 20)
    monkeypatch.setattr(bmod, "RECONNECT_SLOW_INTERVAL", 0.01)
    monkeypatch.setattr(bmod, "RECONNECT_MAX_ATTEMPTS", 3)

    ok = await asyncio.wait_for(bridge.reconnect(), timeout=5.0)
    assert ok is True
    # Should have kept retrying past the 3-attempt cap.
    assert calls["n"] >= 4


@pytest.mark.asyncio
async def test_call_tool_recovers_after_reconnect_gave_up(monkeypatch):
    """Even if a background reconnect exhausted attempts and gave up
    (the original bug), a subsequent ``call_tool`` must trigger a fresh
    ``connect()`` and succeed when Godot is back.
    """
    # Simulate "Godot just came back": first call_tool's on-demand connect succeeds.
    fake_ws = _FakeWS()

    async def fake_do_connect(self):
        self._ws = fake_ws
        self._connected = True
        self._reconnect_attempts = 0
        self._recv_task = asyncio.create_task(self._recv_loop())
        self._heartbeat_task = asyncio.create_task(self._heartbeat_loop())
        return True

    monkeypatch.setattr(BridgeClient, "_do_connect", fake_do_connect)

    async def fake_recv_loop(self):
        for _ in range(200):
            if self._pending:
                break
            await asyncio.sleep(0.01)
        for fut in list(self._pending.values()):
            if not fut.done():
                fut.set_result({"ok": True})
        self._pending.clear()

    monkeypatch.setattr(BridgeClient, "_recv_loop", fake_recv_loop)
    monkeypatch.setattr(BridgeClient, "_heartbeat_loop", AsyncMock(return_value=None))

    bridge = BridgeClient(host="127.0.0.1", port=6970)
    # State as it would be after the old reconnect() gave up permanently.
    bridge._connected = False
    bridge._reconnect_attempts = 999
    bridge._ws = None

    result = await bridge.call_tool("editor", "state")
    assert result == {"ok": True}
    assert bridge.connected is True
    # connect() resets reconnect_attempts on success.
    assert bridge._reconnect_attempts == 0
