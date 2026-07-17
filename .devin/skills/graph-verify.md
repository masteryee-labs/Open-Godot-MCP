---
name: graph-verify
description: "Use when answering structural questions (who calls X, who imports Y, blast radius). Verifies claims against code graph or grep, not memory."
---

# Skill: graph-verify

> Don't trust memory for structure. Trust the graph.

## Trigger
- A claim involves file relationships, call chains, imports, or dependency blast radius.
- A worker says "X is used by Y", "A depends on B", or "this change affects ...".
- Before any refactor that touches multiple files.

## When to run
Before finalizing a structural claim. May be called by Scout, Builder, Auditor, or Commander.

## How

1. **Prefer code graph if available.**
   - If `codebase-memory-mcp` is configured, query it for callers/importers of the symbol/file.
   - If `codebase-memory-mcp` is not available, continue to step 2.
2. **Fallback to grep.**
   - Use `grep -n` or `rg` to find:
     - `import X`, `from X import`, `require('X')`, `using X`, `using X;` for the target.
     - `X(` or `->X` or `X.` or `<X` for call sites.
   - Limit to 5-10 representative matches; do not dump the whole repo.
3. **Filter for the correct symbol.**
   - Same name in different files is not the same symbol. Use file path and namespace to disambiguate.
4. **Attach evidence.**
   - Every structural claim must be followed by `file:line` matches.
   - If you found 0 matches, say `[structure: zero-callers]` and report that, not a guess.
5. **Output `[structure-verified]` if you can trace from the changed symbol to all affected callers.**

## Output
```
## Structure verification
- claim: <what you are asserting>
- method: <codebase-memory-mcp|grep>
- evidence:
  - path/to/file:line
  - path/to/file:line
- status: [structure-verified|needs-graph|zero-callers]
```

Caveman compact. One line per match. No "probably used by".
