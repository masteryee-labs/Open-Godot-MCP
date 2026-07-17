---
name: auditor
description: "Use when 5 iterations have passed, or after a large output (>5 files or >200 lines changed), or before declaring a task complete. Seven-angle adversarial audit to catch self-persuasion blind spots."
---

# Skill: auditor

> Adversarial audit. Run every 5 iterations, after large outputs, and before declaring done.
> Eight-angle audit to catch self-persuasion, SLOP, and evidence blind spots.
> Run `claim-grader` and `slop-detector` before finalizing the audit output.

## Trigger
- Every 5 iterations (mandatory periodic breadth pass — 8 fixed angles).
- After a large output (>5 files or >200 lines changed).
- Before declaring a task complete — **but the done-gate itself is `fable-judge`** (event-driven,
  every done-declaration, focused on claims + frauds + verbatim gate lines per
  `.agents/canon/VERIFICATION_PROTOCOL.md §Verbatim execution gates`). Run fable-judge first;
  Auditor adds the 8-angle breadth sweep. See `.agents/skills/fable-judge.md`.
- Keywords: auditor, adversarial audit, AUDITOR MODE.

## The eight audit angles

1. **Self-persuasion** — did the agent talk itself into "done" without evidence?
2. **Scope creep** — did work exceed what was asked?
3. **Red-line breach** — any `canon/REDLINES.md` line violated?
4. **Evidence grade** — is every claim tagged `[fact]`, `[inference]`, or `[unverified-guess]`? Is `[unverified-guess]` followed by an action?
5. **Unverified claims** — claims stated as fact without file:line evidence?
6. **Fabricated detection** — any "synced"/"found" claim without a tool run?
7. **State drift** — `loop_state.md` not updated last iteration? Includes `context_fill_pct` and `caveman_level`.
8. **Honest-clause violation** — taste/aesthetic decision made without escalating?

## SLOP check

- **Names**: `data`, `info`, `manager`, `helper`, `utils`, `processor`, `handler`, `service` without domain context.
- **Abstractions**: single-call wrappers, interfaces with one implementation, premature base classes.
- **Prose**: filler phrases (`delve`, `leverage`, `seamless`, `robust`, `in the ever-evolving landscape`).
- **Commits**: `update`, `fix`, `improve` without area/why.

## How

For each angle: ask the adversarial question. If yes → P0/P1 finding with evidence.
If no → one-line "clean" note. No angle skipped.

## Output
```
## Audit [CLEAN/ISSUES] iteration:N
## Findings
| angle | severity | evidence | fix |
## Clean angles
- [angle]: clean — [why]
## Escalation needed [yes/no + reason]
```

## Rule
Auditor is fresh-context when possible. If same context, switch to Devil's Advocate mode
explicitly and state it. Same-context audit is weaker — note this in output.
