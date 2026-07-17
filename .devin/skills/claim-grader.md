---
name: claim-grader
description: "Use before finalizing any worker report. Grades every claim as [fact], [inference], or [unverified-guess] and attaches file:line or command evidence."
---

# Skill: claim-grader

> Evidence-graded claims. No more "I think this is used".

## Trigger
- Worker has produced an analysis and is about to return a report.
- Commander is reviewing a worker output before integration.
- Any conclusion is about to influence the next action.

## When to run
Last step before finalizing a report. Re-run if any claim's evidence is challenged.

## How

1. Scan the draft report line by line.
2. For each concrete claim, tag it:
   - `[fact]` — direct evidence from a file, line, or command output. Attach `file:line` or `command`.
   - `[inference: <basis>]` — logically derived from one or more facts, but not directly observed. State the basis.
   - `[unverified-guess]` — no direct evidence; a placeholder. If this appears, stop and gather evidence before continuing.
3. Code-related facts need `file:line` (e.g., `src/main.py:42`).
4. State/config facts need exact command or `cat` output.
5. "Seems", "looks like", "probably", "should" are signals that the claim is not a `[fact]`.
6. If `[unverified-guess]` count > 0, downgrade the report to "needs evidence" and dispatch the appropriate worker (Scout/Builder) to verify.
7. Output an `Evidence-graded` section:
   ```
   ## Evidence-graded
   - [fact] <claim> — evidence: <file:line|command>
   - [inference: <basis>] <claim> — basis: <...>
   - [unverified-guess] <claim> — action needed: <...>
   ```

## Output
Append the `Evidence-graded` section to the worker report. The Commander must see at least one `[fact]` for every major conclusion before trusting the output.

Caveman compact. One line per claim. No essays about evidence.
