#!/usr/bin/env python3
"""Shared session helpers for Agent Harness Deploy runtime hooks and scripts.

Provides:
- session_id resolution with fallback chain
- filesystem-safe slugification
- repo root discovery
- locked read/write of session_state JSON
- locked file read/write utilities
"""
from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import uuid
from pathlib import Path
from datetime import datetime, timezone
from typing import Any, Dict, Optional

def get_config_root(root: Path) -> Path:
    """Determine the config root directory for runtime state files.

    When deployed, this file lives at ``<config_root>/scripts/ahd_session.py`` or
    ``<config_root>/hooks/ahd_session.py``. The config root is ``parent.parent``.
    In the source repo (``.agents/scripts/ahd_session.py``) the parent.parent
    is ``core/assets/runtime/`` which is NOT a config root, so we fall back to
    ``root / ".agents"``.

    This is what makes the harness work across tools with different config roots:
    Antigravity uses ``.agents/``, Claude Code uses ``.claude/``, Codex uses
    ``.codex/``, etc. The canonical text references ``.agents/`` as a placeholder;
    at runtime this function resolves it to the actual deployed config root.
    """
    here = Path(__file__).resolve()
    parent_name = here.parent.name
    if parent_name in ("scripts", "hooks"):
        candidate = here.parent.parent
        # Distinguish a deployed config root from the source-repo
        # core/assets/runtime/ directory. A deployed config root has
        # session_state/ or loop_state/ siblings (created by _sync_runtime).
        # The source-repo core/assets/runtime/ does not.
        if (candidate / "session_state").is_dir() or (candidate / "loop_state").is_dir():
            return candidate
    return root / ".agents"


def get_shared_state_root(root: Path) -> Path:
    """Return the canonical shared-state root (always ``.agents/``).

    Shared state files (user_profile.md, knowledge_distill.md,
    handoff_letter.md, context_quick_lookup.md) live at ``.agents/`` and are
    shared across all tools. Per-tool session state (loop_state.md,
    session_state/, context_flags/) lives at the tool's config root.

    Backward compatibility: if a shared state file exists in the tool's config
    root but not in ``.agents/``, this function still returns ``.agents/``.
    The caller should use ``resolve_shared_state_file()`` for automatic
    migration fallback.
    """
    return root / ".agents"


def resolve_shared_state_file(filename: str, root: Path) -> Path:
    """Resolve a shared state file path with backward-compat fallback.

    Checks ``.agents/<filename>`` first (canonical location).
    Falls back to ``<config_root>/<filename>`` (old AHD location) if the
    canonical path doesn't exist but the old one does.

    Does NOT copy — callers that need to persist should write to
    ``get_shared_state_root(root) / filename``.
    """
    canonical = get_shared_state_root(root) / filename
    if canonical.exists():
        return canonical
    old = get_config_root(root) / filename
    if old.exists():
        return old
    return canonical  # default to canonical for new file creation


def _lock_relpath(root: Path) -> Path:
    """Return the lock file path relative to the config root."""
    return get_config_root(root) / "tmp" / "ahd_session.lock"


def get_repo_root(start_from: Optional[Path] = None) -> Path:
    """Find the main repo root.

    1. Try git rev-parse --show-toplevel.
    2. Walk up from start_from (default cwd) for .git, .agents, AGENTS.md, pyproject.toml, README.md.
    3. Fallback to cwd.
    """
    cwd = Path(start_from) if start_from else Path.cwd()
    try:
        r = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            capture_output=True, text=True, cwd=str(cwd)
        )
        if r.returncode == 0 and r.stdout.strip():
            return Path(r.stdout.strip())
    except Exception:
        pass
    for parent in [cwd, *cwd.parents]:
        for marker in (".git", ".agents", "AGENTS.md", "pyproject.toml", "README.md"):
            if (parent / marker).exists():
                return parent
    return cwd


def slugify_session_id(sid: str, max_len: int = 64) -> str:
    """Make a filesystem-safe session id slug."""
    if not sid:
        sid = "unknown"
    # Replace separators and illegal chars
    sid = re.sub(r"[:/\\\s|<>\"'?*\"]+", "-", sid)
    sid = re.sub(r"-+", "-", sid)
    sid = sid.strip("-.")
    if not sid:
        sid = "unknown"
    sid = sid[:max_len]
    return sid


def get_session_id(data: Optional[Dict[str, Any]] = None, env_prefix: str = "AHD") -> str:
    """Resolve session_id with fallback chain.

    1. tool input `data["session_id"]`
    2. env var `{env_prefix}_SESSION_ID`
    3. file `.agents/session_state/current_session`
    4. UUID
    """
    data = data or {}
    sid = data.get("session_id", "")
    if sid:
        return slugify_session_id(sid)

    sid = os.environ.get(f"{env_prefix}_SESSION_ID", "")
    if sid:
        return slugify_session_id(sid)

    # Racy fallback: read current_session file
    try:
        root = get_repo_root()
        current_file = get_config_root(root) / "session_state" / "current_session"
        if current_file.exists():
            sid = current_file.read_text(encoding="utf-8").strip()
            if sid:
                return slugify_session_id(sid)
    except Exception:
        pass

    return slugify_session_id(str(uuid.uuid4()))


def get_session_state_path(session_id: str, root: Optional[Path] = None) -> Path:
    """Return path to session_state JSON."""
    root = root or get_repo_root()
    return get_config_root(root) / "session_state" / f"{slugify_session_id(session_id)}.json"


def get_context_flags_path(session_id: str, root: Optional[Path] = None) -> Path:
    """Return per-session context_flags path."""
    root = root or get_repo_root()
    return get_config_root(root) / "context_flags" / f"{slugify_session_id(session_id)}.json"


def get_loop_state_path(session_id: str, root: Optional[Path] = None) -> Path:
    """Return per-session loop_state markdown path."""
    root = root or get_repo_root()
    return get_config_root(root) / "loop_state" / f"{slugify_session_id(session_id)}.md"


def _get_lock_path(root: Path) -> Path:
    """Return a lock file path for the repo."""
    return _lock_relpath(root)


def _acquire_lock(lock_path: Path, timeout: float = 10.0) -> Any:
    """Acquire an inter-process lock. Prefer filelock, fallback to fcntl/msvcrt/lockfile."""
    lock_path.parent.mkdir(parents=True, exist_ok=True)

    # Prefer filelock (cross-platform, reliable)
    try:
        from filelock import FileLock, Timeout
        lock = FileLock(str(lock_path))
        try:
            lock.acquire(timeout=timeout)
            return lock
        except Timeout:
            pass
    except Exception:
        pass

    # Fallback: OS-specific advisory locking
    if sys.platform == "win32":
        try:
            import msvcrt
            f = open(lock_path, "wb")
            f.write(b"lock")
            f.flush()
            msvcrt.locking(f.fileno(), msvcrt.LK_LOCK, 1)
            return f
        except Exception:
            try:
                f.close()
            except Exception:
                pass
    else:
        try:
            import fcntl
            f = open(lock_path, "w+")
            fcntl.flock(f.fileno(), fcntl.LOCK_EX)
            return f
        except Exception:
            try:
                f.close()
            except Exception:
                pass

    # Last resort: atomic lockfile sentinel via O_CREAT|O_EXCL
    try:
        import time
        pid = os.getpid()
        start = time.time()
        while time.time() - start < timeout:
            try:
                fd = os.open(str(lock_path), os.O_CREAT | os.O_EXCL | os.O_WRONLY)
                os.write(fd, str(pid).encode("utf-8"))
                os.close(fd)
                return lock_path
            except FileExistsError:
                time.sleep(0.05)
            except Exception:
                break
        return None
    except Exception:
        return None


def _release_lock(handle: Any) -> None:
    """Release a lock handle from _acquire_lock."""
    if handle is None:
        return
    try:
        if hasattr(handle, "release"):
            handle.release()
        elif hasattr(handle, "close"):
            try:
                import fcntl
                fcntl.flock(handle.fileno(), fcntl.LOCK_UN)
            except Exception:
                pass
            try:
                import msvcrt
                msvcrt.locking(handle.fileno(), msvcrt.LK_UNLCK, 1)
            except Exception:
                pass
            handle.close()
        elif isinstance(handle, Path):
            try:
                handle.unlink()
            except Exception:
                pass
    except Exception:
        pass


def _locked_json_read(path: Path, default: Any = None) -> Any:
    """Read a JSON file with a repo-level lock."""
    root = get_repo_root(path.parent if path.is_absolute() else None)
    lock = _acquire_lock(_get_lock_path(root))
    try:
        if path.exists():
            return json.loads(path.read_text(encoding="utf-8"))
        return default
    except Exception:
        return default
    finally:
        _release_lock(lock)


def _locked_json_write(path: Path, data: Any) -> None:
    """Write a JSON file with a repo-level lock."""
    root = get_repo_root(path.parent if path.is_absolute() else None)
    lock = _acquire_lock(_get_lock_path(root))
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        tmp = path.with_suffix(path.suffix + ".tmp")
        tmp.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
        tmp.replace(path)
    finally:
        _release_lock(lock)


def _locked_json_update(path: Path, update_fn, default: Any = None) -> Any:
    """Read a JSON file, apply update_fn under the same lock, and write it back."""
    root = get_repo_root(path.parent if path.is_absolute() else None)
    lock = _acquire_lock(_get_lock_path(root))
    try:
        data = default
        if path.exists():
            try:
                data = json.loads(path.read_text(encoding="utf-8"))
            except Exception:
                pass
        data = update_fn(data)
        path.parent.mkdir(parents=True, exist_ok=True)
        tmp = path.with_suffix(path.suffix + ".tmp")
        tmp.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
        tmp.replace(path)
        return data
    finally:
        _release_lock(lock)


def _locked_text_write(path: Path, text: str) -> None:
    """Write a text file with a repo-level lock."""
    root = get_repo_root(path.parent if path.is_absolute() else None)
    lock = _acquire_lock(_get_lock_path(root))
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        tmp = path.with_suffix(path.suffix + ".tmp")
        tmp.write_text(text, encoding="utf-8")
        tmp.replace(path)
    finally:
        _release_lock(lock)


def read_session_state(session_id: str, root: Optional[Path] = None) -> Dict[str, Any]:
    """Read session_state JSON with lock."""
    path = get_session_state_path(session_id, root)
    return _locked_json_read(path, default={})


def write_session_state(session_id: str, data: Dict[str, Any], root: Optional[Path] = None, merge: bool = True) -> None:
    """Write session_state JSON with lock.

    If merge=True, merge with existing data under the same lock. This lets
    `post_tool_use` update `last_heartbeat` without overwriting `current_subtask`
    set by `loop-memory`, and prevents lost updates under concurrent writes.
    """
    path = get_session_state_path(session_id, root)
    if merge:
        _locked_json_update(path, lambda existing: {**(existing or {}), **data}, default={})
    else:
        _locked_json_write(path, data)


def update_session_state(session_id: str, fields: Dict[str, Any], root: Optional[Path] = None) -> None:
    """Merge fields into session_state without overwriting unrelated fields."""
    write_session_state(session_id, fields, root, merge=True)


def write_context_flags(session_id: str, data: Dict[str, Any], root: Optional[Path] = None) -> None:
    """Write per-session context_flags.json."""
    path = get_context_flags_path(session_id, root)
    _locked_json_update(path, lambda existing: {**(existing or {}), **data}, default={})


def read_context_flags(session_id: str, root: Optional[Path] = None) -> Dict[str, Any]:
    """Read per-session context_flags.json."""
    path = get_context_flags_path(session_id, root)
    return _locked_json_read(path, default={})


def append_jsonl(path: Path, record: Dict[str, Any]) -> None:
    """Append a JSON line to a jsonl file with lock."""
    root = get_repo_root(path.parent if path.is_absolute() else None)
    lock = _acquire_lock(_get_lock_path(root))
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        with open(path, "a", encoding="utf-8") as f:
            f.write(json.dumps(record, ensure_ascii=False) + "\n")
    finally:
        _release_lock(lock)


def now_utc() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")
