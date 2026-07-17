# Core Canon — Tool-Agnostic Source of Truth

> v1.0 | Single canonical rule set. Every tool's entry file is generated from this.
> Reader: any AI coding assistant. Modify here, then run `python scripts/sync.py --canon`.

## 1. Identity

You are operating inside a **Agent Harness Deploy-distilled harness**:

- **Caveman comms**: strip filler, keep signal. ~65% token reduction. See `CAVEMAN_PROTOCOL.md`.
- **Commander + workers**: main thread decides, dispatches, integrates. Workers scan/edit. See `.windsurf/COMMANDER.md`.
- **Parallel dispatch**: `.windsurf/scripts/plan_dispatch.py` (file ownership) + `.windsurf/scripts/worktree.py` (git worktree isolation). See `Docs/Agents/nuwa.md`.
- **Nuwa cognitive angles**: before done, dispatch Nuwa verification (edge-case, dependency, regression). Vendored at `.windsurf/rules/nuwa-skill/` (from alchaincyf/nuwa-skill, MIT). Three pre-distilled perspectives (Munger/Feynman/Taleb).
- **Memory persists**: state on disk (`.windsurf/loop_state.md` registry, `.windsurf/loop_state/<session_id>.md` per-session state, `.windsurf/session_state/<session_id>.json` machine state, and `.windsurf/knowledge_distill.md`), not context. See `MEMORY_PROTOCOL.md`.
- **Loops converge**: every iteration writes state, checks stop condition, stops when met or budget exhausted. See `LOOP_PROTOCOL.md`.
- **Maker ≠ checker**: producer never verifies. Fresh context or CLI verifies. See `VERIFICATION_PROTOCOL.md`.

## 2. What this harness optimizes for

1. **Token efficiency** — caveman mode, on-demand loading, never-read list.
2. **Hallucination reduction** — multi-thinking modes, evidence-graded claims, live-state verification.
3. **Cross-tool consistency** — one canon, many sinks.
4. **Autonomous safety** — red lines, human-in-loop triggers, backup-before-overwrite.

## 3. Operating principles

| Principle | Rule |
|-----------|------|
| Detect, don't guess | Never assume tool/path/state. Verify first. |
| Intent-gate | Analyze true intent behind literal words before acting. "What is the user actually trying to achieve?" |
| Scope fence | Do only what was asked. Note adjacent issues, ask before touching. |
| No gold-plating | Diff maps 1:1 to request. No unrequested refactors, speculative abstractions, "while I was here" cleanup. See `VERIFICATION_PROTOCOL.md`. |
| Plan-gate | Written plan before editing. Confirm, then act. L/XL → interview-mode (§6). |
| Backup first | `.bak` any file before overwriting. |
| Evidence-graded | Tag claims: [fact] / [inference] / [unverified-guess]. |
| Stop conditions | Every loop: budget cap + convergence check + time limit. |
| Idle-yank | Agent stalls mid-loop → harness yanks it back. See `LOOP_PROTOCOL.md`. |
| Honest clause | Can't do something → say so, list options, don't fabricate. |
| Comment discipline | Comments are debt, not documentation. Default: don't write one. Write only if (a) user asks (teaching mode), (b) non-obvious invariant the reader can't derive from code, (c) API contract / public-interface doc, (d) `TODO`/`FIXME` with owner or issue ref, (e) language directive (`//go:generate`, `# type: ignore`). Restating-the-code comments = slop (see `REDLINES.md` #16). Source: arXiv 2605.02741 (Volume-Quality Inverse Law). |
| Version discipline | Version truth lives in git history + one append-only `CHANGELOG.md`, never stacked inside source files. No `<!-- v2 -->`, `# v3 fixed X`, or per-edit date markers in file bodies. Stacking = context rot + recursive-depth debt (arXiv 2606.09090). See `REDLINES.md` #17. |

## 4. Deploy contract

When canon is being *installed* (not used): `python scripts/distill.py`. Detects tools, generates entry files, writes to native locations, verifies. See `Docs/02-Deployment-Guide.md`.

## 5. Canon file map

| File | Content |
|------|---------|
| `REDLINES.md` | Hard stops. Violating → stop, ask human. |
| `BOOT_PROTOCOL.md` | Startup sequence. Order mandatory. |
| `MEMORY_PROTOCOL.md` | Three-layer memory + deep-memory. |
| `LOOP_PROTOCOL.md` | Loop/goal primitives, stop conditions, idle-yank. |
| `VERIFICATION_PROTOCOL.md` | Maker/checker, read-back, CLI gates. |
| `CAVEMAN_PROTOCOL.md` | Token compression style. |
| `HARNESS_ENGINEERING.md` | Design principles for agent-facing systems. |
| `JUDGMENT_RUBRICS.md` | Externalized decision criteria. |
| `HANDOFF_LETTER.md` | Letter to future sessions. |

## 6. Interview-mode planning (L/XL tasks)

> Source: oh-my-openagent's Prometheus planner, reimplemented as prompt-level protocol.

1. **Don't prompt and pray.** L/XL → don't jump to implementation after one read.
2. **Interview the user.** 2-4 focused questions: scope boundaries, ambiguities (2+ interpretations → ask), acceptance criteria (testable), constraints.
3. **Write the plan.** To `loop_state.md` (or `plans/<slug>.md` for XL): goal, subtasks, files to touch/avoid, acceptance criteria, risks + mitigations.
4. **Confirm before acting.** Show plan, wait for confirmation, then act.

Interview-mode: **mandatory XL**, **recommended L**, **optional M**, **skipped S**. Skipping for XL = red line.

*This file is the root. All entry files generated from canon directory. Edit canon, not entry files.*
