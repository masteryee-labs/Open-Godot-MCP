#!/usr/bin/env python3
"""Session manager CLI for Agent Harness Deploy.

Commands:
  init <session_id> --goal "" [--complexity S|M|L|XL]
  heartbeat <session_id>
  status <session_id> <completed|crashed>
  sync

This script is intended to be called by hooks, workers, or the AI directly.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

# Import ahd_session: in .agents/scripts/ it's in the same directory; in source
# scripts/ it lives under core/assets/runtime/hooks.
try:
    import ahd_session
except ImportError:  # pragma: no cover
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "core" / "assets" / "runtime" / "hooks"))
    import ahd_session


MAX_ACTIVE_SESSIONS = 3
ACTIVE_STATUSES = {"in_progress", "crashed", "suspected_crashed"}


def _count_active_sessions(root: Path) -> int:
    count = 0
    session_dir = ahd_session.get_config_root(root) / "session_state"
    if not session_dir.exists():
        return 0
    for f in session_dir.glob("*.json"):
        if f.name == "current_session":
            continue
        try:
            data = json.loads(f.read_text(encoding="utf-8"))
            if data.get("status") in ACTIVE_STATUSES:
                count += 1
        except Exception:
            pass
    return count


def cmd_init(args: argparse.Namespace) -> int:
    root = ahd_session.get_repo_root()
    sid = ahd_session.slugify_session_id(args.session_id)
    active_count = _count_active_sessions(root)

    # Enforce max active sessions at the creation gate
    status = "in_progress"
    if active_count >= MAX_ACTIVE_SESSIONS:
        if args.force:
            status = "queued"
            print(f"[!] Active session limit reached ({active_count}/{MAX_ACTIVE_SESSIONS}). Creating as queued.")
        else:
            print(f"[!] Cannot initialize session: active session limit reached ({active_count}/{MAX_ACTIVE_SESSIONS}).")
            print(f"    Wait for an active session to complete, or use --force to create a queued session.")
            return 1

    state = {
        "session_id": sid,
        "goal": args.goal or "",
        "status": status,
        "complexity": args.complexity or "M",
        "current_subtask": "",
        "last_action": "",
        "last_heartbeat": ahd_session.now_utc(),
        "last_state_write": "",
        "last_tool": "",
        "last_file": "",
        "state_written": False,
        "owned_files": [],
        "affected_files": [],
        "tags": [],
        "context_fill_pct": 0,
        "caveman_level": "full",
        "context_flags": {"context_oversized": False},
        "worktrees": [],
    }
    ahd_session.write_session_state(sid, state, root, merge=False)
    # Also seed the current_session file (racy, best effort)
    try:
        current_file = ahd_session.get_config_root(root) / "session_state" / "current_session"
        current_file.write_text(sid, encoding="utf-8")
    except Exception:
        pass
    if status == "queued":
        print(f"[+] Session initialized as queued: {sid}")
    else:
        print(f"[+] Session initialized: {sid}")
    return 0


def cmd_heartbeat(args: argparse.Namespace) -> int:
    root = ahd_session.get_repo_root()
    sid = ahd_session.slugify_session_id(args.session_id)
    ahd_session.update_session_state(sid, {"last_heartbeat": ahd_session.now_utc()}, root)
    print(f"[+] Heartbeat updated: {sid}")
    return 0


def cmd_status(args: argparse.Namespace) -> int:
    root = ahd_session.get_repo_root()
    sid = ahd_session.slugify_session_id(args.session_id)
    status = args.status
    if status not in ("completed", "crashed", "in_progress", "suspected_crashed"):
        print("[!] Status must be one of: completed, crashed, in_progress, suspected_crashed")
        return 1
    updates = {"status": status}
    if status == "completed":
        updates["last_state_write"] = ahd_session.now_utc()
        updates["state_written"] = True
    ahd_session.update_session_state(sid, updates, root)
    print(f"[+] Status set to {status}: {sid}")
    return 0


def cmd_sync(args: argparse.Namespace) -> int:
    """Call loop_memory_sync.py to regenerate loop_state.md."""
    root = ahd_session.get_repo_root()
    for script_dir in (ahd_session.get_config_root(root) / "scripts", root / "scripts"):
        candidate = script_dir / "loop_memory_sync.py"
        if candidate.exists():
            import subprocess
            cmd = [sys.executable, str(candidate)]
            if args.session_id:
                cmd.extend(["--session", args.session_id])
            if args.status:
                cmd.extend(["--status", args.status])
            r = subprocess.run(cmd, cwd=str(root))
            return r.returncode
    print("[!] loop_memory_sync.py not found")
    return 1


def main() -> int:
    ap = argparse.ArgumentParser(description="Session manager CLI")
    sub = ap.add_subparsers(dest="command", required=True)

    p_init = sub.add_parser("init", help="Initialize a session")
    p_init.add_argument("session_id")
    p_init.add_argument("--goal", default="")
    p_init.add_argument("--complexity", default="M", choices=["S", "M", "L", "XL"])
    p_init.add_argument("--force", action="store_true",
                        help="Allow creating a queued session even if active limit is reached")

    p_hb = sub.add_parser("heartbeat", help="Update heartbeat timestamp")
    p_hb.add_argument("session_id")

    p_status = sub.add_parser("status", help="Set session status")
    p_status.add_argument("session_id")
    p_status.add_argument("status", choices=["completed", "crashed", "in_progress", "suspected_crashed"])

    p_sync = sub.add_parser("sync", help="Regenerate loop_state.md registry")
    p_sync.add_argument("--session", default="")
    p_sync.add_argument("--status", default="")

    args = ap.parse_args()

    if args.command == "init":
        return cmd_init(args)
    if args.command == "heartbeat":
        return cmd_heartbeat(args)
    if args.command == "status":
        return cmd_status(args)
    if args.command == "sync":
        return cmd_sync(args)
    return 1


if __name__ == "__main__":
    sys.exit(main())