#!/usr/bin/env python3
"""Pre-tool-use hook — guards against dangerous operations + enforces context compaction.

Called by the AI tool before executing any tool. Receives JSON on stdin:
  {"tool_name": "Bash", "tool_input": {"command": "rm -rf /"}, "session_id": "..."}

Exit codes:
  0 = allow the tool call
  2 = block the tool call (stderr shown to user)
  other non-zero = error (tool decides; usually allow)

Two gates:
  1. Context-oversized gate — if context_oversized flag is set, graduated response:
     - counter < 2: allow + stderr note (compact soon)
     - counter 2-3: allow + stderr warning (compact NOW)
     - counter >= 4: block non-compaction tools (force agent to compact)
     Compaction tools (read, grep, glob, write, edit, notebook_*, todo_write, skill)
     are always allowed so the agent can actually run context-compactor.

  2. Dangerous-command gate — blocks rm -rf, force-push, etc. (Bash/shell only)

This is a safety net, not a replacement for the canon's red lines. The agent
should already know not to do these things; this hook catches it if the agent
doesn't.
"""
import json
import re
import sys

import ahd_session

# --- Context-oversized gate config ---
OVERSIZED_NOTE_THRESHOLD = 0   # counter >= this -> note
OVERSIZED_WARN_THRESHOLD = 2   # counter >= this -> warning
OVERSIZED_BLOCK_THRESHOLD = 4  # counter >= this -> block non-compaction tools

# Tools that are always allowed even during compaction block (needed to actually compact)
COMPACTION_SAFE_TOOLS = frozenset({
    "read", "Read", "grep", "Grep", "glob", "Glob", "find_file_by_name",
    "write", "Write", "edit", "Edit",
    "notebook_read", "notebook_edit",
    "todo_write", "TodoWrite",
    "skill", "Skill",
})

# Patterns that are always blocked
DANGEROUS_PATTERNS = [
    # rm -rf with broad targets
    (r"\brm\s+(-[a-z]*r[a-z]*f|--recursive\s+--force)\s+(/|/\*|~|\$HOME|\.\.|\*|\.)", "rm -rf with broad target"),
    # git push --force / -f to main/master
    (r"\bgit\s+push\s+(--force|-f)\b.*\b(main|master)\b", "force-push to main/master"),
    # git reset --hard to remote
    (r"\bgit\s+reset\s+--hard\b.*\b(origin|upstream)\b", "hard reset to remote"),
    # curl/wget pipe to shell
    (r"\b(curl|wget)\b.*\|\s*(bash|sh|zsh)\b", "pipe-to-shell from URL"),
    # chmod -R 777
    (r"\bchmod\s+-R\s+777\b", "chmod 777 recursive"),
    # dd to disk device
    (r"\bdd\b.*\bof=/dev/(sd|nvme|hd)", "dd to disk device"),
    # mkfs
    (r"\bmkfs\b", "filesystem format"),
    # GitHub token / API key in command
    (r"\b(ghp_[A-Za-z0-9]{36}|sk-[A-Za-z0-9]{48}|AKIA[A-Z0-9]{16})\b", "secret in command"),
]

# Patterns that are warned but allowed (exit 0 with stderr note)
WARN_PATTERNS = [
    (r"\bgit\s+push\b(?!.*--force)", "git push (not force)"),
    (r"\bnpm\s+publish\b", "npm publish"),
    (r"\bpip\s+install\b", "pip install"),
]


def _check_context_oversized_gate(data: dict) -> None:
    """Gate 1: context-oversized graduated enforcement.

    Checks .agents/context_flags/<session_id>.json for context_oversized flag.
    If set, responds based on how many tool calls have passed without compaction:
      - counter < WARN_THRESHOLD: allow + stderr note
      - WARN_THRESHOLD <= counter < BLOCK_THRESHOLD: allow + stderr warning
      - counter >= BLOCK_THRESHOLD: block non-compaction tools (exit 2)

    Compaction-safe tools (read, grep, write, etc.) are always allowed so the
    agent can actually run the context-compactor skill.
    """
    try:
        session_id = ahd_session.get_session_id(data)
        root = ahd_session.get_repo_root()
        flags = ahd_session.read_context_flags(session_id, root)

        if not flags.get("context_oversized"):
            return  # no flag -> no gate

        counter = flags.get("oversized_tool_calls_since_flag", 0)
        tool_name = data.get("tool_name", "")

        # Always allow compaction-safe tools — agent needs them to compact
        if tool_name in COMPACTION_SAFE_TOOLS:
            if counter >= OVERSIZED_WARN_THRESHOLD:
                print(
                    f"[Agent Harness Deploy] context_oversized: {counter} tool calls "
                    f"without compaction. You are using a compaction-safe tool — good. "
                    f"Continue compacting, then clear the flag.",
                    file=sys.stderr,
                )
            return

        # Non-compaction tool — graduated response
        if counter >= OVERSIZED_BLOCK_THRESHOLD:
            # Block: force the agent to compact before doing more work
            print(
                f"[Agent Harness Deploy] BLOCKED: context_oversized for {counter}+ tool calls "
                f"without compaction. Run the context-compactor skill first: "
                f"(1) offload large outputs to .codex/tmp/, keep head+tail+path. "
                f"(2) lower caveman_level to compact or ultra. "
                f"(3) clear context_oversized flag in "
                f".agents/context_flags/{session_id}.json. "
                f"Then retry this tool call.",
                file=sys.stderr,
            )
            sys.exit(2)
        elif counter >= OVERSIZED_WARN_THRESHOLD:
            print(
                f"[Agent Harness Deploy] WARNING: context_oversized for {counter} tool calls. "
                f"Compact NOW — run context-compactor skill before the next non-essential tool call. "
                f"At {OVERSIZED_BLOCK_THRESHOLD}+ calls, non-compaction tools will be BLOCKED.",
                file=sys.stderr,
            )
        else:
            print(
                f"[Agent Harness Deploy] NOTE: context_oversized detected. "
                f"Run context-compactor skill soon to offload large outputs.",
                file=sys.stderr,
            )
    except SystemExit:
        raise
    except Exception:
        pass  # don't block on internal errors


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        # Can't parse input — allow (don't block on parse failure)
        sys.exit(0)

    # Gate 1: context-oversized enforcement (all tools)
    _check_context_oversized_gate(data)

    # Gate 2: dangerous-command check (Bash/shell only)
    tool_name = data.get("tool_name", "")
    tool_input = data.get("tool_input", {})

    if tool_name not in ("Bash", "bash", "Shell", "Execute", "exec", "terminal"):
        sys.exit(0)

    command = tool_input.get("command", "")
    if not command:
        sys.exit(0)

    # Check dangerous patterns
    for pattern, reason in DANGEROUS_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            print(f"[Agent Harness Deploy guard] BLOCKED: {reason}", file=sys.stderr)
            print(f"Command: {command[:200]}", file=sys.stderr)
            print(f"Pattern: {pattern}", file=sys.stderr)
            sys.exit(2)

    # Check warn patterns (allow but note)
    for pattern, reason in WARN_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            print(f"[Agent Harness Deploy guard] NOTE: {reason} — proceed carefully", file=sys.stderr)
            break

    sys.exit(0)


if __name__ == "__main__":
    main()
