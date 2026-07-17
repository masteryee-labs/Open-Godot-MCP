#!/usr/bin/env python3
"""memory_audit.py — merge per-session candidate memory into knowledge_distill.md.

Run by Memory Keeper, loop-memory, or stop.py. Uses a repo lock to prevent
concurrent writes to knowledge_distill.md.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

try:
    import ahd_session
except ImportError:  # pragma: no cover
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "core" / "assets" / "runtime" / "hooks"))
    import ahd_session

MAX_KNOWLEDGE_SIZE = 8000  # characters


def _parse_knowledge_entries(text: str) -> list[dict]:
    """Parse existing knowledge_distill entries. Very tolerant."""
    entries = []
    current = {}
    for line in text.splitlines():
        if line.startswith("- trigger:"):
            current = {"trigger": line[len("- trigger:"):].strip()}
        elif line.startswith("  correct_action:") and current:
            current["correct_action"] = line[len("  correct_action:"):].strip()
        elif line.startswith("  counter:") and current:
            current["counter"] = line[len("  counter:"):].strip()
        elif line.startswith("  ts:") and current:
            current["ts"] = line[len("  ts:"):].strip()
        elif line.strip() == "" and current:
            if current:
                entries.append(current)
                current = {}
    if current:
        entries.append(current)
    return entries


def _format_entry(entry: dict) -> str:
    lines = ["- trigger: " + entry.get("trigger", "")]
    if "correct_action" in entry:
        lines.append("  correct_action: " + entry.get("correct_action", ""))
    if "counter" in entry:
        lines.append("  counter: " + entry.get("counter", ""))
    if "ts" in entry:
        lines.append("  ts: " + entry.get("ts", ""))
    return "\n".join(lines)


def _valid(candidate: dict) -> bool:
    return bool(candidate.get("trigger") and candidate.get("correct_action"))


def _dedupe(existing: list[dict], candidates: list[dict]) -> list[dict]:
    seen = set()
    for e in existing:
        key = (e.get("trigger", ""), e.get("correct_action", ""))
        seen.add(key)
    result = existing[:]
    for c in candidates:
        if not _valid(c):
            continue
        key = (c.get("trigger", ""), c.get("correct_action", ""))
        if key in seen:
            continue
        seen.add(key)
        result.append(c)
    return result


def _distill(entries: list[dict]) -> list[dict]:
    """Very basic distillation: keep top entries by recency, unique triggers."""
    seen = set()
    result = []
    for e in entries:
        key = (e.get("trigger", ""), e.get("correct_action", ""))
        if key not in seen:
            seen.add(key)
            result.append(e)
    # Keep most recent 20
    return result[-20:]


def run(root: Path, session_id: str) -> None:
    sid = ahd_session.slugify_session_id(session_id)
    candidate_path = ahd_session.get_config_root(root) / "session_state" / sid / "candidate_memory.jsonl"
    knowledge_path = ahd_session.get_config_root(root) / "knowledge_distill.md"

    candidates = []
    if candidate_path.exists():
        for line in candidate_path.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line:
                continue
            try:
                candidates.append(json.loads(line))
            except Exception:
                pass

    if not candidates:
        return

    existing = []
    if knowledge_path.exists():
        existing = _parse_knowledge_entries(knowledge_path.read_text(encoding="utf-8"))

    merged = _dedupe(existing, candidates)

    # Distill if too large
    text = "\n\n".join(_format_entry(e) for e in merged)
    if len(text) > MAX_KNOWLEDGE_SIZE:
        merged = _distill(merged)

    text = "\n\n".join(_format_entry(e) for e in merged)

    # Write with lock
    ahd_session._locked_text_write(knowledge_path, text)
    # Clear candidate memory
    try:
        candidate_path.write_text("", encoding="utf-8")
    except Exception:
        pass


def main() -> int:
    ap = argparse.ArgumentParser(description="Merge candidate memory into knowledge_distill.md")
    ap.add_argument("--session", required=True, help="Session ID")
    args = ap.parse_args()

    root = ahd_session.get_repo_root()
    run(root, args.session)
    return 0


if __name__ == "__main__":
    sys.exit(main())