---
name: context-compactor
description: "Use when context fill is >70%, a single tool output exceeds 20 lines / 3KB, or before reading a large file. Offloads the full payload to disk and keeps only head+tail+path in context."
---

# Skill: context-compactor

> Prevent context-dumb zone. Compress long outputs without losing the signal.

## Trigger
- `context_fill_pct > 70%` in `.hermes/session_state/<session_id>.json` or `.hermes/loop_state/<session_id>.md`.
- A single `read`/`exec`/`Bash` output is > 20 lines or > 3KB.
- Before reading any file known to be large (> 500 lines, build logs, lockfiles, traces).
- You are about to paste a full file, stack trace, or test log into the chat.

## When to run
At the start of every iteration if context is high, and immediately after a large tool output.

**Enforcement:** `pre_tool_use.py` will block non-compaction tool calls after 4+ un-compacted oversized detections. You **must** run this skill and clear the flag to unblock. Compaction-safe tools (read, grep, write, edit) remain available during the block — use them to compact.

## How

1. Read `.hermes/context_flags/<session_id>.json` if it exists. It contains `context_oversized` and any per-session signal.
2. For **read** calls:
   - Use `read` with `offset`/`limit` or `grep` to fetch only the relevant section.
   - If the full file is needed for later, use `grep` to extract relevant lines and write them to `.hermes/tmp/<file-name>.summary.md`.
3. For **exec/Bash** outputs:
   - Keep the first 10 and last 10 lines, plus the exact exit code and command.
   - Write the full output to `.hermes/tmp/<tool>-<ts>.log`.
   - In the context, replace the full output with:
     ```
     [context-compactor] <command> -> .hermes/tmp/<tool>-<ts>.log (head + tail below)
     <head 10 lines>
     ... <N lines offloaded to .hermes/tmp/<tool>-<ts>.log> ...
     <tail 10 lines>
     ```
4. Never compress the following verbatim:
   - exact code being changed
   - file paths
   - line numbers
   - error messages / exceptions
   - exact command outputs the next step depends on
5. Update `.hermes/loop_state/<session_id>.md` and `.hermes/session_state/<session_id>.json`:
   - `context_fill_pct` (estimate)
   - `caveman_level` (compact / ultra as needed)
6. After compacting, clear `.hermes/context_flags/<session_id>.json`:
   - Set `context_oversized: false`
   - Reset `oversized_tool_calls_since_flag: 0`
   This unblocks the `pre_tool_use.py` gate. Without clearing, non-compaction tools will remain blocked.

## Output
```
[context-compactor] offloaded <tool>/<file>
- summary: <one-line what it contained>
- full path: .hermes/tmp/<tool>-<ts>.log
- kept in context: <head+tail or key excerpt>
- caveman_level: <full|compact|ultra>
```

Caveman compact. No prose about the file. Keep paths and error strings exact.
