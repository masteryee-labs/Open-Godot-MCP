---
name: comment_checker
description: "Use after any code edit that touches comments, or before declaring a code task complete. Detects AI-slop comments — filler, over-explanation, restating the obvious, hedge words — and flags them for removal. Code should read like a senior engineer wrote it."
---

# Skill: comment_checker

> No AI slop in comments. Code reads like a senior wrote it.
> Concept extracted from oh-my-openagent's `comment-checker` skill (Sisyphus Labs),
> reimplemented as a prompt-level skill for the Agent Harness Deploy harness. No OmO runtime dependency.

## Trigger
- After any code edit that adds or modifies comments.
- Before declaring a code task complete (run alongside `auditor`).
- When reviewing a file that looks AI-generated.
- Keywords: comment_checker, comment-checker, AI slop, comment quality, code review.

## Why

AI-generated code comes with comments that scream "a machine wrote this": restating the obvious, over-explaining stdlib, hedge words, filler transitions, apologetic notes. Senior engineers comment only when the *why* is non-obvious — the *what* is already in the code. Slop comments waste tokens, distract reviewers, and signal "AI was here."

## The 6 slop patterns

| # | Pattern | Example | Fix |
|---|---------|---------|-----|
| 1 | **Restating the code** | `# set x to 5` → `x = 5` | Delete |
| 2 | **Over-explaining stdlib** | `# len() returns length` | Delete — assumed knowledge |
| 3 | **Hedge / uncertainty** | `# maybe handles edge case` | Confirm definitively or delete |
| 4 | **Filler transition** | `# Now process results` | Delete — structure is self-explanatory |
| 5 | **Apologetic / self-deprecating** | `# hacky but works` | Fix code, or add TODO with owner + ticket |
| 6 | **AI signature phrases** | "Let's", "I'll", "We can see" | Delete or rewrite in imperative |

## How

### Step 1: Identify all comments in the edited file(s)

Use `grep` for comment markers per language:
- Python: `#` lines
- JS/TS: `//` lines and `/* */` blocks
- Rust: `//` lines
- etc.

### Step 2: Classify each comment

| Class | Action |
|-------|--------|
| **Slop** (any of 6 patterns) | Flag for deletion |
| **Obvious restatement** | Flag for deletion |
| **Useful — non-obvious why** | Keep |
| **Useful — gotcha/trap** | Keep |
| **Useful — public API docstring** | Keep (check for slop inside) |
| **TODO/FIXME with owner + reason** | Keep |
| **TODO/FIXME without owner** | Flag — add owner or delete |

### Step 3: Report

```
## comment_checker report
## File: [path]
## Slop found
| line | pattern | comment | fix |
| 42 | restating code | `# set x to 5` | delete |
| 87 | hedge | `# maybe handles edge case` | confirm or delete |
## Clean
- [N] comments reviewed, [M] kept, [K] flagged
## Verdict [CLEAN / SLOP_FOUND]
```

### Step 4: Fix (if SLOP_FOUND)

Delete flagged comments. Do NOT replace them with "better" comments — the default action
is **deletion**, not rewriting. A missing comment is better than a slop comment. Only
rewrite if the comment was pointing at a real non-obvious *why* that the code alone
doesn't convey.

## Rules

- **Default action is deletion, not rewriting.** Most slop comments should simply be
  removed. The code is the documentation; comments explain *why*, not *what*.
- **Never add comments that restate the code.** If `x = 5` needs a comment, the variable
  name is wrong, not the comment count.
- **Docstrings on public APIs are exempt** — but check for slop *inside* the docstring.
  A docstring that says "This function returns the result of processing the input" is slop.
- **TODOs must have an owner.** `# TODO: fix this` → delete or change to
  `# TODO(@user): fix this because [reason], tracked in [issue]`.
- **Caveman mode applies to comments too.** If a comment survives review, it should be
  terse: one line, no filler, no hedging.

## Relationship to slop-detector

`comment_checker` focuses on **comments**. For broader AI Slop (naming, abstractions, user-facing prose, commit messages), use `slop-detector` after `comment_checker`.

## Relationship to Agent Harness Deploy caveman protocol

The caveman protocol (`.windsurf/canon/CAVEMAN_PROTOCOL.md`) compresses agent *output* (chat, reports). `comment_checker` extends that philosophy into *code comments* — the persistent text in the repo. Together: caveman protocol compresses every response; `comment_checker` compresses comments after code edits.

## Attribution

Concept extracted from oh-my-openagent's `comment-checker` (Sisyphus Labs, SUL-1.0). Reimplemented as a prompt-level skill — no OmO runtime code used or vendored. The concept (detect and remove AI-slop comments) is a code-quality pattern, not copyrightable expression.
