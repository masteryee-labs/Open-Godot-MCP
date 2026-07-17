# Judgment Rubrics — Externalized Decision Criteria

> Source: Agent Harness Deploy internal. Each criterion has positive/negative examples. Model matches, doesn't judge.

## Why externalize

Models grade their own work inconsistently. Externalization: write criteria + examples before the decision. Model's job = *matching* (positive or negative example?) not *judging* (good or bad?). Matching > judging. Same principle as Maker ≠ Checker, applied to subjective calls.

## Rubric format

```
## [criterion]
Question: [yes/no or multi-choice]
Positive example: [what "yes" looks like — concrete]
Negative example: [what "no" looks like — concrete]
Action on match: [what to do]
```

Can't write positive/negative examples? Criterion too vague → escalate to human.

## Core rubrics

### R1: Is the task done?

| | Example |
|---|---------|
| **Question** | Are all acceptance criteria met with file:line evidence? |
| **Positive** | "ST-3 done — src/sync.py:42 backup added, verify.py:18 marker passes, test_sync_backup.py PASS" |
| **Negative** | "ST-3 looks complete. The backup should work now." |
| **Action +** | Mark done, dispatch Verifier for cold confirmation |
| **Action −** | NOT done. Specify what's missing with file:line. |

### R2: Should I escalate to human?

| | Example |
|---|---------|
| **Question** | Is this a taste/aesthetic/ambiguous-judgment call? |
| **Positive** | "User asked for 'clean' UI — no spec, 3 valid designs, no way to rank without user input." |
| **Negative** | "User asked for backup-before-overwrite — spec clear, criteria deterministic." |
| **Action +** | STOP. Present options to human. Don't pick. |
| **Action −** | Proceed with implementation. |

### R3: Should I upgrade the model?

| | Example |
|---|---------|
| **Question** | Has the current model tier failed on this subtask? |
| **Positive** | "Sonnet attempted type-checker fix twice, both introduced new type error elsewhere." |
| **Negative** | "Sonnet's first attempt had syntax error, fixed on retry." |
| **Action +** | Upgrade to Opus (or cross-family). Log failure mode. |
| **Action −** | Retry once more at current tier. |

### R4: Is this a destructive operation?

| | Example |
|---|---------|
| **Question** | Does this modify state in a way that can't be undone via .bak or git? |
| **Positive** | "About to run `rm -rf .codex/` — no .bak, no git tracking." |
| **Negative** | "About to overwrite CLAUDE.md — .bak will be created first." |
| **Action +** | STOP. Ask human. No exceptions. |
| **Action −** | Proceed (backup first per Red Line #1). |

### R5: Is verification stale?

| | Example |
|---|---------|
| **Question** | Was the file modified after the last verification? |
| **Positive** | "Verifier said PASS at 14:32. Builder edited at 14:35." |
| **Negative** | "Verifier said PASS at 14:32. No edits since." |
| **Action +** | Re-verify. Old verdict invalid (SHA discipline). |
| **Action −** | Trust existing verdict. |

### R6: Is this scope creep?

| | Example |
|---|---------|
| **Question** | Does the work exceed what the GoalSpec defines? |
| **Positive** | "GoalSpec says 'fix backup bug'. Agent also refactoring sync.py error handling 'because it looked messy'." |
| **Negative** | "GoalSpec says 'fix backup bug'. Agent fixes bug + updates related failing test." |
| **Action +** | STOP extra work. Log as candidate subtask. Ask Commander. |
| **Action −** | Proceed. |

### R7: Should this session continue a previous session?

| | Example |
|---|---------|
| **Question** | Is there an active, crashed, or suspected-crashed session whose `owned_files`/`affected_files`/`tags` overlap the new task? |
| **Positive** | "Session `s-20260709-abc` is `suspected_crashed` on `current_subtask: add file lock to base.py`. New task is `fix sync.py concurrency` and `owned_files` lists `scripts/sync.py` and `adapters/base.py`." |
| **Negative** | "No active sessions, or active session `s-xyz` owns `Docs/Agents/nuwa.md` while new task is `scripts/distill.py` with no file/tag overlap." |
| **Action +** | STOP. Read `.agents/loop_state/<session_id>.md` and `.agents/session_state/<session_id>.json`. Ask the human: "Session `s-xxx` was interrupted at `<current_subtask>`. Continue it, or start new?" |
| **Action −** | Start a new session with a fresh `session_id`; keep the old session in `active_sessions` unless it is completed. |

## How to use

1. **At decision points**: Commander checks relevant rubric before acting.
2. **In Auditor reviews**: Auditor checks each rubric against session's decisions.
3. **When stuck**: if model can't decide, rubric is missing or vague. Write it, then decision = matching.

## When to add a new rubric

- Same subjective call recurs 3+ times → externalize.
- Decision keeps getting made inconsistently → externalize.
- Human corrects same judgment error repeatedly → externalize.

## When NOT to externalize

- One-off decisions (cost > savings).
- Deterministic answers (use CLI check, not rubric).
- Domain expertise rubric can't capture (escalate to human).

## Relationship to other canon

| Canon file | Relationship |
|------------|-------------|
| REDLINES.md | Red lines = non-negotiable; rubrics = gray area above red lines. R4 overlaps Red Line #1 but covers "is this destructive enough to ask?" |
| VERIFICATION_PROTOCOL.md | R1, R5 = judgment layer on verification machinery. Verification provides evidence; rubrics decide what to do. |
| BOOT_PROTOCOL.md | GoalSpec's acceptance criteria feed R1. Without GoalSpec, R1 has nothing to check. |
| auditor skill | Seven audit angles = domain-specific rubrics. This file = general pattern. |

---

## Workspace rubrics (extended)

> The core R1-R6 are summary rubrics. The workspace rubrics below are granular extensions
> for specific decision categories: Direction-Lost Signals (R-DL), Task Completion (R-TC),
> and Human Escalation Circuit Breakers (R-HE). Each has concrete positive/negative examples.

### Category 1: Direction-Lost Signals (R-DL)

Detect when a Worker has lost track of its dispatched task.

| ID | Question | Positive | Negative | Action |
|----|----------|----------|----------|--------|
| R-DL1 | Does current action match the dispatched Goal? | Grepping for `detect_all` as dispatched | Refactoring `detect_all`'s signature "because it looked improvable" | −: STOP, log drift, return to Goal, report to Commander |
| R-DL2 | Re-reading a file without reason? | Re-read config.json after Builder modified it | Re-read config.json "to make sure" — unchanged | −: Use cached content. Check git status if unsure. |
| R-DL3 | Every claim has file:line or command evidence? | "Bug in sync.py:42 — grep shows hardcoded path" | "Bug seems somewhere in sync module" | −: Reject report. Re-report with evidence. |
| R-DL4 | Same action 3+ times, same result? | `npm test` → fix → `npm test` (different result) | `npm test` 3× same failures, no changes between | −: STOP. Escalate. Max 2 retries. |
| R-DL5 | Reading files outside dispatched scope? | Reads sync.py + imports (detect.py, registry.json) | Reads 15 files "to understand architecture" | −: STOP. Request scope expansion from Commander. |

### Category 2: Task Completion Criteria (R-TC)

Determine whether a task is actually done — not just "looks done."

| ID | Question | Positive | Negative | Action |
|----|----------|----------|----------|--------|
| R-TC1 | Every AC met with evidence? | "AC-1: sync.py:42 backup added (read-back). AC-2: verify.py PASS" | "Looks complete. Should work now. Pretty confident." | −: NOT done. Specify unmet ACs + missing evidence. |
| R-TC2 | Verified by fresh context? | Verifier (fresh) read back + ran pytest. PASS. | Builder: "I checked my changes, they look correct." | −: NOT verified. Dispatch fresh-context Verifier. Red line. |
| R-TC3 | Full test suite run (regression check)? | Changed sync.py → ran `pytest tests/` (full). All pass. | Changed sync.py → ran only `test_sync.py`. | −: Run full suite. Any fail = NOT done (regression). |
| R-TC4 | loop_state.md updated before declaring done? | Last action: write loop_state.md "ST-3 done, next: ST-4" | Declares done but state shows "ST-3 in progress" | −: Write state first. Done without state = red line. |
| R-TC5 | Nuwa run for L/XL tasks? | Ran Edge Case + Dependency + Regression trees. All clean. | "I'm confident it's correct." No Nuwa. | −: Run Nuwa before declaring done. See `Docs/Agents/nuwa.md`. |

### Category 3: Human Escalation Circuit Breakers (R-HE)

When the agent MUST stop and escalate. These trip automatically.

| ID | Question | Positive | Negative | Action |
|----|----------|----------|----------|--------|
| R-HE1 | Taste/aesthetic/ambiguous judgment? | "Clean UI" — no spec, 3 valid designs | Backup feature — spec clear, criteria deterministic | +: STOP. Present options to human. Don't pick. |
| R-HE2 | Destructive without undo? | `rm -rf .codex/` — no .bak, no git | Overwrite CLAUDE.md — .bak created first | +: STOP. Ask human. No exceptions. |
| R-HE3 | Max retries exceeded? | 2 retries, same error persists | 1 retry, syntax error fixed | +: STOP. Escalate with full failure trace. |
| R-HE4 | Outside deploy contract? | "幫我部屬" + "also refactor my codebase" | "幫我部屬" and nothing else | +: Acknowledge deploy, flag out-of-contract request. |
| R-HE5 | About to modify canon? | Wants to "improve" CAVEMAN_PROTOCOL.md | Editing generated entry file via deployer | +: STOP. Canon modification = human approval (Red Line #12). |
| R-HE6 | Verification stale (SHA mismatch)? | PASS at abc123, current HEAD = def456 | PASS at abc123, HEAD still abc123 | +: Re-verify. Old verdict invalid. |

### Mapping: core R1-R6 → workspace rubrics

| Core | Workspace extension | Notes |
|------|---------------------|-------|
| R1 (done?) | R-TC1, R-TC2, R-TC3, R-TC4, R-TC5 | R-TC breaks "done" into 5 checkable sub-criteria |
| R2 (escalate?) | R-HE1, R-HE4, R-HE5 | R-HE breaks "escalate" into specific trigger types |
| R3 (upgrade model?) | R-HE3 | R-HE3 is the retry-exhausted escalation |
| R4 (destructive?) | R-HE2 | Same concept, workspace-specific examples |
| R5 (stale verify?) | R-HE6, R-TC2 | SHA discipline + fresh-context check |
| R6 (scope creep?) | R-DL1, R-DL5 | R-DL breaks "scope creep" into action-matching + file-scope |
