"""Bridge — WebSocket client to the GDScript Editor Bridge.

Implements channel 2 from Docs/01-Architecture/Transport.md:
  JSON-RPC 2.0 over WebSocket, with request_id correlation.
  Server -> Bridge: tool_invoke
  Bridge -> Server: tool_result, event
  Handshake: session_id, Godot version, project path, plugin version, auth_token

Connection stability (Connection-Stability.md):
  - heartbeat: ping every 5s, 3s no pong -> suspected_dead, 3x -> reconnect
  - smart reconnect: 1s,2s,4s,8s,16s,30s backoff, max 20 attempts
  - backpressure: 4MB outbound limit, 32 packets/tick drain, 500-node scene limit

The bridge runs as a singleton per Godot instance; the InstanceManager owns
multiple BridgeClient instances for multi-instance testing.
"""

from __future__ import annotations

import asyncio
import json
import logging
import time
from dataclasses import dataclass, field
from typing import Any

import websockets
from websockets.exceptions import ConnectionClosed

from .utils.error_codes import fail
from .utils.port_resolver import (
    DEFAULT_BRIDGE_PORT,
    ENV_BRIDGE_PORT,
    env_port,
    is_port_free,
    resolve_port,
)

log = logging.getLogger(__name__)

# Heartbeat (Connection-Stability.md §對策 3)
HEARTBEAT_INTERVAL = 5.0  # seconds
HEARTBEAT_TIMEOUT = 3.0  # seconds to wait for pong
SUSPECTED_DEAD_THRESHOLD = 3  # consecutive misses -> disconnect + reconnect

# Reconnect (Connection-Stability.md §對策 4)
RECONNECT_BACKOFF = [1, 2, 4, 8, 16, 30]  # seconds, 30s cap
RECONNECT_MAX_ATTEMPTS = 20
# After the bounded backoff sequence exhausts, keep retrying at this slow
# interval so the bridge recovers when Godot comes back instead of giving
# up permanently (spec §對策 4: "不靜默失敗").
RECONNECT_SLOW_INTERVAL = 60.0

# Backpressure (Connection-Stability.md §封包與背壓控制)
OUTBOUND_BUFFER_LIMIT = 4 * 1024 * 1024
DEFAULT_TOOL_TIMEOUT = 30.0  # seconds per tool call


@dataclass
class BridgeInfo:
    """Info learned from the bridge handshake."""

    session_id: str = ""
    godot_version: str = ""
    project_path: str = ""
    plugin_version: str = ""
    auth_token: str = ""


@dataclass
class BridgeClient:
    """Async WebSocket client to one Editor Bridge instance."""

    host: str = "127.0.0.1"
    port: int = DEFAULT_BRIDGE_PORT
    auth_token: str = ""
    server_version: str = "0.1.0"

    # Runtime state
    _ws: Any = None  # websockets connection
    _connected: bool = False
    _info: BridgeInfo = field(default_factory=BridgeInfo)
    _next_id: int = 1
    _pending: dict[int, asyncio.Future[dict]] = field(default_factory=dict)
    _event_handlers: dict[str, list] = field(default_factory=dict)
    _recv_task: asyncio.Task | None = None
    _heartbeat_task: asyncio.Task | None = None
    _missed_pongs: int = 0
    _last_pong: float = 0.0
    _reconnect_attempts: int = 0
    _connect_lock: asyncio.Lock = field(default_factory=asyncio.Lock)
    _closed: bool = False
    # Bridge -> Server event queue (for game_started, runtime_ready, etc.)
    _events: asyncio.Queue[dict] = field(default_factory=asyncio.Queue)

    # ---- lifecycle ----

    @property
    def connected(self) -> bool:
        return self._connected

    @property
    def info(self) -> BridgeInfo:
        return self._info

    @property
    def runtime_connected(self) -> bool:
        """True if the bridge reports a connected game runtime."""
        # Updated by event handler; default False
        return getattr(self, "_runtime_connected", False)

    async def connect(self) -> bool:
        """Connect to the bridge, perform handshake. Returns True on success."""
        if self._closed:
            return False
        async with self._connect_lock:
            if self._connected and self._ws is not None:
                return True
            # Tear down any stale connection before reconnecting to avoid
            # duplicate recv/heartbeat loops racing on the same socket.
            for task in (self._heartbeat_task, self._recv_task):
                if task and not task.done():
                    task.cancel()
            self._heartbeat_task = None
            self._recv_task = None
            if self._ws is not None:
                try:
                    await self._ws.close()
                except Exception:
                    pass
                self._ws = None
            self._connected = False
            return await self._do_connect()

    async def _do_connect(self) -> bool:
        url = f"ws://{self.host}:{self.port}"
        try:
            self._ws = await asyncio.wait_for(
                websockets.connect(url, max_size=OUTBOUND_BUFFER_LIMIT, ping_interval=None),
                timeout=5.0,
            )
        except (TimeoutError, OSError) as e:
            log.debug("Bridge connect to %s failed: %s", url, e)
            return False

        # Handshake (Transport.md §通道 2)
        hs_id = self._next_id
        self._next_id += 1
        hs_msg = {
            "jsonrpc": "2.0",
            "id": hs_id,
            "method": "handshake",
            "params": {
                "server_version": self.server_version,
                "auth_token": self.auth_token,
            },
        }
        try:
            await self._ws.send(json.dumps(hs_msg))
            raw = await asyncio.wait_for(self._ws.recv(), timeout=5.0)
            resp = json.loads(raw)
        except (TimeoutError, OSError, json.JSONDecodeError) as e:
            log.warning("Handshake with %s failed: %s", url, e)
            await self._ws.close()
            self._ws = None
            return False

        if resp.get("id") != hs_id or "error" in resp:
            log.warning("Handshake rejected: %s", resp.get("error"))
            await self._ws.close()
            self._ws = None
            return False

        result = resp.get("result", {})
        self._info = BridgeInfo(
            session_id=result.get("session_id", ""),
            godot_version=result.get("godot_version", ""),
            project_path=result.get("project_path", ""),
            plugin_version=result.get("plugin_version", ""),
            auth_token=result.get("auth_token", ""),
        )
        self._connected = True
        self._reconnect_attempts = 0
        self._missed_pongs = 0
        self._last_pong = time.monotonic()

        # Start background tasks
        self._recv_task = asyncio.create_task(self._recv_loop())
        self._heartbeat_task = asyncio.create_task(self._heartbeat_loop())

        log.info(
            "Bridge connected: %s (Godot %s, project %s, plugin %s)",
            url,
            self._info.godot_version,
            self._info.project_path,
            self._info.plugin_version,
        )
        return True

    async def disconnect(self) -> None:
        self._closed = True
        self._connected = False
        for task in (self._heartbeat_task, self._recv_task):
            if task and not task.done():
                task.cancel()
                try:
                    await task
                except (asyncio.CancelledError, Exception):
                    pass
        self._heartbeat_task = None
        self._recv_task = None
        if self._ws:
            try:
                await self._ws.close()
            except Exception:
                pass
            self._ws = None
        # Cancel pending requests
        for fut in self._pending.values():
            if not fut.done():
                fut.set_result(fail("BRIDGE_NOT_CONNECTED", "Bridge disconnected"))
        self._pending.clear()

    async def reconnect(self) -> bool:
        """Attempt to reconnect with exponential backoff, then slow-stream.

        Runs the bounded backoff sequence (1s..30s, 20 attempts). If that
        exhausts, switches to slow-stream (every RECONNECT_SLOW_INTERVAL)
        indefinitely so the bridge recovers when Godot comes back instead
        of giving up permanently. Teardown of any stale connection is
        handled by ``connect()`` under the connect lock.
        """
        while not self._closed:
            if self._reconnect_attempts < RECONNECT_MAX_ATTEMPTS:
                idx = min(self._reconnect_attempts, len(RECONNECT_BACKOFF) - 1)
                delay = RECONNECT_BACKOFF[idx]
                log.info(
                    "Reconnect attempt %d/%d in %.1fs",
                    self._reconnect_attempts + 1,
                    RECONNECT_MAX_ATTEMPTS,
                    delay,
                )
            else:
                delay = RECONNECT_SLOW_INTERVAL
                log.info("Reconnect in slow-stream (every %.0fs)", delay)
            await asyncio.sleep(delay)
            if self._closed:
                break
            self._reconnect_attempts += 1
            if await self.connect():
                return True
        return False

    # ---- tool invocation ----

    async def call_tool(
        self,
        tool: str,
        action: str,
        params: dict | None = None,
        *,
        timeout: float = DEFAULT_TOOL_TIMEOUT,
    ) -> dict:
        """Send a ``tool_invoke`` to the bridge and await ``tool_result``."""
        if not self._connected or self._ws is None:
            # On-demand reconnect: if the background reconnect gave up or
            # never started, try one fresh connect before failing. Cheap
            # (5s timeout) and recovers when Godot came back between calls.
            if self._closed:
                return fail("BRIDGE_NOT_CONNECTED", f"Bridge closed (host={self.host}:{self.port})")
            if not await self.connect():
                return fail("BRIDGE_NOT_CONNECTED", f"Bridge not connected (host={self.host}:{self.port})")
        req_id = self._next_id
        self._next_id += 1
        msg = {
            "jsonrpc": "2.0",
            "id": req_id,
            "method": "tool_invoke",
            "params": {"tool": tool, "action": action, "params": params or {}},
        }
        fut: asyncio.Future[dict] = asyncio.get_event_loop().create_future()
        self._pending[req_id] = fut
        try:
            await self._ws.send(json.dumps(msg))
        except (OSError, ConnectionClosed) as e:
            self._pending.pop(req_id, None)
            self._connected = False
            asyncio.create_task(self.reconnect())
            return fail("BRIDGE_NOT_CONNECTED", f"Send failed: {e}")
        try:
            return await asyncio.wait_for(fut, timeout=timeout)
        except TimeoutError:
            self._pending.pop(req_id, None)
            return fail("TIMEOUT", f"Tool {tool}.{action} timed out after {timeout}s")

    async def call_tool_unwrapped(self, tool: str, action: str, params: dict | None = None, **kw) -> dict:
        """Like call_tool but if the response has ok:false, raise McpError.

        Convenience for handlers that want exceptions instead of dict-checking.
        """
        from .utils.error_codes import McpError
        resp = await self.call_tool(tool, action, params, **kw)
        if resp.get("ok") is False:
            e = resp.get("error", {})
            raise McpError(code=e.get("code", "INTERNAL_ERROR"), message=e.get("message", "unknown"))
        return resp

    # ---- events ----

    def on_event(self, event_type: str, handler) -> None:
        self._event_handlers.setdefault(event_type, []).append(handler)

    async def next_event(self, timeout: float | None = None) -> dict | None:
        try:
            return await asyncio.wait_for(self._events.get(), timeout=timeout)
        except TimeoutError:
            return None

    # ---- background loops ----

    async def _recv_loop(self) -> None:
        assert self._ws is not None
        try:
            async for raw in self._ws:
                try:
                    msg = json.loads(raw)
                except json.JSONDecodeError:
                    log.warning("Bad JSON from bridge: %r", raw[:200])
                    continue
                if "id" in msg and ("result" in msg or "error" in msg):
                    # Response to a pending request — any response means the
                    # bridge is alive, so update heartbeat state.
                    self._last_pong = time.monotonic()
                    self._missed_pongs = 0
                    fut = self._pending.pop(msg["id"], None)
                    if fut and not fut.done():
                        if "error" in msg:
                            fut.set_result({"ok": False, "error": msg["error"]})
                        else:
                            fut.set_result(msg["result"])
                elif msg.get("method") == "event":
                    params = msg.get("params", {})
                    etype = params.get("type", "")
                    # Track runtime connection state
                    if etype in ("runtime_ready", "runtime_connected"):
                        self._runtime_connected = True
                    elif etype in ("runtime_disconnected", "game_stopped", "game_crashed"):
                        self._runtime_connected = False
                    await self._events.put(params)
                    for h in self._event_handlers.get(etype, []):
                        try:
                            res = h(params)
                            if asyncio.iscoroutine(res):
                                await res
                        except Exception:
                            log.exception("Event handler for %s failed", etype)
                elif msg.get("method") == "pong":
                    self._last_pong = time.monotonic()
                    self._missed_pongs = 0
                elif msg.get("method") == "tool_result":
                    # Unsolicited result (e.g., async notification) — ignore
                    pass
        except (ConnectionClosed, OSError) as e:
            log.info("Bridge connection lost: %s", e)
        except asyncio.CancelledError:
            raise
        except Exception:
            log.exception("Bridge recv loop crashed")
        finally:
            self._connected = False
            if not self._closed:
                asyncio.create_task(self.reconnect())

    async def _heartbeat_loop(self) -> None:
        try:
            while self._connected and self._ws is not None:
                await asyncio.sleep(HEARTBEAT_INTERVAL)
                if not self._connected or self._ws is None:
                    break
                try:
                    ping_msg = {"jsonrpc": "2.0", "method": "ping", "params": {}}
                    await self._ws.send(json.dumps(ping_msg))
                except (OSError, ConnectionClosed):
                    self._connected = False
                    break
                # Check pong timeliness
                if time.monotonic() - self._last_pong > HEARTBEAT_INTERVAL + HEARTBEAT_TIMEOUT:
                    self._missed_pongs += 1
                    log.warning("Bridge missed pong (%d/%d)", self._missed_pongs, SUSPECTED_DEAD_THRESHOLD)
                    if self._missed_pongs >= SUSPECTED_DEAD_THRESHOLD:
                        log.warning("Bridge suspected dead — forcing reconnect")
                        self._connected = False
                        try:
                            await self._ws.close()
                        except Exception:
                            pass
                        break
        except asyncio.CancelledError:
            raise
        except Exception:
            log.exception("Heartbeat loop crashed")


def resolve_bridge_port(preferred: int | None = None) -> int:
    """Resolve the bridge port from env/config/default (Connection-Stability.md §對策 1)."""
    if preferred is None:
        preferred = env_port(ENV_BRIDGE_PORT, DEFAULT_BRIDGE_PORT)
    return resolve_port(preferred, DEFAULT_BRIDGE_PORT)


async def probe_bridge(host: str, port: int, timeout: float = 1.0) -> bool:
    """Quick check: is something listening on host:port?"""
    if not is_port_free(port, host):
        # Port is in use — could be the bridge. Try a quick WS handshake.
        return True
    return False
