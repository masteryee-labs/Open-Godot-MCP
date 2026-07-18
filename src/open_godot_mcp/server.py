"""FastMCP server entry point — registers all tools, resources, prompts.

Per Docs/01-Architecture/Architecture.md:
  Layer 1 (MCP Server): Python + FastMCP, stdio transport.
  Exposes ~30 tools, ~145 actions, MCP resources, MCP prompts.

The server is stateless across restarts; all Godot state lives in the
Editor Bridge / runtime. We just route.
"""

from __future__ import annotations

import asyncio
import logging

from fastmcp import FastMCP

from .context import ServerContext
from .tools import register_all_tools
from .utils.port_resolver import DEFAULT_BRIDGE_PORT, env_port

log = logging.getLogger("open_godot_mcp.server")

# Module-level singleton context (tools close over it)
_ctx: ServerContext | None = None


def get_context() -> ServerContext:
    global _ctx
    if _ctx is None:
        _ctx = ServerContext()
    return _ctx


def build_mcp(ctx: ServerContext) -> FastMCP:
    """Build a FastMCP instance with all tools/resources/prompts registered."""
    mcp = FastMCP(
        "open-godot-mcp",
        version=ctx.server_version,
        instructions=(
            "Open Godot MCP — control Godot editor, run games with deterministic "
            "playtesting, test multiplayer, debug, and more. "
            "All tools return {ok: bool, ...}; check ok before using results. "
            "Godot types are JSON objects: Vector2={x,y}, Vector3={x,y,z}, Color={r,g,b,a}. "
            "Node paths look like /root/...; resource paths look like res://... "
            "Use godot_health check to verify connectivity before other tools."
        ),
    )
    register_all_tools(mcp, ctx)
    _register_resources(mcp, ctx)
    _register_prompts(mcp, ctx)
    return mcp


def _register_resources(mcp: FastMCP, ctx: ServerContext) -> None:
    """Register MCP Resources (Docs/02-Tools/Index.md §MCP Resources)."""
    from .resources import register_resources

    register_resources(mcp, ctx)


def _register_prompts(mcp: FastMCP, ctx: ServerContext) -> None:
    """Register MCP Prompts (Docs/02-Tools/Index.md §MCP Prompts)."""
    from .prompts import register_prompts

    register_prompts(mcp, ctx)


def run_stdio(
    *,
    bridge_host: str = "127.0.0.1",
    bridge_port: int | None = None,
    read_only: bool = False,
    allow_eval: bool = True,
    allowed_paths: list[str] | None = None,
    projects: list[str] | None = None,
) -> None:
    """Start the MCP server on stdio transport.

    This is the main entry point called by __main__.main().
    """
    ctx = get_context()
    ctx.read_only = read_only
    ctx.allow_eval = allow_eval
    ctx.allowed_paths = allowed_paths
    ctx.projects = projects

    # Adopt projects lazily on first tool call (inside mcp.run's event loop).
    # Running adopt in a separate asyncio.run() would kill the WebSocket when
    # that temporary loop closes.
    ctx._pending_adopts = projects or []
    ctx._adopt_host = bridge_host
    ctx._adopt_port = bridge_port or env_port("OPEN_GODOT_MCP_PORT", DEFAULT_BRIDGE_PORT)

    mcp = build_mcp(ctx)
    log.info("Starting Open Godot MCP server (stdio) v%s", ctx.server_version)
    mcp.run(transport="stdio")


def main() -> None:
    """Alias for __main__.main without arg parsing (for programmatic use)."""
    run_stdio()


if __name__ == "__main__":
    main()
