"""Open Godot MCP — Model Context Protocol server for AI-driven Godot game development.

See Docs/ for full documentation.
"""

from importlib.metadata import PackageNotFoundError, version as _pkg_version

try:
    __version__ = _pkg_version("open-godot-mcp")
except PackageNotFoundError:
    __version__ = "0.0.0-dev"
