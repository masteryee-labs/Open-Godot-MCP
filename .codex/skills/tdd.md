---
name: tdd
description: "Use when implementing any feature or bugfix, before writing implementation code. Enforces RED-GREEN-REFACTOR: write failing test first, watch it fail, write minimal code to pass, refactor."
---

# Skill: tdd — Test-Driven Development

> Iron law: no production code without a failing test first.
> Extracted from obra/superpowers `test-driven-development` skill.
> Agent Harness Deploy adaptation: integrates with maker≠checker (test = checker, code = maker).

## Trigger

- Implementing a feature or bugfix.
- Keywords: TDD, test-first, red-green, write test, implement feature.

## The iron law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Wrote code before the test? Delete it. Start over. No "keep as reference", no "adapt it while writing tests". Delete means delete.

## When to use

**Always:**
- New features
- Bug fixes
- Refactoring
- Behavior changes

**Exceptions (ask human partner):**
- Throwaway prototypes
- Generated code
- Configuration files

Thinking "skip TDD just this once"? Stop. That's rationalization.

## RED-GREEN-REFACTOR cycle

### 1. RED — Write failing test

One minimal test showing what should happen. One behavior per test. Clear name (describes behavior). Real code, no mocks unless unavoidable.

### 2. Verify RED — Watch it fail (MANDATORY, never skip)

Run test. Confirm: test **fails** (not errors), failure message is expected, fails because feature missing (not typos). Passes immediately? Testing existing behavior — fix test. Errors? Fix error, re-run until it fails correctly.

### 3. GREEN — Minimal code

Simplest code to pass the test. No extra features, no refactoring, no "improvements" beyond the test. Run test: passes? Other tests still pass? Output pristine? Test fails → fix code, not test. Other tests fail → fix now.

### 4. REFACTOR — Clean up (after green only)

Remove duplication, improve names, extract helpers. Keep tests green. Don't add behavior. Then: next failing test for next feature.

## Good tests

- **Minimal**: One thing per test. "and" in name? Split it.
- **Clear**: Name describes behavior, not "test1".
- **Shows intent**: Demonstrates desired API, not obscures what code should do.

## Why order matters

- **"I'll write tests after"** → Tests pass immediately, proving nothing. Might test wrong thing, test implementation not behavior, miss edge cases, never saw it catch the bug. Test-first forces you to see it fail.
- **"Deleting X hours of work is wasteful"** → Sunk cost fallacy. Keeping unverified code is technical debt.

## Red flags — STOP and start over

- Code before test
- Test after implementation
- Test passes immediately
- Can't explain why test failed
- Rationalizing "just this once"
- "Keep as reference" or "adapt existing code"

**All of these mean: delete code. Start over with TDD.**

### Common rationalizations (same trap, different words)

- "Too simple to test" → Simple code breaks. Test takes 30 seconds.
- "I'll test after" → Tests passing immediately prove nothing.
- "Already manually tested" → Ad-hoc ≠ systematic. No record, can't re-run.
- "Deleting is wasteful" → Sunk cost. Keeping unverified code = debt.
- "Keep as reference" → You'll adapt it. That's testing after. Delete means delete.
- "Need to explore first" → Fine. Throw away exploration, start with TDD.
- "TDD will slow me down" → TDD faster than debugging production.

## Bug fix workflow

1. **RED**: Write failing test reproducing the bug.
2. **Verify RED**: Watch it fail (confirms test catches the bug).
3. **GREEN**: Write minimal fix.
4. **Verify GREEN**: Watch it pass.
5. **REFACTOR**: Clean up if needed.

Never fix bugs without a test. The test proves the fix and prevents regression.

## Agent Harness Deploy integration

- **Maker≠checker**: Test = checker, implementation = maker. The agent that writes code does not judge if tests pass — the test runner does.
- **Verification protocol**: TDD's "watch it fail / watch it pass" is the verification protocol applied at the unit level.
- **Loop protocol**: RED→GREEN→REFACTOR is a `/goal` loop with exit condition "test passes".

## Attribution

Extracted/adapted from [obra/superpowers](https://github.com/obra/superpowers) `test-driven-development` skill (MIT). Integrates with maker≠checker and verification protocol.
