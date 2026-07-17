#!/usr/bin/env python3
"""loop_memory_sync.py — regenerate loop_state.md registry from session_state.

This is the single machine writer of `.hermes/loop_state.md`. It reads:
- `.hermes/session_state/*.json` for active session metadata
- `.hermes/loop_state/<session_id>.md` for human-readable GoalSpec and subtasks

It writes:
- `.hermes/loop_state.md` registry (active + recent 3 completed)
- `.hermes/loop_state_archive.md` event summaries for archived sessions
- moves completed session files to `.hermes/loop_state_archive/<session_id>.md`
"""
from __future__ import annotations

import argparse
import json
import re
import shutil
import sys
from datetime import datetime, timezone
from pathlib import Path

try:
    import ahd_session
except ImportError:  # pragma: no cover
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "core" / "assets" / "runtime" / "hooks"))
    import ahd_session

MAX_REGISTRY_COMPLETED = 3
MAX_ACTIVE_SESSIONS = 3
MAX_LOOP_STATE_FILES = 10
STALE_THRESHOLD_SECONDS = 1800  # 30 minutes
ACTIVE_STATUSES = ("in_progress", "crashed", "suspected_crashed")


def _parse_front_matter(text: str) -> dict:
    """Parse a YAML front matter block into a dict (simple)."""
    result = {}
    if not text.startswith("---"):
        return result
    end = text.find("---", 3)
    if end == -1:
        return result
    fm = text[3:end].strip()
    for line in fm.splitlines():
        if ":" in line:
            key, val = line.split(":", 1)
            key = key.strip()
            val = val.strip()
            try:
                result[key] = json.loads(val)
            except Exception:
                result[key] = val
    return result


def _read_loop_state_md(path: Path) -> tuple[dict, str]:
    """Read per-session loop_state markdown, return (front_matter, body)."""
    if not path.exists():
        return {}, ""
    text = path.read_text(encoding="utf-8")
    fm = _parse_front_matter(text)
    body = text
    if text.startswith("---"):
        end = text.find("---", 3)
        if end != -1:
            body = text[end + 3:].lstrip()
    return fm, body


def _is_stale(s: dict) -> bool:
    """Return True if a session's last heartbeat or state write is older than the threshold."""
    now = datetime.now(timezone.utc).timestamp()
    timestamps = [s.get("last_heartbeat", ""), s.get("last_state_write", "")]
    max_ts = 0.0
    for ts in timestamps:
        if ts:
            try:
                t = datetime.fromisoformat(ts).timestamp()
                if t > max_ts:
                    max_ts = t
            except Exception:
                pass
    if max_ts == 0.0:
        # No timestamp information; treat as stale
        return True
    return (now - max_ts) > STALE_THRESHOLD_SECONDS


def _mark_stale_sessions(root: Path, sessions: list[dict]) -> None:
    """Mark in_progress sessions without recent heartbeat as suspected_crashed."""
    for s in sessions:
        if s.get("status") != "in_progress":
            continue
        if _is_stale(s):
            sid = s.get("session_id", "")
            if not sid:
                continue
            ahd_session.update_session_state(sid, {"status": "suspected_crashed"}, root)
            s["status"] = "suspected_crashed"


def _build_registry(root: Path) -> tuple[list[dict], list[dict]]:
    """Build active/recent session list from session_state/*.json."""
    session_dir = ahd_session.get_config_root(root) / "session_state"
    state_files = []
    if session_dir.exists():
        for f in session_dir.glob("*.json"):
            sid = f.stem
            if sid in ("current_session", ""):
                continue
            try:
                data = json.loads(f.read_text(encoding="utf-8"))
                if data.get("session_id") == sid:
                    state_files.append(data)
            except Exception:
                pass

    # Detect stale in-progress sessions before classifying
    _mark_stale_sessions(root, state_files)

    # Sort by last_state_write then last_heartbeat
    def _sort_key(s):
        for k in ("last_state_write", "last_heartbeat"):
            ts = s.get(k, "")
            if ts:
                try:
                    return datetime.fromisoformat(ts).timestamp()
                except Exception:
                    pass
        return 0.0

    state_files.sort(key=_sort_key, reverse=True)

    active = [s for s in state_files if s.get("status") in ACTIVE_STATUSES]
    completed = [s for s in state_files if s.get("status") == "completed"]
    # Keep most recent 3 completed in registry
    completed = completed[:MAX_REGISTRY_COMPLETED]

    return active + completed, active


def _enforce_active_session_limit(root: Path, sessions: list[dict]) -> list[dict]:
    """If there are more than MAX_ACTIVE_SESSIONS active sessions, queue the oldest.

    Active sessions are sorted by most recent heartbeat/state write. The newest
    MAX_ACTIVE_SESSIONS keep active; the rest are marked `queued`.
    """
    active = [s for s in sessions if s.get("status") in ACTIVE_STATUSES]
    if len(active) <= MAX_ACTIVE_SESSIONS:
        return sessions

    # Sort by recency (most recent first)
    def _sort_key(s):
        for k in ("last_state_write", "last_heartbeat"):
            ts = s.get(k, "")
            if ts:
                try:
                    return datetime.fromisoformat(ts).timestamp()
                except Exception:
                    pass
        return 0.0

    active.sort(key=_sort_key, reverse=True)
    overflow = active[MAX_ACTIVE_SESSIONS:]
    for s in overflow:
        sid = s.get("session_id", "")
        if not sid:
            continue
        ahd_session.update_session_state(sid, {"status": "queued"}, root)
        s["status"] = "queued"
    return sessions


def _archive_session(root: Path, session_id: str, body: str, front: dict) -> None:
    """Move a completed per-session loop_state md to archive."""
    archive_dir = ahd_session.get_config_root(root) / "loop_state_archive"
    archive_dir.mkdir(parents=True, exist_ok=True)
    src = ahd_session.get_config_root(root) / "loop_state" / f"{session_id}.md"
    dst = archive_dir / f"{session_id}.md"
    if src.exists():
        shutil.copy2(src, dst)
        src.unlink()

    # Append summary to archive
    archive_md = ahd_session.get_config_root(root) / "loop_state_archive.md"
    try:
        ts = ahd_session.now_utc()
        goal = front.get("goal", "") or ""
        summary = f"\n- archived session `{session_id}` at {ts}: {goal[:80]}\n"
        with open(archive_md, "a", encoding="utf-8") as f:
            f.write(summary)
    except Exception:
        pass


def _cleanup_loop_state_dir(root: Path, status_map: dict) -> None:
    """Archive oldest completed loop_state files if directory exceeds limit."""
    loop_dir = ahd_session.get_config_root(root) / "loop_state"
    if not loop_dir.exists():
        return
    files = [f for f in loop_dir.glob("*.md") if f.stem not in ("", "loop_state")]
    if len(files) <= MAX_LOOP_STATE_FILES:
        return
    # Find completed files with their mtime
    completed_files = []
    for f in files:
        fm, body = _read_loop_state_md(f)
        sid = f.stem
        status = fm.get("status") or status_map.get(sid)
        if status == "completed":
            completed_files.append((f, f.stat().st_mtime))
    completed_files.sort(key=lambda x: x[1])
    while len(files) > MAX_LOOP_STATE_FILES and completed_files:
        f, _ = completed_files.pop(0)
        sid = f.stem
        fm, body = _read_loop_state_md(f)
        _archive_session(root, sid, body, fm)
        files = [f for f in loop_dir.glob("*.md") if f.stem not in ("", "loop_state")]


def regenerate(root: Path, session_id: str = "", status: str = "") -> None:
    """Regenerate loop_state.md registry."""
    sessions, active = _build_registry(root)

    # If caller wants to set a specific status, update session_state first
    if session_id and status:
        sid = ahd_session.slugify_session_id(session_id)
        state = ahd_session.read_session_state(sid, root)
        if state:
            state["status"] = status
            if status == "completed":
                state["last_state_write"] = ahd_session.now_utc()
                state["state_written"] = True
            ahd_session.write_session_state(sid, state, root, merge=False)
            # Rebuild
            sessions, active = _build_registry(root)

    # Enforce max active sessions limit
    sessions = _enforce_active_session_limit(root, sessions)
    active = [s for s in sessions if s.get("status") in ACTIVE_STATUSES]

    # Determine active session(s) and front-matter values
    active_sids = [s.get("session_id", "") for s in active if s.get("session_id", "")]
    active_session = active_sids[0] if active_sids else None

    # Determine context fill / caveman level from active session
    context_fill_pct = 0
    caveman_level = "full"
    if active:
        context_fill_pct = active[0].get("context_fill_pct", 0)
        caveman_level = active[0].get("caveman_level", "full")

    registry_path = ahd_session.get_config_root(root) / "loop_state.md"
    registry_path.parent.mkdir(parents=True, exist_ok=True)

    lines = ["---"]
    lines.append(f"context_fill_pct: {context_fill_pct}")
    lines.append(f"caveman_level: {caveman_level}")
    lines.append(f"active_sessions: {json.dumps(active_sids, ensure_ascii=False)}")
    lines.append(f"active_session: {active_session or 'null'}")
    lines.append("---")
    lines.append("")
    lines.append("# Loop State Registry")
    lines.append("")
    lines.append("## Active sessions")
    lines.append("| session_id | goal | status | tags | owned_files | last_heartbeat |")
    lines.append("|---|---|---|---|---|---|")
    for s in sessions:
        if s.get("status") not in ACTIVE_STATUSES:
            continue
        sid = s.get("session_id", "")
        goal = s.get("goal", "")[:30]
        status = s.get("status", "")
        tags = ", ".join(s.get("tags", [])[:5]) or ""
        owned = ", ".join(s.get("owned_files", [])[:5]) or ""
        hb = s.get("last_heartbeat", "")
        lines.append(f"| {sid} | {goal} | {status} | {tags} | {owned} | {hb} |")

    lines.append("")
    lines.append(f"## Recent sessions (last {MAX_REGISTRY_COMPLETED})")
    lines.append("| session_id | goal | status | tags |")
    lines.append("|---|---|---|---|")
    recent = [s for s in sessions if s.get("status") == "completed"][:MAX_REGISTRY_COMPLETED]
    for s in recent:
        sid = s.get("session_id", "")
        goal = s.get("goal", "")[:30]
        status = s.get("status", "")
        tags = ", ".join(s.get("tags", [])[:5]) or ""
        lines.append(f"| {sid} | {goal} | {status} | {tags} |")

    queued = [s for s in sessions if s.get("status") == "queued"]
    if queued:
        lines.append("")
        lines.append("## Queued sessions")
        lines.append("| session_id | goal | tags | reason |")
        lines.append("|---|---|---|---|")
        for s in queued:
            sid = s.get("session_id", "")
            goal = s.get("goal", "")[:30]
            tags = ", ".join(s.get("tags", [])[:5]) or ""
            lines.append(f"| {sid} | {goal} | {tags} | max {MAX_ACTIVE_SESSIONS} active |")

    lines.append("")
    lines.append("## Links")
    lines.append("- knowledge_distill: .agents/knowledge_distill.md")
    lines.append("- handoff_letter: .agents/handoff_letter.md")
    lines.append("- session_archive: .hermes/loop_state_archive.md")
    lines.append("- session_archive_dir: .hermes/loop_state_archive/")

    tmp = registry_path.with_suffix(".tmp")
    tmp.write_text("\n".join(lines) + "\n", encoding="utf-8")
    tmp.replace(registry_path)

    # Build status map for loop_state cleanup
    status_map = {s.get("session_id", ""): s.get("status", "") for s in sessions}
    completed_sids = {s.get("session_id", "") for s in recent}
    loop_dir = ahd_session.get_config_root(root) / "loop_state"
    if loop_dir.exists():
        for f in loop_dir.glob("*.md"):
            sid = f.stem
            if sid == "loop_state":
                continue
            fm, body = _read_loop_state_md(f)
            status = fm.get("status") or status_map.get(sid)
            if status == "completed" and sid not in completed_sids:
                _archive_session(root, sid, body, fm)

    # Archive old session_state files for completed sessions not in recent
    for s in sessions:
        if s.get("status") == "completed" and s.get("session_id", "") not in completed_sids:
            sid = s.get("session_id", "")
            ss = ahd_session.get_config_root(root) / "session_state" / f"{sid}.json"
            if ss.exists():
                # Move to archive
                archive_dir = ahd_session.get_config_root(root) / "loop_state_archive"
                archive_dir.mkdir(parents=True, exist_ok=True)
                shutil.copy2(ss, archive_dir / f"{sid}.json")
                ss.unlink()
            # Also remove per-session runtime directory (journal, candidate_memory, etc.)
            ss_dir = ahd_session.get_config_root(root) / "session_state" / sid
            if ss_dir.exists():
                shutil.rmtree(ss_dir, ignore_errors=True)

    _cleanup_loop_state_dir(root, status_map)


def main() -> int:
    ap = argparse.ArgumentParser(description="Regenerate loop_state.md registry")
    ap.add_argument("--session", default="", help="Session ID to update")
    ap.add_argument("--status", default="", help="Status to set (completed, crashed, in_progress)")
    args = ap.parse_args()

    root = ahd_session.get_repo_root()
    regenerate(root, args.session, args.status)
    return 0


if __name__ == "__main__":
    sys.exit(main())