# Model Tier Mapping

> Tool-specific mapping for the abstract model tiers used in `DISPATCH_TEMPLATES.md`.
> Update this file when new models are released; the canon itself stays tool-agnostic.

| Tier | Meaning | Claude Code | Codex CLI | Devin CLI | Antigravity / AGY |
|------|---------|-------------|-----------|-----------|-------------------|
| **cheap** | Fast scan, grep, read, light checks | `claude-haiku-3-20250217` | `codex-4-mini` | `subagent_explore` | `gemini-1.5-flash` |
| **mid** | General coding, editing, most workers | `claude-sonnet-4-20250514` | `codex-4` | `subagent_general` | `claude-sonnet-4-20250514` via `--model` |
| **high** | Deep reasoning, verification, Auditor | `claude-opus-4-20250514` | `codex-4` with `--reasoning` | `subagent_general` with rich context | `claude-opus-4-20250514` via `--model` |

> Notes:
> - Model names are examples. Use the latest stable IDs from the vendor's docs.
> - `cheap` is for Scout/Scout-like tasks and Sensor passes.
> - `mid` is the default for Builder, Verifier, Memory Keeper.
> - `high` is for Auditor, multi-step reasoning, and L/XL final checks.
> - If a tier is not available, default to the next higher tier.

## Escalation rules

When a model fails, escalate — don't retry the same tier indefinitely.

| Current tier | Failure signal | Action |
|--------------|---------------|--------|
| cheap | Same subtask fails **1 time** (syntax error, path error, wrong API) | Escalate to mid with failure trace |
| mid | Same subtask fails **2 times** consecutively | Escalate to high with failure trace |
| high | Same subtask fails **2 times** consecutively | Stop. Mark `human_required`. Ask the human. |

**Failure trace** (required when escalating): error message + attempted fix + file:line + command output.

**Max retries**: 2 rounds total per issue (including tier changes). After 2 rounds, mark `deferred` or `human_required`.

**Downgrade** (after verification passes): if a high-tier model solves a pattern, template the solution and batch-run with cheaper models.
