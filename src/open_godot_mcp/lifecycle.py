"""Process lifecycle — parent watchdog and sibling shutdown.

On Windows, killing an MCP client (parent) does NOT close the child's
inherited stdin handle, so FastMCP's stdio EOF detection never fires and
the server process leaks. The parent watchdog catches orphaned processes
by checking parent liveness periodically and self-exiting when the parent
is gone.

``shutdown_all_instances`` terminates every running ``open-godot-mcp``
process except the caller — the pre-update cleanup tool that unlocks the
``.exe`` for ``uv sync``.
"""

from __future__ import annotations

import asyncio
import logging
import os
import sys
import threading

log = logging.getLogger(__name__)

PARENT_CHECK_INTERVAL = 5.0
STILL_ACTIVE = 259


def _parent_is_alive_windows(ppid: int) -> bool:
    import ctypes

    PROCESS_QUERY_LIMITED_INFORMATION = 0x1000
    kernel32 = ctypes.windll.kernel32
    handle = kernel32.OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, False, ppid)
    if not handle:
        return False
    try:
        exit_code = ctypes.wintypes.DWORD()
        if kernel32.GetExitCodeProcess(handle, ctypes.byref(exit_code)):
            return exit_code.value == STILL_ACTIVE
        return False
    finally:
        kernel32.CloseHandle(handle)


def _parent_is_alive_unix(ppid: int) -> bool:
    if ppid <= 1:
        return False
    try:
        os.kill(ppid, 0)
        return True
    except (ProcessLookupError, PermissionError):
        return False


def parent_is_alive(ppid: int) -> bool:
    if ppid <= 1:
        return False
    if sys.platform == "win32":
        return _parent_is_alive_windows(ppid)
    return _parent_is_alive_unix(ppid)


async def parent_watchdog(ppid: int, interval: float = PARENT_CHECK_INTERVAL) -> None:
    """Exit the process if the parent disappears.

    Catches orphaned servers on Windows where stdin EOF never fires
    after the parent is killed.
    """
    while True:
        await asyncio.sleep(interval)
        if not parent_is_alive(ppid):
            log.info("Parent process %d is gone — shutting down orphaned server", ppid)
            os._exit(0)


def start_parent_watchdog_thread(ppid: int, interval: float = PARENT_CHECK_INTERVAL) -> threading.Thread:
    """Start the parent watchdog in a daemon thread.

    Thread-based (not asyncio) so it works regardless of which event loop
    FastMCP manages. Uses ``os._exit`` for immediate termination.
    """

    def _watch() -> None:
        import time

        while True:
            time.sleep(interval)
            if not parent_is_alive(ppid):
                log.info("Parent process %d is gone — shutting down orphaned server", ppid)
                os._exit(0)

    t = threading.Thread(target=_watch, name="parent-watchdog", daemon=True)
    t.start()
    return t


def shutdown_all_instances() -> int:
    """Terminate every running open-godot-mcp process except this one."""
    import subprocess

    own_pid = os.getpid()
    killed = 0

    if sys.platform == "win32":
        result = subprocess.run(
            ["tasklist", "/fi", "imagename eq open-godot-mcp.exe", "/fo", "csv", "/nh"],
            capture_output=True,
            text=True,
        )
        pids: list[int] = []
        for line in result.stdout.strip().splitlines():
            line = line.strip()
            if not line:
                continue
            parts = line.split(",")
            if len(parts) < 2:
                continue
            pid_str = parts[1].strip('"')
            try:
                pid = int(pid_str)
            except ValueError:
                continue
            if pid != own_pid:
                pids.append(pid)
        if not pids:
            print("No other open-godot-mcp processes found.")
            return 0
        print(f"Terminating {len(pids)} orphaned process(es)...")
        for pid in pids:
            subprocess.run(["taskkill", "/pid", str(pid), "/f"], capture_output=True)
            killed += 1
    else:
        own_pid_str = str(own_pid)
        result = subprocess.run(
            ["pgrep", "-f", "open-godot-mcp"],
            capture_output=True,
            text=True,
        )
        pids = []
        for line in result.stdout.strip().splitlines():
            pid_str = line.strip()
            if pid_str and pid_str != own_pid_str:
                pids.append(int(pid_str))
        if not pids:
            print("No other open-godot-mcp processes found.")
            return 0
        print(f"Terminating {len(pids)} orphaned process(es)...")
        for pid in pids:
            try:
                os.kill(pid, 15)
                killed += 1
            except ProcessLookupError:
                pass

    print(f"Done. {killed} process(es) terminated.")
    return 0
