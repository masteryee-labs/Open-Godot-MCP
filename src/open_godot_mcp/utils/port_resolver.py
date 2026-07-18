"""Port resolution — find free ports, avoid conflicts.

Implements the port strategy from Docs/01-Architecture/Connection-Stability.md:
  Priority: env var > EditorSettings > auto-avoidance > default
  Default: 6970 (bridge), 6006 (DAP), 6005 (LSP), 7070 (game)
  Multi-instance: base + 10n (see Multi-Instance.md)

On Windows, also detects Hyper-V/WSL2/Docker reserved port ranges via
``netsh interface ipv4 show excludedportrange protocol=tcp``.
"""

from __future__ import annotations

import logging
import os
import platform
import socket
import subprocess

log = logging.getLogger(__name__)

# Defaults from the docs
DEFAULT_BRIDGE_PORT = 6970
DEFAULT_DAP_PORT = 6006
DEFAULT_LSP_PORT = 6005
DEFAULT_GAME_PORT = 7070

ENV_BRIDGE_PORT = "OPEN_GODOT_MCP_PORT"
ENV_DAP_PORT = "OPEN_GODOT_MCP_DAP_PORT"
ENV_LSP_PORT = "OPEN_GODOT_MCP_LSP_PORT"

# Backpressure / limits (Connection-Stability.md §封包與背壓控制)
OUTBOUND_BUFFER_LIMIT = 4 * 1024 * 1024  # 4 MB
PACKET_DRAIN_CAP = 32
SCREENSHOT_MAX_SIZE = 2 * 1024 * 1024  # 2 MB
SCENE_TREE_NODE_LIMIT = 500


def env_port(env_var: str, default: int | None) -> int | None:
    """Read a port from an environment variable, or return *default*."""
    raw = os.environ.get(env_var)
    if raw is None or not raw.strip():
        return default
    try:
        p = int(raw)
    except ValueError:
        log.warning("Invalid port in %s=%r, using default %s", env_var, raw, default)
        return default
    if not (1 <= p <= 65535):
        log.warning("Port %d out of range in %s, using default %s", p, env_var, default)
        return default
    return p


def get_windows_excluded_ports() -> list[tuple[int, int]]:
    """Return list of ``(start, end)`` TCP port ranges excluded on Windows.

    These are reserved by Hyper-V / WSL2 / Docker Desktop. On non-Windows or
    if ``netsh`` fails, returns an empty list.
    """
    if platform.system() != "Windows":
        return []
    try:
        out = subprocess.run(
            ["netsh", "interface", "ipv4", "show", "excludedportrange", "protocol=tcp"],
            capture_output=True,
            text=True,
            timeout=5,
            check=False,
        )
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return []
    ranges: list[tuple[int, int]] = []
    # Output has a header then rows of: start  end  (sometimes extra columns)
    stdout = out.stdout or ""
    in_data = False
    for line in stdout.splitlines():
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith("---"):
            in_data = True
            continue
        if not in_data:
            # Look for the divider line that precedes data
            if "Start" in stripped and "End" in stripped:
                in_data = True
            continue
        parts = stripped.split()
        if len(parts) >= 2:
            try:
                start = int(parts[0])
                end = int(parts[1])
                ranges.append((start, end))
            except ValueError:
                continue
    return ranges


def is_port_free(port: int, host: str = "127.0.0.1") -> bool:
    """True if *port* can be bound on *host*."""
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            s.bind((host, port))
            return True
    except OSError:
        return False


def is_port_excluded_by_windows(port: int) -> bool:
    """True if *port* falls in a Windows reserved range."""
    return any(start <= port <= end for start, end in get_windows_excluded_ports())


def resolve_port(
    preferred: int | None,
    default: int,
    *,
    host: str = "127.0.0.1",
    avoid_windows_reserved: bool = True,
) -> int:
    """Resolve a single port following the doc priority chain.

    1. Use *preferred* if given and free (and not Windows-reserved).
    2. Otherwise try *default*.
    3. If that's taken or reserved, increment until a free port is found.
    """
    excluded = get_windows_excluded_ports() if (avoid_windows_reserved and platform.system() == "Windows") else []

    def _ok(p: int) -> bool:
        if not (1 <= p <= 65535):
            return False
        if any(s <= p <= e for s, e in excluded):
            log.info("Port %d is in a Windows reserved range, skipping", p)
            return False
        return is_port_free(p, host)

    candidates: list[int] = []
    if preferred is not None:
        candidates.append(preferred)
    candidates.append(default)

    for p in candidates:
        if _ok(p):
            return p

    # Increment from default until we find one
    p = default + 1
    while p <= 65535:
        if _ok(p):
            return p
        p += 1
    # Wrap around as last resort
    p = 1024
    while p < default:
        if _ok(p):
            return p
        p += 1
    raise RuntimeError(f"No free port found near {default}")


def allocate_instance_ports(instance_index: int, *, host: str = "127.0.0.1") -> dict[str, int]:
    """Allocate a port block for instance *n* (0-based).

    Per Multi-Instance.md:
      bridge = 6970 + 10n
      dap    = 6006 + 10n
      lsp    = 6005 + 10n
      game   = 7070 + 10n
    Conflicts auto-increment.
    """
    n = instance_index
    return {
        "bridge": resolve_port(DEFAULT_BRIDGE_PORT + 10 * n, DEFAULT_BRIDGE_PORT + 10 * n, host=host),
        "dap": resolve_port(DEFAULT_DAP_PORT + 10 * n, DEFAULT_DAP_PORT + 10 * n, host=host),
        "lsp": resolve_port(DEFAULT_LSP_PORT + 10 * n, DEFAULT_LSP_PORT + 10 * n, host=host),
        "game": resolve_port(DEFAULT_GAME_PORT + 10 * n, DEFAULT_GAME_PORT + 10 * n, host=host),
    }
