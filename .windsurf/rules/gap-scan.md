---
name: gap-scan
description: "Use when BOOT is complete and GoalSpec is written, before starting the first work action. Scans 1-2 scope angles for blind spots the GoalSpec doesn't cover."
---

# Skill: gap-scan

> Differential blind-spot scan. Run after BOOT, before starting work.
> Scans 1-2 scope angles only (not all six). Keeps context clean.

## Trigger
- BOOT complete, GoalSpec written.
- Keywords: scan blind spots, gap analysis, differential scan, BOOT.

## When to run
After BOOT, before the first work action. Re-run when scope changes significantly.

## How

1. Read GoalSpec from `loop_state.md`. Identify `scope.angles_required` (1-3 angles).
2. For each required angle, ask: "what would make this angle fail that the GoalSpec
   doesn't already cover?"
3. List gaps as: `[angle] — [potential blind spot] — [check to resolve it]`.
4. Resolve cheap gaps immediately (one read/grep). Expensive gaps → add as subtasks.
5. Write findings to `loop_state.md` under `gap_scan_results`.

## The six angles (pick from these)

| Angle | Question |
|-------|----------|
| Completeness | What's missing that the user expects but didn't say? |
| Correctness | What assumption is unverified? |
| Consistency | What conflicts with existing rules/files? |
| Cost | What will burn tokens/time unexpectedly? |
| Safety | What destructive side effect could happen? |
| Reversibility | What can't be undone if we're wrong? |

## Output
```
## Gap scan [angle]
- [gap] — [check] — [resolved/subtask/deferred]
## New subtasks added
- ST-N: ...
```

Caveman full. Don't write essays about gaps. One line each.
