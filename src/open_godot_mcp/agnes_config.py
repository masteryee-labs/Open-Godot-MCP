"""Agnes / NVIDIA API config — load, save, path resolution, git safety check.

Config lives OUTSIDE any git repo by default, at:
    <user_home>/.open_godot_mcp/config.json

This keeps API keys out of the project repo (no accidental commit).
If the user picks a custom path inside a git working tree, we warn but
do NOT auto-modify .gitignore (per user requirement).

Both Godot (OS.get_environment) and Python (Path.home) can resolve the
same default path, so the dock and the MCP server agree on location.
"""

from __future__ import annotations

import json
import logging
import os
from dataclasses import dataclass, field, asdict
from pathlib import Path
from typing import Any

log = logging.getLogger(__name__)

CONFIG_DIR_NAME = ".open_godot_mcp"
CONFIG_FILENAME = "config.json"

DEFAULTS: dict[str, Any] = {
    "agnes": {
        "enabled": False,
        "api_keys": [],
        "vision": False,
        "image_generate": False,
        "video_generate": False,
        "base_url": "https://apihub.agnes-ai.com/v1",
        "text_model": "agnes-2.0-flash",
        "image_model": "agnes-image-2.0-flash",
        "video_model": "agnes-video-v2.0",
    },
    "nvidia": {
        "enabled": False,
        "api_keys": [],
        "vision": False,
        "image_generate": False,
        "vlm_base_url": "https://integrate.api.nvidia.com/v1",
        "vlm_model": "meta/llama-3.2-90b-vision-instruct",
        "imggen_base_url": "https://ai.api.nvidia.com/v1/genai",
        "imggen_model": "black-forest-labs/flux.2-klein-4b",
    },
}


@dataclass
class GitSafetyReport:
    """Result of checking whether the config path is git-safe."""

    in_git_repo: bool = False
    gitignore_covers: bool = False
    repo_root: str | None = None
    warning: str = ""


def default_config_path() -> Path:
    """Resolve the default config path under the user home directory."""
    home = os.environ.get("USERPROFILE") or os.environ.get("HOME")
    if not home:
        # Last-resort fallback: cwd. Unusual on any real OS.
        home = str(Path.cwd())
    return Path(home) / CONFIG_DIR_NAME / CONFIG_FILENAME


def _deep_merge(base: dict, override: dict) -> dict:
    """Recursively merge override into base; base provides defaults."""
    out = dict(base)
    for k, v in override.items():
        if isinstance(v, dict) and isinstance(out.get(k), dict):
            out[k] = _deep_merge(out[k], v)
        else:
            out[k] = v
    return out


def _is_inside_git_repo(path: Path) -> tuple[bool, Path | None]:
    """Walk parents of *path* looking for a .git directory.

    Returns (is_inside, repo_root). Symlinks are resolved first.
    """
    try:
        p = path.resolve()
    except OSError:
        p = path
    # If path is a file, start from its parent.
    if p.is_file():
        p = p.parent
    for parent in [p, *p.parents]:
        if (parent / ".git").exists():
            return True, parent
    return False, None


def _gitignore_covers(repo_root: Path, target: Path) -> bool:
    """Best-effort: does any .gitignore in repo_root cover *target*?

    Checks each .gitignore from repo_root down to the target's parent.
    Matches either the absolute filename or the config dir name.
    """
    try:
        rel = target.resolve().relative_to(repo_root.resolve())
    except ValueError:
        return False
    parts = rel.parts
    candidates = [
        target.name,
        CONFIG_DIR_NAME,
        "/".join(parts),
        "/".join(parts[:-1]) + "/" if parts else "",
    ]
    # Walk .gitignore files from repo_root to target's parent dir.
    cur = repo_root
    for i in range(len(parts)):
        gi = cur / ".gitignore"
        if gi.is_file():
            try:
                patterns = [
                    ln.strip() for ln in gi.read_text(encoding="utf-8", errors="replace").splitlines()
                    if ln.strip() and not ln.strip().startswith("#")
                ]
            except OSError:
                patterns = []
            for pat in patterns:
                pat_clean = pat.rstrip("/")
                if pat_clean in candidates or pat == target.name:
                    return True
        if i < len(parts) - 1:
            cur = cur / parts[i]
            if not cur.is_dir():
                break
    return False


def check_git_safety(path: Path | None = None) -> GitSafetyReport:
    """Check whether *path* is inside a git repo and whether .gitignore covers it.

    Used by the dock to warn the user. Does NOT modify .gitignore.
    """
    path = path or default_config_path()
    inside, root = _is_inside_git_repo(path)
    if not inside:
        return GitSafetyReport(in_git_repo=False)
    covered = _gitignore_covers(root, path)
    if covered:
        return GitSafetyReport(
            in_git_repo=True,
            gitignore_covers=True,
            repo_root=str(root),
        )
    return GitSafetyReport(
        in_git_repo=True,
        gitignore_covers=False,
        repo_root=str(root),
        warning=(
            f"Config file path is inside git repo ({root}) and is NOT covered "
            f"by .gitignore. API keys may be committed accidentally. "
            f"Move the file outside the repo, or add '{path}' to .gitignore manually."
        ),
    )


def load_config(path: Path | None = None) -> dict[str, Any]:
    """Load config from *path* (default: user home). Returns merged-with-defaults dict.

    Missing file → returns DEFAULTS (all disabled). Corrupt file → returns DEFAULTS
    and logs a warning (does not raise).

    Backward compat: if the file has ``api_key`` (singular string) instead of
    ``api_keys`` (list), it's converted to ``api_keys: [value]``.
    """
    path = path or default_config_path()
    if not path.is_file():
        return _deep_merge(DEFAULTS, {})
    try:
        raw = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as e:
        log.warning("agnes_config: failed to read %s: %s — using defaults", path, e)
        return _deep_merge(DEFAULTS, {})
    if not isinstance(raw, dict):
        log.warning("agnes_config: %s root is not an object — using defaults", path)
        return _deep_merge(DEFAULTS, {})
    # Backward compat: api_key (string) → api_keys (list)
    for provider in ("agnes", "nvidia"):
        sec = raw.get(provider)
        if isinstance(sec, dict) and "api_key" in sec and "api_keys" not in sec:
            k = sec.pop("api_key")
            sec["api_keys"] = [k] if k else []
    merged = _deep_merge(DEFAULTS, raw)
    # Sanitize: ensure api_keys is a list of non-empty strings
    for provider in ("agnes", "nvidia"):
        sec = merged.get(provider, {})
        keys = sec.get("api_keys", [])
        if isinstance(keys, str):
            keys = [keys]
        sec["api_keys"] = [k.strip() for k in keys if isinstance(k, str) and k.strip()]
    return merged


def save_config(cfg: dict[str, Any], path: Path | None = None) -> GitSafetyReport:
    """Write *cfg* to *path* (default: user home) with restrictive permissions.

    Returns the git safety report so callers can warn the user.
    POSIX: chmod 600. Windows: best-effort (file is in user home by default).
    """
    path = path or default_config_path()
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(cfg, indent=2, ensure_ascii=False), encoding="utf-8")
    try:
        os.chmod(path, 0o600)
    except OSError:
        pass  # Windows: chmod is mostly a no-op; user-home path is already private
    return check_git_safety(path)


# ---- capability queries (used by tool registration) ----


def _has_keys(sec: dict) -> bool:
    """True if the provider section has at least one non-empty API key."""
    keys = sec.get("api_keys", [])
    if isinstance(keys, str):
        keys = [keys]
    return any(isinstance(k, str) and k.strip() for k in keys)


def get_api_keys(sec: dict) -> list[str]:
    """Return the list of non-empty API keys from a provider section."""
    keys = sec.get("api_keys", [])
    if isinstance(keys, str):
        keys = [keys]
    return [k.strip() for k in keys if isinstance(k, str) and k.strip()]


def agnes_tools_enabled(cfg: dict[str, Any]) -> list[str]:
    """Return the list of agnes_* tool names that should be registered."""
    a = cfg.get("agnes", {})
    if not a.get("enabled") or not _has_keys(a):
        return []
    out = []
    if a.get("vision"):
        out.append("agnes_vision")
    if a.get("image_generate"):
        out.append("agnes_image_generate")
    if a.get("video_generate"):
        out.append("agnes_video_generate")
    return out


def nvidia_tools_enabled(cfg: dict[str, Any]) -> list[str]:
    """Return the list of nvidia_* tool names that should be registered."""
    n = cfg.get("nvidia", {})
    if not n.get("enabled") or not _has_keys(n):
        return []
    out = []
    if n.get("vision"):
        out.append("nvidia_vision")
    if n.get("image_generate"):
        out.append("nvidia_image_generate")
    return out


def all_enabled_tools(cfg: dict[str, Any]) -> list[str]:
    return agnes_tools_enabled(cfg) + nvidia_tools_enabled(cfg)
