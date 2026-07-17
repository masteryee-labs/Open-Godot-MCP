---
name: slop-detector
description: "Use after generating user-facing prose, docs, commit messages, naming, or code. Detects AI-generated filler, generic abstractions, and meaningless identifiers."
---

# Skill: slop-detector

> Detect AI Slop before it ships.

## Trigger
- After writing user-facing prose, README, PR description, commit message, or inline documentation.
- After naming a class, function, variable, or module.
- After creating an abstraction (interface, base class, wrapper).
- Final report before user-facing output.

## When to run
Before declaring a task done or before a user-facing response.

## How

1. **Prose check.**
   Flag and rewrite any of these AI Slop phrases:
   - `delve into`, `leverage`, `seamless`, `robust`, `in the ever-evolving landscape`, `it's important to note`, `as a responsible AI`, `we will explore`, `this is a complex topic`
   - Hedging: `might be`, `could be considered`, `arguably`, `to some extent` (unless uncertainty is real)
2. **Naming check.**
   Flag generic names with no domain meaning:
   - `data`, `info`, `manager`, `helper`, `utils`, `processor`, `handler`, `service`, `common`, `base` (unless part of a recognized pattern)
   - Replace with the domain concept (e.g., `UserProfile` not `UserData`, `InvoiceParser` not `InvoiceProcessor`).
3. **Abstraction check.**
   Flag:
   - Single-call wrapper functions.
   - Interfaces with only one implementation.
   - Premature generic abstractions (`AbstractBaseFoo`, `IManager`).
   - Gold-plating: unrequested features, speculative extension points.
4. **Commit message check.**
   - Reject: `update`, `fix`, `improve`, `changes`.
   - Require: `area: what changed and why`.
5. **Output a slop report.**
   For each issue: `[category] original -> rewrite`.
   If rewrite count > 0, fix before shipping.

## Output
```
## Slop report
| # | category | original | rewrite |
|---|----------|----------|---------|
| 1 | prose | ... | ... |
| 2 | naming | ... | ... |
| 3 | abstraction | ... | ... |
```

Caveman compact. One row per issue.
