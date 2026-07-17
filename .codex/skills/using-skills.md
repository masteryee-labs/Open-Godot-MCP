---
name: using-skills
description: "Use before responding to any user request. Enforces skill-first methodology: check if a skill matches the request, invoke it before acting. Prevents ad-hoc work that bypasses the harness."
---

# Skill: using-skills — Meta-Skill

> This is a **meta-skill**. Its job is to enforce that other skills get used.
> Inspired by obra/superpowers `using-superpowers` pattern.

## The rule

**Before responding to any user request, check: does a skill match?**

1. Scan the skill list (descriptions start with "Use when...").
2. If a skill's "Use when..." condition matches the current situation → invoke it first.
3. If no skill matches → proceed without a skill (not everything needs one).
4. If multiple skills match → invoke all of them (parallel if possible).

## Why

Skills encode hard-won lessons. When an agent skips a skill and improvises, it re-derives
the lesson from scratch — usually worse. The skill exists because:
- Someone hit this situation before.
- They distilled the correct response.
- They wrote it down so it wouldn't have to be re-derived.

Skipping skills = paying the lesson's cost again every time.

## The skill list (scan this)

| Skill | Use when... |
|-------|-------------|
| `gap-scan` | BOOT complete, GoalSpec written, before first work action |
| `harness-sensor` | Code or files have been modified |
| `auditor` | 5 iterations passed, or large output, or before declaring done |
| `loop-memory` | BOOTing a session, or end of an iteration |
| `chroma-hybrid-search` | High-accuracy code/solution retrieval needed, hallucination must be minimized |
| `init_deep` | Repository is too large to explain from memory, or codebase shape has changed |
| `comment_checker` | After code edits that touch comments, or before declaring a code task complete |
| `slop-detector` | After generating user-facing prose, docs, naming, or abstractions |
| `claim-grader` | Before finalizing any worker report or analysis |
| `graph-verify` | Answering structural questions (who calls X, who imports Y, blast radius) |
| `context-compactor` | Context fill >70%, large tool output, or before reading large files |
| `memory-audit` | Every 5 iterations, scope change, or before session end |
| `user-preference` | At BOOT, or whenever a user preference is discovered |
| `tdd` | Implementing any feature or bugfix, before writing implementation code |
| `systematic-debugging` | Encountering any bug, test failure, or unexpected behavior, before proposing fixes |
| `using-skills` | (this skill) Before responding to any request |

## Process vs Implementation skills

| Type | What it does | Examples |
|------|-------------|----------|
| **Process** | Sets the *approach* — how to think about the task | gap-scan, auditor, using-skills, comment_checker, slop-detector, claim-grader, tdd, systematic-debugging |
| **Implementation** | Does the *work* — executes a specific capability | harness-sensor, loop-memory, chroma-hybrid-search, init_deep, context-compactor, graph-verify, memory-audit, user-preference |

Process skills run first. They shape the approach. Implementation skills run when their
trigger condition is met during execution.

## When to NOT invoke a skill

- The request is conversational/informational (no work to do).
- The request is trivial (single command, <5 lines, no verification chain).
- A skill's "Use when..." condition clearly doesn't match.

Don't force-fit a skill to a request that doesn't need it. Skills are tools, not rituals.

## Personal skill shadowing

Users can add personal skills by dropping `.md` files into `.codex/skills/` with the same
frontmatter format. Personal skills **shadow** (override) built-in skills by name. This
lets users customize behavior without forking the canon.

## Output

This meta-skill doesn't produce a report. It produces a *decision*: which skill(s) to
invoke, or "no skill needed." The decision is visible in the next action.
