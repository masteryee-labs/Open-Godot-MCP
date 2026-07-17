#!/usr/bin/env python3
"""Stop hook — clean exit when the agent session ends.

Called by the AI tool when a session stops (agent finishes, user stops, or
context limit hit). Receives JSON on stdin:
  {"session_id": "..."}

Exit codes:
  0 = success (always — stop hooks never block)

What it does:
  1. Resolves session_id.
  2. Reads session_state and determines status:
     - completed if state_written is true and last_state_write is recent
     - crashed otherwise
  3. If completed: runs memory_audit to merge candidate memory, then loop_memory_sync
     to archive session files and update loop_state.md registry.
  4. If crashed: runs loop_memory_sync to mark suspected_crashed without deleting.
  5. Appends a session-end marker to loop_state_archive.md.
  6. Cleans temporary files older than 24h in .agents/tmp/.
"""
import json
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

import ahd_session

SESSION_MARKER = "<!-- Agent Harness Deploy-stop-hook -->"


def _call_script(root: Path, script: str, *args) -> None:
    """Call a helper script in .agents/scripts/ or scripts/."""
    for script_dir in (ahd_session.get_config_root(root) / "scripts", root / "scripts"):
        candidate = script_dir / script
        if candidate.exists():
            try:
                subprocess.run(
                    [sys.executable, str(candidate), *args],
                    cwd=str(root), capture_output=True, timeout=30
                )
            except Exception:
                pass
            return


def _clean_tmp(tmp_dir: Path) -> None:
    """Remove temp files older than 24h."""
    if not tmp_dir.exists():
        return
    cutoff = time.time() - 86400
    for f in tmp_dir.iterdir():
        try:
            if f.is_file() and f.stat().st_mtime < cutoff:
                f.unlink()
        except Exception:
            pass


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        data = {}

    session_id = ahd_session.get_session_id(data)
    root = ahd_session.get_repo_root()
    ts = ahd_session.now_utc()

    archive_path = ahd_session.get_config_root(root) / "loop_state_archive.md"
    tmp_dir = ahd_session.get_config_root(root) / "tmp"

    session_state = ahd_session.read_session_state(session_id, root)
    state_written = session_state.get("state_written", False)
    last_state_write = session_state.get("last_state_write", "")

    completed = False
    if state_written and last_state_write:
        try:
            last_ts = datetime.fromisoformat(last_state_write)
            elapsed = (datetime.now(timezone.utc) - last_ts).total_seconds()
            if elapsed < 1800:  # 30 minutes
                completed = True
        except Exception:
            pass

    if completed:
        # Merge candidate memory before archiving
        _call_script(root, "memory_audit.py", "--session", session_id)
        # Archive and update registry
        _call_script(root, "loop_memory_sync.py", "--session", session_id, "--status", "completed")
    else:
        # Mark as suspected crashed; do not delete session_state
        _call_script(root, "loop_memory_sync.py", "--session", session_id, "--status", "suspected_crashed")

    # Append session-end marker to cold archive
    try:
        archive_path.parent.mkdir(parents=True, exist_ok=True)
        with open(archive_path, "a", encoding="utf-8") as f:
            f.write(f"\n{SESSION_MARKER} session_end ts={ts} session_id={session_id} status={'completed' if completed else 'crashed'}\n")
    except Exception:
        pass

    # Clean old temp files
    _clean_tmp(tmp_dir)

    sys.exit(0)


if __name__ == "__main__":
    main()