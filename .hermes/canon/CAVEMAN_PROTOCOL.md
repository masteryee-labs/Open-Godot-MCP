# Caveman Protocol — Token Compression

> Source: JuliusBrussee/caveman + cheeseonamonkey/Lean-Caveman. Goal: ~65% token reduction without losing precision.

## The problem

Agent transcripts burn tokens on filler that carries no decision-relevant information. 40 words to say what 8 words say. Filler eats context window that should be spent on evidence (file contents, errors, prior state). When context fills with filler, the model loses track of the actual problem.

## The deeper point

Token efficiency isn't just about cost. It's about **attention**. A model with 200K context that's 65% filler effectively has 70K of useful context. A model with 100K context that's 90% signal has more *usable* attention. Caveman mode is a context-window multiplier.

## Why ~65%

Filler (hedging, restating, transitions, pleasantries) accounts for roughly 65% of tokens in verbose mode. Cutting it leaves the signal. The exact number varies by task; the direction is consistent.

## The rule

**Strip filler. Keep signal.**
- Cut: adverbs, hedging, pleasantries, restating the question, motivational filler, transitions.
- Keep verbatim: code, paths, line numbers, errors, identifiers, commands, URLs, exact values.

## Examples

| Verbose (bad) | Caveman (good) |
|---------------|----------------|
| "So I looked into the issue and it looks like the problem is probably in the config file at line 42 where the path seems to be wrong." | `config.json:42` — path wrong. Fix: `/correct/value`. |
| "I'm happy to report that I've successfully completed the deployment and everything appears to be working!" | Deploy done. `verify.py` PASS. 3 tools synced. |

## What caveman is NOT

- NOT broken grammar. Sentences stay parseable.
- NOT dropping evidence. Paths/lines/errors always verbatim.
- NOT for user-facing prose needing warmth (apologies, bad news, teaching).
- NOT for code comments or docs meant for humans.

## When to relax

- User asks for explanation/teaching.
- Writing Docs/README (full prose).
- Bad news or clarifying questions (clarity > brevity).

## Dynamic context compaction

Context fill is a leading indicator of token waste. When the window fills, the model falls back to slop. React before it happens.

### Triggers
- `context_fill_pct > 70%` → switch to `compact` mode.
- `context_fill_pct > 80%` → switch to `ultra` mode.
- A single tool output > 20 lines or > 3KB → dispatch `context-compactor` skill.
- A single `read` would exceed 50 lines → use `read` with `offset`/`limit` or `grep`.

### Automatic load + enforcement
- `post_tool_use.py` writes `context_oversized: true` + `oversized_tool_calls_since_flag: 0` to `.hermes/context_flags/<session_id>.json` when a tool response is oversized. It also prints a stderr directive telling the agent to run `context-compactor` — most tools feed hook stderr back to the agent as feedback.
- If the flag is still set on the next tool call, `post_tool_use.py` increments `oversized_tool_calls_since_flag` — tracking how many tool calls have passed without compaction.
- `pre_tool_use.py` enforces a **graduated gate** based on the counter:
  - **counter 0-1** (note): non-compaction tools allowed + stderr note "compact soon."
  - **counter 2-3** (warning): non-compaction tools allowed + stderr warning "compact NOW, block incoming."
  - **counter >= 4** (block): non-compaction tools **blocked** (exit 2). Agent must run `context-compactor` skill and clear the flag before continuing.
  - Compaction-safe tools (read, grep, glob, write, edit, notebook_*, todo_write, skill) are **always allowed** — the agent needs them to actually compact.
- This makes compaction **enforced, not suggested**. The agent can't ignore the flag indefinitely — at 4+ un-compacted tool calls, it is forced to act.
- `loop-memory` reads `.hermes/context_flags/<session_id>.json` at the end of every iteration and updates `.hermes/session_state/<session_id>.json` and `.hermes/loop_state/<session_id>.md`.
- `.hermes/loop_state.md` registry front matter must include:
  ```yaml
  context_fill_pct: <0-100 estimate>
  caveman_level: <light|compact|full|ultra|wenyan>
  active_session: s-...
  ```
- `.hermes/loop_state/<session_id>.md` must include:
  ```yaml
  context_fill_pct: <0-100>
  caveman_level: <light|compact|full|ultra|wenyan>
  ```

### Compaction rules
- Use `context-compactor` skill for large payloads.
- Never compress verbatim items: code, paths, line numbers, errors, exact values.
- When in doubt, offload the full payload and keep a one-line summary + path.

## Compression levels

| Level | Cuts | Example |
|-------|------|---------|
| **light** | Filler, hedging, pleasantries | `Sync done. 2 issues: src/sync.py:42 path, :88 backup.` |
| **full** | light + articles, aux verbs, restating question | `sync.py:42` hardcoded path (P1). `:88` missing backup (P0). |
| **ultra** | full + abbreviate, drop pronouns, telegraphic | `sync.py:42 hardcode P1. :88 no backup P0. fix: registry + shutil.copy2.` |
| **wenyan** | Classical Chinese register | `sync.py:42 路徑硬編 P1。:88 無備份 P0。修：registry + shutil.copy2。` |

### When to use each

| Channel | Default | Escalate to |
|---------|---------|-------------|
| Worker → Commander | full | compact (>70%) / ultra (>80%) |
| Commander → user | light | full (user asks) |
| Memory writes | full | ultra (near 3KB cap) |
| Large tool output | compact | ultra (context high) |
| Docs / README | full prose | — |
| Bad news / questions | full prose | — |

### Ultra mode

- Abbreviate: `configuration`→`config`, `verification`→`verify`, `implementation`→`impl`
- Drop pronouns: "I found the bug" → `found bug`
- Telegraphic: SVO only, no connectives
- **Still keep verbatim**: code, paths, lines, errors, commands, URLs, values
- **Never ultra for**: bad news, apologies, teaching, user summaries

### Wenyan mode

Classical Chinese (文言文) for Chinese sessions with max compression needed. Same keep-verbatim rules. Only when session language is Chinese AND context constrained.
