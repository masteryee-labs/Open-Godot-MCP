---
name: systematic-debugging
description: "Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes. Enforces 4-phase root cause investigation: investigate, analyze, hypothesize, implement."
---

# Skill: systematic-debugging

> Iron law: no fixes without root cause investigation first.
> Extracted from obra/superpowers `systematic-debugging` skill.
> Agent Harness Deploy adaptation: integrates with maker≠checker (investigator≠fixer) and evidence-graded claims.

## Trigger

- Any bug, test failure, unexpected behavior, performance problem, build failure.
- Keywords: debug, root cause, why does this fail, fix bug, investigate.

**Use ESPECIALLY when:**
- Under time pressure (emergencies make guessing tempting)
- "Just one quick fix" seems obvious
- Previous fix didn't work
- You don't fully understand the issue

## The iron law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed Phase 1, you cannot propose fixes.

## The four phases

You MUST complete each phase before proceeding to the next.

### Phase 1: Root cause investigation

**BEFORE attempting ANY fix:**

1. **Read errors completely** — Stack traces, line numbers, error codes. They often contain the solution.
2. **Reproduce consistently** — Exact steps, every time? If not reproducible → gather more data, don't guess.
3. **Trace to source** — Check recent changes (git diff). Log component boundaries (what enters/exits). Trace bad values to origin. Fix at source, not symptom.

### Phase 2: Pattern analysis

**Find the pattern before fixing:**

1. **Find working examples** — Locate similar working code in same codebase.
2. **Compare completely** — Read reference implementation fully. List every difference, however small.
3. **Check dependencies** — What settings, config, environment does this need?

### Phase 3: Hypothesis and testing

**Scientific method:**

1. **Form single hypothesis** — "I think X is the root cause because Y". Be specific, write it down.
2. **Test minimally** — Smallest possible change, one variable at a time. No bundled fixes.
3. **Verify before continuing** — Worked → Phase 4. Didn't → NEW hypothesis (don't stack fixes). Don't know → say so, ask for help.

### Phase 4: Implementation

**Fix the root cause, not the symptom:**

1. **Create failing test** — Simplest reproduction. Use the `tdd` skill. MUST have before fixing.
2. **Implement single fix** — Address root cause. ONE change. No "while I'm here" improvements.
3. **Verify + escalate if needed** — Test passes? No regressions? If fix fails: <3 attempts → return to Phase 1. ≥3 failed fixes → STOP, question architecture (coupling, shared state, symptom-whack-a-mole). Discuss with human before more fixes.

## Red flags — STOP and follow process

If you catch yourself thinking:
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Add multiple changes, run tests"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- Proposing solutions before tracing data flow
- **"One more fix attempt" (when already tried 2+)**
- **Each fix reveals new problem in different place**

**ALL of these mean: STOP. Return to Phase 1.**

### Common rationalizations (same trap, different words)

- "Issue is simple" → Simple bugs have root causes too. Process is fast for simple bugs.
- "Emergency, no time" → Systematic debugging is FASTER than guess-and-check thrashing.
- "Just try this first" → First fix sets the pattern. Do it right from the start.
- "I'll write test after" → Untested fixes don't stick. Test first proves it.
- "Multiple fixes at once saves time" → Can't isolate what worked. Causes new bugs.
- "I see the problem, let me fix it" → Seeing symptoms ≠ understanding root cause.
- "One more fix attempt" (after 2+) → 3+ failures = architectural problem. Question pattern.

## Quick reference

| Phase | Key activities | Success criteria |
|-------|---------------|------------------|
| 1. Root cause | Read errors, reproduce, check changes, gather evidence | Understand WHAT and WHY |
| 2. Pattern | Find working examples, compare | Identify differences |
| 3. Hypothesis | Form theory, test minimally | Confirmed or new hypothesis |
| 4. Implementation | Create test, fix, verify | Bug resolved, tests pass |

## Real-world impact

Systematic approach: 15-30 min to fix, 95% first-time fix rate, near-zero new bugs. Random fixes: 2-3 hours thrashing, 40% first-time rate, common new bugs.

## Agent Harness Deploy integration

- **Maker≠checker**: The agent that investigates (Phase 1-3) should not be the same agent that fixes (Phase 4) for complex bugs. For simple bugs, same agent is OK but the test is the checker.
- **Evidence-graded claims**: Phase 1 findings tagged [fact] (from error output) / [inference] (from tracing) / [unverified-guess] (hypothesis before testing).
- **Plan-gate**: Phase 3 hypothesis must be stated before testing. No "I'll try X and see" without a written hypothesis.
- **Verification protocol**: Phase 4 fix verification = maker≠checker. The test runner verifies, not the fixer.

## When process reveals "no root cause"

If investigation shows the issue is truly environmental/timing/external: document what you investigated, implement appropriate handling (retry, timeout, error message), add monitoring. **But: 95% of "no root cause" cases are incomplete investigation.**

## Attribution

Extracted/adapted from [obra/superpowers](https://github.com/obra/superpowers) `systematic-debugging` skill (MIT). Integrates with maker≠checker, evidence-graded claims, plan-gate.
