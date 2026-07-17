---
name: memory-audit
description: "Use every 5 iterations, when scope changes, or before session end. Invokes .hermes/scripts/memory_audit.py to review candidate memories, prune stale ones, and distills reusable patterns into knowledge_distill.md."
---

# Skill: memory-audit

> Turn raw mistakes into reusable anti-patterns. Do not write `knowledge_distill.md` by hand; call the script.

## Trigger
- 5 iterations have passed.
- Scope has changed significantly (new files, new goal, new tool).
- Before writing the final `.hermes/handoff_letter.md`.
- `post_tool_use.py` has written candidate memory entries to the per-session file.

## When to run
At scope change, at iteration 5, and before the session ends.

## How

1. Call `python .hermes/scripts/memory_audit.py --session <session_id>`.
2. The script does the following:
   - Read `.hermes/session_state/<session_id>/candidate_memory.jsonl`.
   - For each candidate, check:
     - Does it have a clear trigger? (e.g., "file path with spaces in exec causes shell parse error")
     - Does it have a correct action? (e.g., "quote the path with double quotes")
     - Does it have a counter-example or a previous failure? (e.g., `exec command: rm /path with spaces`)
   - If all three exist, merge into `.hermes/knowledge_distill.md` in the format:
     ```
     - [memory] <trigger> -> <correct action> (counter: <...>)
     ```
   - If incomplete, either add the missing piece by reading the relevant journal or discard if it is too specific to a one-off event.
   - If `.hermes/knowledge_distill.md` exceeds 8KB, run a distillation pass:
     - merge duplicates
     - abstract concrete paths into patterns
     - archive evicted entries to `.hermes/loop_state_archive.md`
   - Clear the processed candidates from `.hermes/session_state/<session_id>/candidate_memory.jsonl`.
3. You may also read the audit output from the script and append any high-level judgment to `.hermes/handoff_letter.md`.

## Output
```
## Memory audit
- script: python .hermes/scripts/memory_audit.py --session <session_id>
- accepted: N
- discarded: N
- merged into knowledge_distill.md: N
- bytes in knowledge_distill.md: <N>/8192
- note: <any unresolved conflict>
```

Caveman compact. One line per memory.
