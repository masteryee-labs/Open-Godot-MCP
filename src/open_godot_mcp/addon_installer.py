"""Addon installer — copy the GDScript addon into a Godot project.

Used by ``open-godot-mcp --install-addon /path/to/project`` (Installation Guide §方式 C).
"""

from __future__ import annotations

import logging
import shutil
from pathlib import Path

log = logging.getLogger(__name__)


def install_addon(project_path: Path) -> bool:
    """Copy addons/open_godot_mcp/ from this package into *project_path*/addons/.

    Returns True on success.
    """
    project_path = Path(project_path).resolve()
    if not (project_path / "project.godot").exists():
        log.error("Not a Godot project (no project.godot): %s", project_path)
        return False

    # Find the bundled addon: either alongside this file (dev mode) or in share/
    here = Path(__file__).resolve().parent
    candidates = [
        here.parent.parent.parent / "addons" / "open_godot_mcp",  # repo root (dev)
        Path(__file__).resolve().parent / "addons" / "open_godot_mcp",  # installed
    ]
    src: Path | None = None
    for c in candidates:
        if (c / "plugin.cfg").exists():
            src = c
            break
    if src is None:
        log.error("Could not locate bundled addon source")
        return False

    dest = project_path / "addons" / "open_godot_mcp"
    dest.parent.mkdir(parents=True, exist_ok=True)
    if dest.exists():
        log.info("Addon already exists at %s — overwriting", dest)
        shutil.rmtree(dest)
    shutil.copytree(src, dest)
    log.info("Addon installed to %s", dest)
    log.info("Enable it in Godot: Project > Project Settings > Plugins")
    return True
