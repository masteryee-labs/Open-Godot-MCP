#!/usr/bin/env python3
"""pre_task_audit.py — check whether a new task overlaps with active sessions.

Usage:
    python .devin/scripts/pre_task_audit.py --files scripts/sync.py,adapters/base.py --tags concurrency
    python .devin/scripts/pre_task_audit.py --files scripts/sync.py --session s-20260709-abc

Exit codes:
    0 = no conflict
    1 = conflict detected
"""
from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

try:
    import ahd_session
except ImportError:  # pragma: no cover
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "core" / "assets" / "runtime" / "hooks"))
    import ahd_session

try:
    from plan_dispatch import _expand_file_hints, _get_active_sessions
except ImportError:
    # In .devin/scripts/ we can import from the same directory
    sys.path.insert(0, str(Path(__file__).resolve().parent))
    from plan_dispatch import _expand_file_hints, _get_active_sessions

MAX_ACTIVE_SESSIONS = 3
STALE_THRESHOLD_SECONDS = 1800  # 30 minutes


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
        return True
    return (now - max_ts) > STALE_THRESHOLD_SECONDS


def audit(root: Path, new_files: list[str], new_tags: list[str], session_id: str = "") -> dict:
    """Compare the new task against active sessions and return conflict report."""
    active = _get_active_sessions(root)
    expanded_new = set(new_files)
    if new_files:
        try:
            expanded_new = _expand_file_hints(new_files)
        except Exception:
            pass
    new_tags_set = set(t.strip() for t in new_tags if t.strip())

    conflicts = []
    for s in active:
        sid = s.get("session_id", "")
        if sid and sid == session_id:
            continue

        # Treat stale in-progress sessions as suspected_crashed for the audit
        is_stale = _is_stale(s)
        if s.get("status") == "in_progress" and is_stale:
            s["status"] = "suspected_crashed"
            try:
                ahd_session.update_session_state(sid, {"status": "suspected_crashed"}, root)
            except Exception:
                pass

        owned = set(s.get("owned_files", []))
        affected = set(s.get("affected_files", []))
        if not affected and owned:
            try:
                affected = _expand_file_hints(list(owned))
            except Exception:
                pass
        tags = set(s.get("tags", []))

        file_overlap = (owned | affected) & expanded_new
        tag_overlap = tags & new_tags_set

        if file_overlap:
            for f in sorted(file_overlap):
                reason = "file overlap"
                suffix = ""
                if is_stale:
                    reason = "file overlap with stale session"
                    suffix = " (stale/suspected_crashed)"
                conflicts.append({
                    "session_id": sid,
                    "current_subtask": s.get("current_subtask", ""),
                    "goal": s.get("goal", ""),
                    "file": f,
                    "reason": reason,
                    "suggested_action": "ask_human",
                    "message": (
                        f"Active session {sid}{suffix} (current_subtask: {s.get('current_subtask', '')}) "
                        f"owns/affects {f}. Ask the human whether to continue it or start new."
                    ),
                })
        if tag_overlap:
            for t in sorted(tag_overlap):
                reason = "tag overlap"
                suffix = ""
                if is_stale:
                    reason = "tag overlap with stale session"
                    suffix = " (stale/suspected_crashed)"
                conflicts.append({
                    "session_id": sid,
                    "current_subtask": s.get("current_subtask", ""),
                    "goal": s.get("goal", ""),
                    "tag": t,
                    "reason": reason,
                    "suggested_action": "ask_human",
                    "message": (
                        f"Active session {sid}{suffix} has tag '{t}' which overlaps the new task. "
                        f"Ask the human whether to continue it or start new."
                    ),
                })

    return {
        "ok": not conflicts,
        "active_sessions_count": len(active),
        "max_active_sessions": MAX_ACTIVE_SESSIONS,
        "conflicts": conflicts,
    }


def main() -> int:
    ap = argparse.ArgumentParser(description="Pre-task audit for active session conflicts")
    ap.add_argument("--files", default="", help="comma-separated file paths for the new task")
    ap.add_argument("--tags", default="", help="comma-separated tags for the new task")
    ap.add_argument("--session", default="", help="Current session ID (optional, exclude self from audit)")
    ap.add_argument("--json", action="store_true", help="Output JSON")
    args = ap.parse_args()

    root = ahd_session.get_repo_root()
    new_files = [f.strip() for f in args.files.split(",") if f.strip()]
    new_tags = [t.strip() for t in args.tags.split(",") if t.strip()]

    result = audit(root, new_files, new_tags, args.session)

    if args.json:
        print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        if result["ok"]:
            print("No conflict with active sessions.")
        else:
            print("Conflict detected:")
            for c in result["conflicts"]:
                print(f"  [{c['reason']}] {c['message']}")

    return 0 if result["ok"] else 1


if __name__ == "__main__":
    sys.exit(main())
