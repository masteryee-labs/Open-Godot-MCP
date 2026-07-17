---
name: loop-memory
description: "Use when BOOTing a session (read the registry + knowledge layers) or at the end of every iteration (write per-session state). Keeps state persistent across runs — the model forgets, the repo doesn't."
---

# Skill: loop-memory

> Thin wrapper over `.codex/canon/MEMORY_PROTOCOL.md`. Read at BOOT, write per-session state at the end of every iteration.
> The model forgets; the repo doesn't.

## Trigger
- BOOT: read registry + knowledge layers + per-session state.
- End of every iteration: write per-session state and regenerate the registry.
- Keywords: update memory, loop_state, session_state, iteration end, distill.

## What to do

Follow `.codex/canon/MEMORY_PROTOCOL.md` for the full spec. Quick reference:

| Action | Rule |
|--------|------|
| Read at BOOT | `.codex/loop_state.md` registry (<3KB) + `.codex/knowledge_distill.md` (<8KB) + `.codex/user_profile.md` (<2KB) + `.codex/context_flags/<session_id>.json` if exists. Only read the matching `loop_state/<session_id>.md` and `session_state/<session_id>.json` for audit/conflict. |
| Iteration start | Set `.codex/session_state/<session_id>.json` `state_written` to `false`. |
| Write every iteration | Update `.codex/loop_state/<session_id>.md` with date, phase, last_action, active GoalSpec, subtasks, deferred/human_required, `context_fill_pct`, `caveman_level`. Update `.codex/session_state/<session_id>.json` with `current_subtask`, `last_action`, `last_state_write`, `state_written: true`, `context_fill_pct`, `caveman_level`, `context_flags`, `owned_files`, `affected_files`, `tags`. Then call `python .codex/scripts/loop_memory_sync.py`. |
| Distill when >8KB | Merge duplicate anti-patterns, abstract concrete cases into patterns, archive originals to `.codex/loop_state_archive.md`. Dispatch Memory Keeper if judgment needed. |
| Micro-memory | Run `memory-audit` skill every 5 iterations or scope change. It invokes `python .codex/scripts/memory_audit.py --session <session_id>`. |
| Cold layer | Append-only. Never edit; only archive. |
| Secrets | Never write secrets/keys/API tokens to any layer. |
| Skipping write | Red line #7 (canon). |

## StateWritten contract

- `state_written` is the heartbeat of honest progress.
- Set it to `false` at the very start of every iteration.
- Set it to `true` only after the per-session markdown and JSON have been written and `loop_memory_sync.py` has returned.
- `stop.py` uses `state_written` + `last_state_write` to decide between `completed` and `crashed`.

## Optional: deep-memory

If `~/.deep-memory/.venv` exists, run cross-project retrieval via `chroma-hybrid-search` skill.
If not, set `deep_memory_offline: true` in `.codex/session_state/<session_id>.json`. Do not fabricate memory.
To bootstrap, run `python scripts/init_deep_memory.py`.
