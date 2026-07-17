# BOOT Protocol — Startup Sequence

> Order is mandatory. Do not skip or reorder. Total BOOT payload target: <16KB.

---

## Sequence

1. **Read entry file** — the file that brought you here (AGENTS.md / CLAUDE.md /
   instructions.md / .devin/AGENTS.md). It routes you to canon.
2. **Ensure registry exists** — `.agents/loop_state.md` is the session registry.
   If it does not exist, create an empty registry with front matter:
   ```yaml
   ---
   active_sessions: []
   active_session: null
   ---
   ```
   Do not write a `session_id` into the registry until the GoalSpec is finalized.
3. **Read registry** — `.agents/loop_state.md` (<3KB). Inherit prior state:
   `active_sessions`, `active_session`, and links to `knowledge_distill.md` and
   `handoff_letter.md`.
4. **Read knowledge layer** — `.agents/knowledge_distill.md` (<8KB). Anti-patterns.
5. **Read user profile** — `.agents/user_profile.md` (<2KB). Language, model tier,
   project type, custom red lines.
6. **Read handoff letter** — `.agents/handoff_letter.md` if it exists and `phase`
   is `complete` or `last_update` is newer than the last known session.
7. **Determine `session_id`** — choose or reuse a session ID:
   - Prefer a value supplied by the tool (`post_tool_use`/`stop` input or env var).
   - If an `active_session` is already set and its status is `in_progress`, `crashed`, or
     `suspected_crashed`, and the new task overlaps its `tags`/`owned_files`, the current
     session ID is reused **only after** the human confirms continuation.
   - Otherwise generate a new `session_id` (slug/UUID, max 64 chars, no `: / \`
     or spaces).
8. **Read per-session context flags** — `.agents/context_flags/<session_id>.json`
   if it exists. Carries `context_oversized` and any per-session signal.
9. **Pre-task / crash audit** — run `python .agents/scripts/pre_task_audit.py --files <files> --tags <tags> --session <session_id>`:
   - It reads `session_state/<session_id>.json` for any session in `active_sessions`
     with `status` `in_progress`, `crashed`, or `suspected_crashed`.
   - It compares `last_heartbeat`, `last_state_write`, `owned_files`, `affected_files`,
     and `tags` against the new task.
   - If `max(last_heartbeat, last_state_write)` is > 30 minutes ago, the session is
     treated as stale and `suspected_crashed`.
   - If there is overlap with `owned_files` / `affected_files` / `tags`, ask the
     human whether to continue the previous session. **Never auto-resume.**
   - If no overlap, start a new session; the old session remains in the registry.
10. **Read deploy guide** — `Docs/02-Deployment-Guide.md` (only if deploying).
11. **Output GoalSpec** — write to `.agents/loop_state/<session_id>.md` and
    `.agents/session_state/<session_id>.json`:
    ```yaml
    session_id: "s-..."
    goal: "[one-line summary]"
    complexity: "S|M|L|XL"
    context_fill_pct: 0
    caveman_level: "full"
    scope:
      angles_required: ["angle1", "angle2"]
      files_to_check: ["path1", "path2"]
      sensor_mode: "code" | "doc"
    subtasks: []  # L/XL required
    acceptance_criteria: []
    human_in_loop_triggers: []
    estimated_iterations: N
    ```
    The machine-readable JSON in `session_state` must include `status: in_progress`,
    `state_written: false`, `last_state_write`, `last_heartbeat`, `owned_files`,
    `affected_files`, and `tags`.
12. **Update registry** — append the new session to `.agents/loop_state.md` active
    sessions table and set `active_session` to the new `session_id`. Then call
    `python .agents/scripts/loop_memory_sync.py` to regenerate the registry from the
    session state files.
13. **Deep-memory check** (optional) — if `~/.deep-memory/.venv` exists, run retrieval.
    If not, set `deep_memory_offline: true`. Do not fabricate memory.
14. **Large-repo init** (optional) — if the repo has >50 source files or >20 directories,
    consider running `init_deep` skill to build a code graph.
15. **Differential gap-scan** — scan 1-2 scope angles only. See `.agents/skills/gap-scan.md`.

## Rules

- Do NOT read all Docs at BOOT. Load on demand via the index in `Docs/00-Overview.md`.
- Do NOT read full `context.md` if a quick-lookup variant exists.
- Do NOT start work without a GoalSpec for L/XL tasks.
- Do NOT read every `session_state/*.json` or every `loop_state/*.md` at BOOT.
  Read the registry first; only read the one session state that matches the task.
- Do NOT auto-resume a crashed or in-progress session. Detect it, then ask the human.
- BOOT is for orientation. Work happens after.

## Multi-thinking mode activation

At BOOT, activate the default thinking mode set (see `Docs/09-Multi-Thinking-Modes.md`):
- **Skeptic** — default. Every claim needs evidence.
- **Architect** — for planning/decomposition tasks.
- **Auditor** — for verification/completion tasks.

Switch modes explicitly when the task changes character. State the active mode in output.

## Rule placement (Lost in the Middle)

> See `HARNESS_ENGINEERING.md §Rule placement and attention management` for the full principle.
> Short version: critical rules go at the top of the entry file (first 30 lines = "golden
> position"). Rules buried at line 300 of a 600-line file are effectively unwritten.
