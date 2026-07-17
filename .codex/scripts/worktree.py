#!/usr/bin/env python3
"""worktree.py ??Git worktree manager for parallel Worker agents.

Each Builder Worker gets its own git worktree so parallel agents don't clobber
each other's files. The Commander calls this script before dispatching parallel
Builders and after they report back.

Lifecycle:
  1. create  ??`python .codex/scripts/worktree.py create <worker_id> [--base <branch>]`
               Creates `.worktrees/<worker_id>/` as a git worktree on a new branch.
               Returns the worktree path (Agent works there).
  2. list    ??`python .codex/scripts/worktree.py list`
               Shows all active worktrees with their worker_id, branch, status.
  3. merge   ??`python .codex/scripts/worktree.py merge <worker_id>`
               Merges the worker's branch back to the base branch, removes the worktree.
  4. clean   ??`python .codex/scripts/worktree.py clean`
               Removes all Agent Harness Deploy-managed worktrees (after all merges are done).
  5. remove  ??`python .codex/scripts/worktree.py remove <worker_id>`
               Removes a worktree without merging (discard worker's changes).

Why worktrees:
  Two agents editing the same file in the same checkout = disaster.
  Git worktrees give each parallel agent its own checkout on its own branch.
  File clashes are mechanically impossible ??each agent has its own filesystem view.

Caveat (from .codex/canon/LOOP_PROTOCOL.md §5+1 components):
  Worktrees solve *file* clashes, not *cognitive* clashes. Your parallelism limit
  is your review bandwidth, not your worktree count.

Usage by the Commander:
  Before parallel dispatch:
    1. python .codex/scripts/plan_dispatch.py --analyze  ??get file ownership map
    2. python .codex/scripts/worktree.py create builder-a
    3. python .codex/scripts/worktree.py create builder-b
    4. dispatch Builder-A to .worktrees/builder-a/ with owned_files=[...]
    5. dispatch Builder-B to .worktrees/builder-b/ with owned_files=[...]
  After both report:
    6. python .codex/scripts/worktree.py merge builder-a
    7. python .codex/scripts/worktree.py merge builder-b
    8. python .codex/scripts/worktree.py clean
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

try:
    import ahd_session
except ImportError:  # pragma: no cover
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "core" / "assets" / "runtime" / "hooks"))
    import ahd_session


def _get_repo_root() -> Path:
    """Find the main repo root. Prefer git toplevel, then walk up for .git/.agents."""
    return ahd_session.get_repo_root()


ROOT = _get_repo_root()
WORKTREE_DIR = ROOT / ".worktrees"
WORKTREE_STATE = WORKTREE_DIR / ".worktree_state.json"


def _git(*args, cwd=ROOT) -> tuple[int, str, str]:
    """Run a git command, return (returncode, stdout, stderr)."""
    r = subprocess.run(["git", *args], capture_output=True, text=True, cwd=str(cwd))
    return r.returncode, r.stdout.strip(), r.stderr.strip()


def _load_state() -> dict:
    if WORKTREE_STATE.exists():
        return json.loads(WORKTREE_STATE.read_text(encoding="utf-8"))
    return {"worktrees": {}}


def _save_state(state: dict):
    WORKTREE_DIR.mkdir(parents=True, exist_ok=True)
    WORKTREE_STATE.write_text(json.dumps(state, indent=2, ensure_ascii=False), encoding="utf-8")


def _update_session_state_worktrees(session_id: str, worktree_id: str, add: bool = True) -> None:
    """Keep session_state.worktrees in sync with the worktree_state registry."""
    if not session_id:
        return
    sid = ahd_session.slugify_session_id(session_id)
    state_path = ahd_session.get_session_state_path(sid, ROOT)
    # Only update if the session has already been initialized (session_manager init).
    if not state_path.exists():
        return
    try:
        state = ahd_session.read_session_state(sid, ROOT)
        worktrees = list(state.get("worktrees", []))
        if add:
            if worktree_id not in worktrees:
                worktrees.append(worktree_id)
        else:
            worktrees = [w for w in worktrees if w != worktree_id]
        ahd_session.update_session_state(sid, {"worktrees": worktrees}, ROOT)
    except Exception:
        pass


def cmd_create(worker_id: str, base: str = "HEAD", session_id: str = "") -> int:
    """Create a worktree for a worker on a new branch."""
    WORKTREE_DIR.mkdir(parents=True, exist_ok=True)
    if session_id:
        prefix = f"wt-{session_id[:8]}-"
    else:
        prefix = ""
    prefixed_id = f"{prefix}{worker_id}"
    target = WORKTREE_DIR / prefixed_id

    if target.exists():
        print(f"  [!] Worktree already exists: {target}")
        return 1

    branch_name = f"agent-harness-deploy/{prefixed_id}"

    # Create branch and worktree
    rc, out, err = _git("worktree", "add", "-b", branch_name, str(target), base)
    if rc != 0:
        print(f"  [!] Failed to create worktree: {err}")
        return 1

    # Record state
    state = _load_state()
    state["worktrees"][prefixed_id] = {
        "path": str(target),
        "branch": branch_name,
        "base": base,
        "status": "active",
        "session_id": session_id,
    }
    _save_state(state)
    _update_session_state_worktrees(session_id, prefixed_id, add=True)

    print(f"  [+] Created worktree for {prefixed_id}")
    print(f"      Path:   {target}")
    print(f"      Branch: {branch_name}")
    print(f"      Base:   {base}")
    print(f"\n  Agent works in: {target}")
    return 0


def cmd_list() -> int:
    """List all active worktrees."""
    state = _load_state()
    if not state["worktrees"]:
        print("  No active worktrees.")
        return 0

    print(f"  {'Worker ID':<20} {'Branch':<30} {'Status':<10} {'Path'}")
    print(f"  {'-'*20} {'-'*30} {'-'*10} {'-'*40}")
    for wid, info in state["worktrees"].items():
        print(f"  {wid:<20} {info['branch']:<30} {info['status']:<10} {info['path']}")
    return 0


def cmd_merge(worker_id: str) -> int:
    """Merge a worker's branch back to the current branch and remove the worktree."""
    state = _load_state()
    if worker_id not in state["worktrees"]:
        print(f"  [!] No worktree for worker '{worker_id}'")
        return 1

    info = state["worktrees"][worker_id]
    branch = info["branch"]
    wt_path = Path(info["path"])

    if not wt_path.exists():
        print(f"  [!] Worktree path does not exist: {wt_path}")
        # Clean up stale state
        del state["worktrees"][worker_id]
        _save_state(state)
        return 1

    # Get current branch (merge target)
    rc, current_branch, err = _git("rev-parse", "--abbrev-ref", "HEAD")
    if rc != 0:
        print(f"  [!] Cannot determine current branch: {err}")
        return 1

    # Merge the worker's branch
    rc, out, err = _git("merge", "--no-ff", branch, "-m",
                        f"Merge worktree: {worker_id} ({branch})")
    if rc != 0:
        print(f"  [!] Merge failed for {worker_id}: {err}")
        print(f"      Resolve conflicts manually, then run: python .codex/scripts/worktree.py remove {worker_id}")
        info["status"] = "merge-conflict"
        _save_state(state)
        return 1

    # Remove the worktree
    rc, out, err = _git("worktree", "remove", str(wt_path), "--force")
    if rc != 0:
        # Fallback: manual removal
        import shutil
        shutil.rmtree(wt_path, ignore_errors=True)

    # Delete the merged branch
    _git("branch", "-D", branch)

    # Update state
    session_id = info.get("session_id", "")
    del state["worktrees"][worker_id]
    _save_state(state)
    _update_session_state_worktrees(session_id, worker_id, add=False)

    print(f"  [+] Merged {worker_id} ({branch} -> {current_branch})")
    print(f"      Worktree removed.")
    return 0


def cmd_remove(worker_id: str) -> int:
    """Remove a worktree without merging (discard changes)."""
    state = _load_state()
    if worker_id not in state["worktrees"]:
        print(f"  [!] No worktree for worker '{worker_id}'")
        return 1

    info = state["worktrees"][worker_id]
    branch = info["branch"]
    wt_path = Path(info["path"])

    # Remove worktree
    if wt_path.exists():
        rc, out, err = _git("worktree", "remove", str(wt_path), "--force")
        if rc != 0:
            import shutil
            shutil.rmtree(wt_path, ignore_errors=True)

    # Delete branch
    _git("branch", "-D", branch)

    # Update state
    session_id = info.get("session_id", "")
    del state["worktrees"][worker_id]
    _save_state(state)
    _update_session_state_worktrees(session_id, worker_id, add=False)

    print(f"  [-] Removed worktree for {worker_id} (changes discarded)")
    return 0


def cmd_clean() -> int:
    """Remove all Agent Harness Deploy-managed worktrees."""
    state = _load_state()
    if not state["worktrees"]:
        print("  No active worktrees to clean.")
        return 0

    count = 0
    for worker_id in list(state["worktrees"].keys()):
        cmd_remove(worker_id)
        count += 1

    print(f"\n  [+] Cleaned {count} worktree(s).")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description="Git worktree manager for parallel Worker agents.")
    sub = ap.add_subparsers(dest="command", required=True)

    p_create = sub.add_parser("create", help="Create a worktree for a worker.")
    p_create.add_argument("worker_id", help="Unique worker identifier (e.g. builder-a)")
    p_create.add_argument("--base", default="HEAD", help="Base branch/commit (default: HEAD)")
    p_create.add_argument("--session", default="", help="Session ID prefix to avoid conflicts (default: none)")

    sub.add_parser("list", help="List all active worktrees.")

    p_merge = sub.add_parser("merge", help="Merge a worker's branch and remove worktree.")
    p_merge.add_argument("worker_id")

    p_remove = sub.add_parser("remove", help="Remove a worktree without merging.")
    p_remove.add_argument("worker_id")

    sub.add_parser("clean", help="Remove all Agent Harness Deploy-managed worktrees.")

    args = ap.parse_args()

    if args.command == "create":
        return cmd_create(args.worker_id, args.base, args.session)
    elif args.command == "list":
        return cmd_list()
    elif args.command == "merge":
        return cmd_merge(args.worker_id)
    elif args.command == "remove":
        return cmd_remove(args.worker_id)
    elif args.command == "clean":
        return cmd_clean()
    return 1


if __name__ == "__main__":
    sys.exit(main())
