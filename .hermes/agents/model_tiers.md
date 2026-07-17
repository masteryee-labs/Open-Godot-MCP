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
