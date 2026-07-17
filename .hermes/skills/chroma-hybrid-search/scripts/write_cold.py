#!/usr/bin/env python3
"""Append a cold-note entry to ~/.deep-memory/cold-notes/raw.jsonl.

Usage (from repo root):
    <PY> .hermes/skills/chroma-hybrid-search/scripts/write_cold.py \
        --text "When editing large CSVs, use Python csv module, not edit tool." \
        --tags "csv,big-file" \
        --project "agent-harness-deploy"

The entry is appended as a single JSON line with project, date, tags, and text.
After writing, rebuild the index with update_db.py.
"""

import argparse
import json
import os
from datetime import datetime, timezone
from pathlib import Path


def workspace_path(workspace: str | None) -> Path:
    if workspace:
        return Path(workspace).expanduser().resolve()
    env = os.environ.get("DEEP_MEMORY_WORKSPACE")
    if env:
        return Path(env).expanduser().resolve()
    return Path.home() / ".deep-memory"


def main():
    parser = argparse.ArgumentParser(description="Write a cold-note entry.")
    parser.add_argument("--text", required=True, help="The takeaway text.")
    parser.add_argument("--tags", default="", help="Comma-separated tags.")
    parser.add_argument("--project", default="", help="Project name.")
    parser.add_argument("--workspace", default=None, help="Override workspace path.")
    args = parser.parse_args()

    ws = workspace_path(args.workspace)
    cold_dir = ws / "cold-notes"
    cold_dir.mkdir(parents=True, exist_ok=True)
    raw_file = cold_dir / "raw.jsonl"

    project = args.project or Path.cwd().name
    tags = [t.strip() for t in args.tags.split(",") if t.strip()]

    entry = {
        "project": project,
        "date": datetime.now(timezone.utc).strftime("%Y-%m-%d"),
        "tags": tags,
        "text": args.text.strip(),
    }

    with open(raw_file, "a", encoding="utf-8") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")

    print(f"[write-cold] appended to {raw_file}")
    print(json.dumps(entry, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
