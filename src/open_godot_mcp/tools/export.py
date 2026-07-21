"""Export tools — godot_export (mixed).

Docs: 02-Tools/Utility.md §godot_export
  presets, export, add_preset

`presets` and `add_preset` route to the bridge (read/write export_presets.cfg).
`export` spawns a headless Godot CLI process to build the game binary.
"""
from __future__ import annotations

import asyncio
import logging
import os
import shutil
from pathlib import Path

from fastmcp import FastMCP

from ..context import ServerContext
from ..utils.error_codes import fail, ok
from ._helpers import guard_write, make_tool

log = logging.getLogger(__name__)


def _find_godot_bin() -> str | None:
    return os.environ.get("GODOT_BIN") or shutil.which("godot")


def _get_project_path(ctx: ServerContext) -> str | None:
    bridge = ctx.bridge()
    if bridge and bridge.info.project_path:
        return bridge.info.project_path
    return None


def register_export_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    @make_tool(
        mcp,
        ctx,
        "godot_export",
        "Game export. Actions: presets,export(preset,dest_path),add_preset(name,platform,settings).",
    )
    async def godot_export(action: str, params: dict | None = None) -> dict:
        params = params or {}
        if action == "presets":
            return await ctx.call("godot_export", "presets", params)
        elif action == "add_preset":
            blocked = guard_write(ctx)
            if blocked:
                return blocked
            return await ctx.call("godot_export", "add_preset", params)
        elif action == "export":
            blocked = guard_write(ctx)
            if blocked:
                return blocked
            preset = params.get("preset", "")
            dest_path = params.get("dest_path", "")
            if not preset or not dest_path:
                return fail("INVALID_ARGUMENT", "preset and dest_path required")
            project_path = _get_project_path(ctx)
            if not project_path:
                return fail(
                    "BRIDGE_NOT_CONNECTED",
                    "No project path available (bridge not connected)",
                )
            godot = _find_godot_bin()
            if not godot:
                return fail(
                    "NOT_FOUND",
                    "Godot executable not found (set GODOT_BIN or add to PATH)",
                )
            dest = Path(dest_path)
            dest.parent.mkdir(parents=True, exist_ok=True)
            # Use --export-release for production builds.
            # Godot CLI: godot --headless --export-release <preset> <dest> --path <project>
            cmd = [
                godot, "--headless", "--export-release",
                preset, str(dest), "--path", project_path,
            ]
            log.info("Exporting: %s", " ".join(cmd))
            try:
                proc = await asyncio.create_subprocess_exec(
                    *cmd,
                    stdout=asyncio.subprocess.PIPE,
                    stderr=asyncio.subprocess.PIPE,
                )
                stdout, stderr = await asyncio.wait_for(proc.communicate(), timeout=120.0)
                if proc.returncode != 0:
                    err_msg = stderr.decode(errors="replace") if stderr else "unknown error"
                    return fail(
                        "INTERNAL_ERROR",
                        f"Export failed (exit {proc.returncode}): {err_msg[:500]}",
                    )
            except TimeoutError:
                return fail("TIMEOUT", "Export timed out after 120s")
            except OSError as e:
                return fail("INTERNAL_ERROR", f"Failed to run Godot: {e}")
            size = dest.stat().st_size if dest.exists() else 0
            return ok(path=str(dest), size=size)
        else:
            return fail("INVALID_ARGUMENT", f"Unknown action: {action}")
