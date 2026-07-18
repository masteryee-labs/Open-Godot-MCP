"""Command-line entry point for ``open-godot-mcp``.

Run as ``open-godot-mcp`` (installed script) or ``python -m open_godot_mcp``.
"""

from __future__ import annotations

import argparse
import logging
import sys
from pathlib import Path

from .server import run_stdio

log = logging.getLogger("open_godot_mcp")


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="open-godot-mcp",
        description="Open Godot MCP — MCP server for AI-driven Godot development.",
    )
    parser.add_argument("--version", action="version", version="open-godot-mcp 0.1.0")
    # Connection
    parser.add_argument(
        "--bridge-host",
        default="127.0.0.1",
        help="Editor Bridge WebSocket host (default: 127.0.0.1)",
    )
    parser.add_argument(
        "--bridge-port",
        type=int,
        default=None,
        help="Editor Bridge WebSocket port (default: 6970, or OPEN_GODOT_MCP_PORT env)",
    )
    # Security
    parser.add_argument("--read-only", action="store_true", help="Read-only mode (no write tools)")
    parser.add_argument("--no-eval", action="store_true", help="Disable godot_exec eval")
    parser.add_argument(
        "--allowed-paths",
        default=None,
        help="Comma-separated list of allowed project paths",
    )
    # Multi-project
    parser.add_argument(
        "--projects",
        default=None,
        help="Comma-separated list of Godot project paths to manage",
    )
    # Addon install helper
    parser.add_argument(
        "--install-addon",
        metavar="PROJECT_PATH",
        default=None,
        help="Copy the GDScript addon into the given Godot project and exit",
    )
    # Logging
    parser.add_argument(
        "--log-level",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR"],
        help="Log level (default: INFO)",
    )
    return parser


def main() -> None:
    parser = _build_parser()
    args = parser.parse_args()

    logging.basicConfig(
        level=getattr(logging, args.log_level),
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
        stream=sys.stderr,
    )

    # --install-addon: copy addon then exit
    if args.install_addon:
        from .addon_installer import install_addon

        target = Path(args.install_addon)
        ok = install_addon(target)
        sys.exit(0 if ok else 1)

    allowed_paths: list[str] | None = None
    if args.allowed_paths:
        allowed_paths = [p.strip() for p in args.allowed_paths.split(",") if p.strip()]

    projects: list[str] | None = None
    if args.projects:
        projects = [p.strip() for p in args.projects.split(",") if p.strip()]

    run_stdio(
        bridge_host=args.bridge_host,
        bridge_port=args.bridge_port,
        read_only=args.read_only,
        allow_eval=not args.no_eval,
        allowed_paths=allowed_paths,
        projects=projects,
    )


if __name__ == "__main__":
    main()
