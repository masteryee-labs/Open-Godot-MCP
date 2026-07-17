#!/usr/bin/env python3
"""Post-tool-use hook — logs tool usage, detects context overload, and captures micro-memory.

Called by the AI tool after executing any tool. Receives JSON on stdin:
  {"tool_name": "Edit", "tool_input": {...}, "tool_response": {...}, "session_id": "..."}

Exit codes:
  0 = success (always — post-hooks never block)

Writes per-session:
- .agents/session_state/<session_id>.json — heartbeat, last_tool, last_file
- .agents/session_state/<session_id>/candidate_memory.jsonl — repeated failure patterns
- .agents/context_flags/<session_id>.json — context_oversized flag
- .agents/session_state/<session_id>/journal.jsonl — audit trail

This creates a persistent audit trail and helps the harness avoid the context dumb zone.
"""
from __future__ import annotations

import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

import ahd_session

CONTEXT_OVERSIZE_THRESHOLD = 3000  # characters in response
CANDIDATE_MEMORY_MAX = 50

# Simple secret redaction patterns
_SECRET_PATTERNS = [
    re.compile(r"ghp_[a-zA-Z0-9]{36}", re.IGNORECASE),
    re.compile(r"sk-[a-zA-Z0-9_-]{20,}", re.IGNORECASE),
    re.compile(r"\b(token|key|password|api_key|secret)\s*=\s*[^\s&;|]+", re.IGNORECASE),
]


def _redact(text: str) -> str:
    """Mask common secret patterns in command strings."""
    if not isinstance(text, str):
        return text
    for pat in _SECRET_PATTERNS:
        text = pat.sub(lambda m: m.group(0)[:m.group(0).find("=") + 1] + "***" if "=" in m.group(0) else "***", text)
    return text


def _response_size(response) -> int:
    """Estimate the size of a tool response in characters."""
    if isinstance(response, dict):
        return len(str(response.get("content", response)))
    elif isinstance(response, str):
        return len(response)
    return 0


def _extract_file_path(tool_input: dict) -> str:
    """Try to extract a file path from common tool arguments."""
    for key in ("file_path", "path", "notebook_path", "file"):
        if key in tool_input:
            return tool_input[key]
    return ""


def _extract_command(tool_input: dict) -> str:
    """Extract a command (truncated + redacted) for Bash-like tools."""
    cmd = tool_input.get("command", "")
    if not cmd:
        return ""
    redacted = _redact(cmd[:200])
    return redacted


def _repeated_failure_count(journal_path: Path, tool_name: str, command: str, session_id: str) -> int:
    """Count how many times this tool/command has failed in the session journal."""
    count = 0
    if not journal_path.exists():
        return 0
    try:
        for line in journal_path.read_text(encoding="utf-8").splitlines():
            if not line:
                continue
            try:
                entry = json.loads(line)
            except Exception:
                continue
            if entry.get("session_id") != session_id:
                continue
            if entry.get("tool") != tool_name:
                continue
            if entry.get("ok"):
                continue
            entry_cmd = entry.get("command", "")
            if command and entry_cmd != command:
                continue
            count += 1
    except Exception:
        pass
    return count


def _extract_candidate_memory(tool_name: str, tool_input: dict, tool_response, ts: str, ok: bool = True) -> dict | None:
    """Detect repeated failure patterns and turn them into candidate memory."""
    try:
        # Check if the tool failed
        if ok:
            return None

        # Heuristic: shell command errors with a clear pattern
        if tool_name in ("Bash", "bash", "Shell", "Execute", "exec"):
            cmd = tool_input.get("command", "")
            resp_text = ""
            if isinstance(tool_response, dict):
                resp_text = str(tool_response.get("content", ""))
            elif isinstance(tool_response, str):
                resp_text = tool_response

            lower = resp_text.lower()
            if "permission denied" in lower:
                return {
                    "trigger": "shell command fails with 'Permission denied'",
                    "correct_action": "check file permissions or use a command that does not require elevation",
                    "counter": _redact(cmd[:200]),
                    "ts": ts,
                }
            if "not found" in lower or "no such file" in lower:
                return {
                    "trigger": "shell command fails with 'not found' or 'no such file'",
                    "correct_action": "verify the path exists before running the command",
                    "counter": _redact(cmd[:200]),
                    "ts": ts,
                }
            if "invalid" in lower or "unrecognized" in lower:
                return {
                    "trigger": "shell command fails with invalid argument/parameter",
                    "correct_action": "recheck the command syntax and flags",
                    "counter": _redact(cmd[:200]),
                    "ts": ts,
                }
        return None
    except Exception:
        return None


def _append_bounded_jsonl(path: Path, record: dict, max_records: int = CANDIDATE_MEMORY_MAX) -> None:
    """Append a record to a jsonl file, keeping the file bounded."""
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        if path.exists():
            lines = path.read_text(encoding="utf-8").splitlines()
            if len(lines) >= max_records:
                lines = lines[-(max_records - 1):]
                path.write_text("\n".join(lines) + "\n" if lines else "", encoding="utf-8")
        with open(path, "a", encoding="utf-8") as f:
            f.write(json.dumps(record, ensure_ascii=False) + "\n")
    except Exception:
        pass


def _rotate(path: Path, max_lines: int = 1000) -> None:
    """Rotate a jsonl file if it exceeds max_lines."""
    try:
        if path.exists() and path.read_text(encoding="utf-8").count("\n") >= max_lines:
            backup = path.with_suffix(".1.jsonl")
            if backup.exists():
                backup.unlink()
            path.rename(backup)
    except Exception:
        pass


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    tool_name = data.get("tool_name", "")
    tool_input = data.get("tool_input", {})
    tool_response = data.get("tool_response", {})

    session_id = ahd_session.get_session_id(data)
    root = ahd_session.get_repo_root()

    ts = ahd_session.now_utc()
    file_path = _extract_file_path(tool_input)
    command = _extract_command(tool_input) if tool_name in ("Bash", "bash", "Shell", "Execute", "exec") else ""

    # Determine success
    ok = True
    failure_markers = [
        "permission denied", "no such file or directory", "not found", "unrecognized",
        "invalid", "command not found", "exit code", "fatal", "failed",
    ]
    if isinstance(tool_response, dict):
        if "error" in tool_response and tool_response["error"]:
            ok = False
        elif "ok" in tool_response and not tool_response["ok"]:
            ok = False
        elif tool_response.get("exit_code", 0) not in (0, None, ""):
            ok = False
        elif tool_response.get("status", "").lower() not in ("", "success", "ok"):
            ok = False
        else:
            content = str(tool_response.get("content", "")).lower()
            if "error" in content or any(p in content for p in failure_markers):
                ok = False
    elif isinstance(tool_response, str):
        content = tool_response.lower()
        if "error" in content or any(p in content for p in failure_markers):
            ok = False

    # Read current session state to preserve current_subtask and goal for the journal
    try:
        current_state = ahd_session.read_session_state(session_id, root)
    except Exception:
        current_state = {}

    # Update session_state heartbeat (merge, don't overwrite current_subtask)
    update = {
        "session_id": session_id,
        "status": "in_progress",
        "last_heartbeat": ts,
        "last_tool": tool_name,
    }
    if file_path:
        update["last_file"] = file_path
    update["last_error"] = not ok
    # Only set status if not already present (avoid overwriting completed)
    if current_state.get("status"):
        update.pop("status")
    ahd_session.update_session_state(session_id, update, root)

    # Write per-session journal
    journal_path = ahd_session.get_config_root(root) / "session_state" / session_id / "journal.jsonl"
    try:
        _rotate(journal_path)
        journal_entry = {
            "ts": ts,
            "tool": tool_name,
            "session_id": session_id,
            "ok": ok,
        }
        if file_path:
            journal_entry["file"] = file_path
        if command:
            journal_entry["command"] = command
        current_subtask = current_state.get("current_subtask", "")
        if current_subtask:
            journal_entry["current_subtask"] = current_subtask
        ahd_session.append_jsonl(journal_path, journal_entry)
    except Exception:
        pass

    # Detect oversized context and enforce compaction
    try:
        oversized = _response_size(tool_response) > CONTEXT_OVERSIZE_THRESHOLD
        if oversized:
            flags = ahd_session.read_context_flags(session_id, root)
            counter = flags.get("oversized_tool_calls_since_flag", 0)
            ahd_session.write_context_flags(session_id, {
                "context_oversized": True,
                "oversized_tool_calls_since_flag": counter,
                "oversized_first_detected": ts,
            }, root)
            # Print directive to stderr — most tools feed hook stderr back to the agent.
            print(
                f"[Agent Harness Deploy] context_oversized detected "
                f"(response > {CONTEXT_OVERSIZE_THRESHOLD} chars). "
                f"Run context-compactor skill before continuing: "
                f"offload full output to .agents/tmp/, keep head+tail+path in context. "
                f"Read .agents/context_flags/{session_id}.json for details.",
                file=sys.stderr,
            )
        elif ahd_session.read_context_flags(session_id, root).get("context_oversized"):
            # Flag still set from a prior call — agent hasn't compacted yet. Increment counter.
            flags = ahd_session.read_context_flags(session_id, root)
            counter = flags.get("oversized_tool_calls_since_flag", 0) + 1
            ahd_session.write_context_flags(session_id, {
                "oversized_tool_calls_since_flag": counter,
            }, root)
    except Exception:
        pass

    # Detect candidate memory (only record after the same command fails 2+ times)
    try:
        candidate = _extract_candidate_memory(tool_name, tool_input, tool_response, ts, ok=ok)
        if candidate:
            # The current failure has already been appended to the journal
            fail_count = _repeated_failure_count(journal_path, tool_name, command, session_id)
            if fail_count >= 2:
                candidate["session_id"] = session_id
                candidate_path = ahd_session.get_config_root(root) / "session_state" / session_id / "candidate_memory.jsonl"
                _append_bounded_jsonl(candidate_path, candidate)
    except Exception:
        pass

    sys.exit(0)


if __name__ == "__main__":
    main()