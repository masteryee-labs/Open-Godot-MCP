# Handoff Letter — To Future Sessions

> Letter from past sessions to future sessions. Read at BOOT when inheriting a long-running project, after major refactor, or when a new maintainer first touches the repo. Not state (`loop_state.md` is state) — *judgment* and *context* that doesn't fit structured state.

## What this is

| File | Answers |
|------|---------|
| `loop_state.md` | What was I doing? |
| `knowledge_distill.md` | What patterns should I reuse? |
| This letter | What should I know that isn't a pattern or task? |

Captures: decisions + why (not just what), warnings about approaches that look right but aren't, project spirit a fresh session would miss, things obvious to current maintainer but invisible to new one.

## When to read

- New maintainer's first session (human or AI)
- After major refactor
- When `loop_state.md` says `phase: complete` but work feels unfinished
- Quarterly review

## When to write

- End of major milestone
- Non-obvious decision (record reasoning before forgetting)
- Hit a trap that isn't a pattern
- Project spirit shifts

## Template

```markdown
## Letter — [date] — [author]

### Spirit of this project
[2-3 sentences: what this project is trying to be, that a fresh session wouldn't infer]

### Decisions made this session
- [decision]: [why, not what. What is in git log. Why is not.]

### Warnings for future sessions
- [thing that looks right but isn't]: [what to watch for]

### Things obvious to me but not to you
- [context]: [explanation]

### What I didn't finish (and whether you should)
- [item]: [reason unfinished] — [pick up / drop / defer]
```

## Rules

1. **Don't duplicate `loop_state.md` or `knowledge_distill.md`.** Those are structured. This is for what doesn't fit.
2. **Bullets, not prose.** One sentence per point. Must be scannable at BOOT.
3. **No secrets.** Same rule as all memory layers.
4. **Mark opinions as "judgment:"** Don't write opinions as facts.
5. **Append, don't rewrite.** Old letters = history. New on top. Archive to `loop_state_archive.md` when >4KB.
6. **Date every entry.** Letter without date = noise.

## Example (this repo)

```markdown
## Letter — 2026-07-07 — initial build

### Spirit
Agent Harness Deploy is a *deployer*, not a product. The product is the harness it writes into other tools. Stay boring and reliable. Fancy features go in canon, not deployer code.

### Decisions
- Canon files concatenated in fixed order (CANON_ORDER in sync.py), not alphabetical. Why: ordering matters for BOOT.
- CLI variants (agy_cli, codex_cli, devin_cli) share entry files with parent tools, deduped by path. Why: writing AGENTS.md twice wastes + clobbers .bak.
- Claude Desktop gets JSON pointer, not full canon body. Why: markdown in JSON config corrupts it.

### Warnings
- Don't edit AGENTS.md directly — generated from canon. Edits vanish on re-sync.
- Don't add tool to registry.json without adapter module — sync.py crashes on import.
- `verify()` marker check looks for "Agent Harness Deploy" (case-insensitive). Rename project → update base.py too.

### Obvious to me, not to you
- `.codex/` = deployer dogfooding itself. Not a template for what gets synced.
- `Docs/02-Deployment-Guide.md` is the only Doc BOOT mandates reading. Rest are on-demand.

### Unfinished
- deep-memory integration documented but not wired into BOOT automatically. Reason: requires venv + model download. Recommendation: leave opt-in.
```

## Relationship to other canon

| Canon file | Relationship |
|------------|-------------|
| MEMORY_PROTOCOL.md | This letter = 4th unstructured memory layer — above cold, below knowledge. Judgment, not state. |
| BOOT_PROTOCOL.md | Reading this letter is optional at BOOT (new maintainers or post-refactor only). Not in mandatory BOOT sequence. |
| JUDGMENT_RUBRICS.md | Rubrics externalize *recurring* decisions. Letter captures *one-off* decisions + context that didn't become a rubric. |
