# Loop Protocol — Convergent Iteration

> Loops let agents work autonomously. Bad loops burn money and produce noise.
> Every loop needs: a goal, a stop condition, and a budget.

## The shift

Prompt Engineering: you talk to the AI every turn.
Loop Engineering: you design a system where the AI talks to itself, verifies, records state, and runs the next turn — until a stop condition is met.

The human moves from "driving every turn" to "designing the loop, setting rules, handling exceptions."

---

## Four loop types (handoff 2×2)

> Source: Inside article (2026-07-14) on Loop Engineering, mapping Anthropic's manual/evaluated/scheduled trichotomy + Avi Chawla's four-type diagram to Claude Code's `/goal` `/loop` `/schedule` primitives. The four types differ on **one axis only**: how much of "what triggers a run" and "what decides done" is handed to the system vs kept by the human.

The two questions every loop answers: **what starts a run**, and **what decides it's finished**. The four types are the 2×2 of who owns each.

| Type | Trigger | Done-decision | Claude Code primitive | When |
|------|---------|---------------|----------------------|------|
| **Turn-based** | Human prompt | Human reviews output | (default chat) | Exploratory; each output reshapes next question |
| **Goal-based** | Human `/goal` w/ success condition + budget | Independent evaluator model | `/goal` | Result measurable; process not worth watching |
| **Time-based** | Clock (interval) | Human / cap | `/loop` (local) or `/schedule` (cloud) | Content known; only timing repeats |
| **Proactive** | Event / schedule, **no human present** | Adversarial review agent (passes → close) | routine + triage/fix/adversarial agents | Unpredictable incoming work; standing duty |

**Handoff ladder:** turn-based keeps both with human → goal-based automates done-decision → time-based automates trigger → proactive automates both **and** generates the workflow on the spot.

**Mapping to this protocol:**
- Turn-based = the manual baseline; not loop-engineered, just chat. No kickoff needed. But: write the verification you repeat every turn into a Skill (SKILL.md) — checklist, multi-step flow, support files. The loop stays human-driven, but each turn's quality stops depending on you remembering to remind the agent. This is the cheapest upgrade: no autonomy added, consistency gained.
- Goal-based = `/goal` mode below + maker≠checker (the evaluator is the checker).
- Time-based = `/loop` (local) or `/schedule` (cloud) below.
- Proactive = §"Proactive loop pattern" below — the only type where the workflow itself is generated at trigger time and an adversarial reviewer is the gate.

**Pick by task nature, not by sophistication.** Exploratory → turn-based. Measurable → goal-based. Periodic → time-based. Standing duty with unpredictable input → proactive. Mismatch = either over-engineering or letting a high-automation loop run something that needs human judgment.

**The deeper the handoff, the higher the bar for stop conditions + guardrails.** No clear termination → infinite loop burns API budget. No adversarial review in proactive → errors amplified while no one watches. The two core skills loop engineering demands: define "what counts as done" and "how to brake on error."

---

## Three loop modes

| Mode | Semantics | When to use |
|------|-----------|-------------|
| `/loop` | Cadence-based, **local**: re-run every N min/hours. Never self-stops. Stops when machine sleeps / user closes laptop. | Inspection, monitoring, periodic checks on your own machine |
| `/schedule` | Cadence-based, **cloud**: same cadence semantics, but runs server-side. Keeps running when laptop closed. | Periodic work that must run unattended across sleep/shutdown |
| `/goal` | Condition-based: run until a verifiable condition is met. | Bug-fix-until-tests-pass, refactor-until-clean |

- Has an endpoint → `/goal`; no endpoint → `/loop` or `/schedule`.
- `/loop` / `/schedule` for convergent tasks = infinite spend. `/goal` for inspection = never terminates.
- `/schedule` raises the stakes: it runs while you're away, so stop conditions + budget cap + adversarial review are **mandatory**, not optional. A broken `/schedule` burns budget 24/7.
- **Cadence matches data change rate, not your patience.** PR might change hourly → don't poll every minute. Over-polling burns tokens, API quota, and external-service budget for zero new information. Set the interval to the fastest rate the watched thing actually changes.

## The 5+1 components

A complete loop needs five components plus a memory spine:

| # | Component | Purpose |
|---|-----------|---------|
| 1 | Loop / Goal | How the loop runs, when it stops |
| 2 | Worktrees | Parallel agents don't clobber each other's files |
| 3 | Skills | Project knowledge written down, so agents don't guess |
| 4 | Connectors | Agents reach beyond the filesystem (GitHub, Linear, Slack, DB) |
| 5 | Sub-agents | Maker and checker are different agents |
| +1 | Memory | Cross-run persistent state — agents forget, repos don't |

- **Worktrees** solve *file* clashes, not *cognitive* clashes. Parallelism limit = review bandwidth, not worktree count.
- **Skills** hold project conventions, build steps, "we don't do X because of past incident Y." Without skills, every iteration re-derives from zero.
- **Connectors** (MCP-based) let agents read issue trackers, query DBs, call APIs, post to Slack. Without them, the agent says "here's the fix" and you do the PR.
- **Sub-agents**: the agent that writes code is too lenient grading its own work. Maker and checker are separate. Even the stop condition is judged by a separate checker.
- **Memory**: without a state file, the next iteration doesn't know what the last one did. State records: what was tried, what passed, what's still open.

## When NOT to loop

Three conditions must hold to loop-ify a work segment:
1. **Measurable metric** — no metric → loop degrades to "runs but doesn't know if it's good."
2. **Failure cost is controlled** — uncontrolled → human stays in the loop.
3. **Harness is hard enough** — weak harness → fix the harness first, don't loop yet.

If any fails, don't loop unattended. Loop to "produce draft for human review" instead.

**Don't loop what a script can do deterministically.** Fixed-format conversion, form filling, data cleaning, mechanical rename — if the steps are fully predictable and need no judgment, write a script, don't burn model tokens re-deriving the same transformation every iteration. Loops are for work that *changes* based on what the last iteration found. Deterministic work in a loop = paying LLM prices for `sed`.

## Mandatory stop conditions (all three required)

1. **Budget cap** — token/iteration/cost limit. Hit → stop.
2. **Convergence check** — N consecutive iterations with no new finding/improvement → stop.
3. **Time limit** — hard wall-clock cap. Hit → stop.

A loop missing any of the three is a broken loop. Do not run it unattended.

## State contract

Every iteration:
1. Read `.windsurf/loop_state.md` registry (which sessions are active/completed).
2. Read `.windsurf/loop_state/<session_id>.md` for the active session (where did I get to?).
3. Do one unit of work.
4. Write `.windsurf/loop_state/<session_id>.md` and `.windsurf/session_state/<session_id>.json`
   (what did I do, what's next, what's still open).
5. Call `python .windsurf/scripts/loop_memory_sync.py` to regenerate `.windsurf/loop_state.md` registry.
6. Check stop condition.
7. Not met → next iteration. Met → stop, archive result.

Without step 4, the next iteration repeats work or skips ahead. State is the spine.

## Maker/checker in loops

The agent that runs the loop body **must not** judge whether the stop condition is met. A separate checker (fresh context, or deterministic script) evaluates the condition. Prevents "I think it's done" self-approval.

**The evaluator should be a smaller / faster / cheaper model than the worker.** The worker does the hard generative work; the evaluator only checks a condition ("did tests pass?", "is the score ≥ 90?"). That check is cheap — don't spend worker-tier tokens on it. Using the same expensive model for both roles doubles cost for no quality gain. The evaluator's job is narrow and verifiable; a smaller model does it just as well, faster.

## Remediation sub-loop

When a checker finds a problem, the fix is a sub-task dispatched to a worker — not the checker fixing it. Checker checks; worker fixes; checker re-checks. Cap retries: same problem 2 rounds → escalate to human.

## Anti-patterns

- No stop condition → don't run unattended. Ever.
- Same agent writes + checks → split them.
- Loop to avoid thinking → if you can't define a metric, you can't loop. Hand to human.
- Ignoring state → next iteration is blind. Always read state first.

## Idle-yank

> Source: oh-my-openagent's Todo Enforcer (Sisyphus Labs), reimplemented as prompt-level protocol (no OmO runtime dependency).

If an agent has not produced output AND not written `.windsurf/loop_state/<session_id>.md` and `.windsurf/session_state/<session_id>.json` for **N** consecutive polling intervals (default N=2), the harness yanks it back:

1. **Re-inject the GoalSpec.** Re-read `.windsurf/loop_state/<session_id>.md`, restate the goal + current subtask.
2. **Force a state write.** Require `.windsurf/loop_state/<session_id>.md` and `.windsurf/session_state/<session_id>.json` update before any other action.
3. **Diagnose the stall.** Blocked? confused? done-but-didn't-declare? Each has a different response.
4. **Re-dispatch or escalate.** Don't let the agent sit idle again.

### Stall diagnosis + response

| Stall type | Signal | Yank response |
|------------|--------|---------------|
| **Blocked** | Hit error/obstacle, stopped | Re-dispatch with obstacle as subtask. 2 rounds → escalate. |
| **Confused** | Output off-topic/contradicts GoalSpec | Re-inject GoalSpec + scope. Reset to last known-good state. |
| **Done-but-silent** | Output complete, no state write | Force verification (maker≠checker). Verified → done. Not → re-dispatch. |
| **Drifted** | Started tangential task | Stop tangent. Log as "deferred". Re-dispatch original goal. |
| **Truly idle** | No output, no state, no error | Re-dispatch from last state. 2 rounds → escalate (tool/API failure?). |

### Implementation (prompt-level)

Enforced by the **Commander** (or user, if no Commander). Between iterations, check each active worker: if `last_output_age > 2 * polling_interval` AND `state_write_age > 2 * polling_interval` → diagnose stall type → yank (re-inject GoalSpec + force state write + re-dispatch or escalate).

For user-driven loops: if no per-session state write and no done-declaration → prompt: "You went idle. Read `.windsurf/loop_state/<session_id>.md`, state current subtask, continue. If blocked, say what. If done, run verification."

### Rules

- **Not a punishment.** Recovery mechanism — re-orienting the agent.
- **Don't yank too early.** N=2 gives agent time for real work. Every interval = micromanagement.
- **Don't yank too late.** N>4 = loop stalled. User waiting.
- **Yank ≠ escalate.** Yank = "wake up". Escalate = "human needed". Yank first; escalate if yank fails 2 rounds.
- **State write is the heartbeat.** Writes `.windsurf/loop_state/<session_id>.md` and `.windsurf/session_state/<session_id>.json` = alive. Doesn't = idle or done — yank distinguishes.

See §"The 5+1 components" above for the component blueprint.

## Warning signals (observable → meaning → action)

> Source: personal governance framework "預警表" concept. Signals must be observable (file state, command output, timestamps) — not feelings.

### The signal table

| # | Observable signal | Meaning | Action |
|---|-------------------|---------|--------|
| 1 | `.windsurf/loop_state/<session_id>.md` or `.windsurf/session_state/<session_id>.json` not updated 2+ iterations | Skipping per-session state writes — loop blind | Force per-session state write first. 2nd round → red line, escalate. |
| 2 | `verify.py` fails same check 2+ rounds | Systematic issue | Stop fixing symptoms. Dispatch systematic-debugging skill (Phase 1). |
| 3 | `knowledge_distill.md` > 8KB | Knowledge bloated | Distillation pass: merge dups, abstract to patterns, archive to cold. |
| 4 | Same error recurs across 2+ sessions | Anti-pattern not captured | Write `knowledge_distill.md` entry: trigger + action + counter-example. |
| 5 | Budget cap hit, 0 convergence iterations | Not converging — goal wrong | Stop. Re-examine GoalSpec. Exit condition testable? Check deterministic? |
| 6 | Worker BLOCKED 2+ times same task | Task too large or plan wrong | Break into smaller pieces or escalate. Don't retry same approach. |
| 7 | 3+ fixes, each reveals new problem elsewhere | Architectural problem | Stop fixing. Question architecture. Discuss with human. (See Phase 4.5) |
| 8 | `.windsurf/loop_state/<session_id>.md` exists but GoalSpec empty | BOOT incomplete | Stop. Re-run BOOT step 11. No work without GoalSpec for L/XL. |
| 9 | Memory retrieval score < 0.35 all queries | Deep-memory irrelevant | Set `memory_low_relevance: true`. Don't fabricate. Fresh analysis. |
| 10 | Knowledge entry references path grep returns nothing | Entry stale | Mark `[STALE: path not found — date]`. Re-verify or archive. |
| 11 | 2+ tool-call parameter errors in session | Context degradation | Dispatch to fresh-context subagents. Don't retry same context. |
| 12 | Model edits file marked "done" or contradicts `knowledge_distill.md` | Semantic drift | STOP. Re-read state + knowledge. Revert wrong edits. Confirm with human. |
| 13 | Model claims "file written" but read-back shows missing/unchanged | False completion | Re-execute write. Verify read-back. 2nd fail → escalate. |
| 14 | `.windsurf/context_flags/<session_id>.json.context_oversized = true` or `context_fill_pct > 70%` | Context degrading | Dispatch `context-compactor`. Offload large outputs. Lower `caveman_level`. |
| 15 | Loop actions don't map to GoalSpec (diff has unrelated changes) | Intent drift | STOP. Re-confirm intent with human. Start new loop if intent changed. |

### How to use the table

1. **At BOOT:** Check 3, 8, 9, 10 (memory/state health). 2. **Between iterations:** Check 1, 2, 5, 6, 14 (loop/context health). 3. **On session end:** Check 3, 4 (knowledge health). 4. **Anytime:** 7, 8, 14 are circuit breakers — STOP immediately if triggered.

### Rules

- **Observable, not interpretive.** "Agent seems confused" ≠ signal. "Agent's output contradicts GoalSpec §2" = signal.
- **One signal → one action.** Don't bundle. If multiple fire: circuit breakers (7, 8) first, then state (1, 5), then knowledge (3, 4, 10), then memory (9).
- **Log signal fires to `.windsurf/loop_state/<session_id>.md` and `.windsurf/session_state/<session_id>.json`.** Record: which signal, when, action taken.

## Loop Readiness Score

> Source: cobusgreyling/loop-engineering `loop-audit`. `verify.py` is binary (PASS/FAIL). A graded rubric tells you how far from loop-ready.

### The rubric (0-100)

| Category | Max | What's checked | How to verify |
|----------|-----|----------------|---------------|
| **State persistence** | 20 | `.windsurf/loop_state.md` registry exists, <3KB; `.windsurf/loop_state/<session_id>.md` and `.windsurf/session_state/<session_id>.json` are written every iteration | `ls .windsurf/loop_state/<session_id>.md` + `ls .windsurf/session_state/<session_id>.json` + timestamps |
| **Knowledge layer** | 15 | `knowledge_distill.md` exists, <8KB, ≥1 distilled entry | `ls .windsurf/knowledge_distill.md` + `wc -c` |
| **Stop conditions** | 15 | Every loop has budget + convergence + time limit | grep kickoffs for "Max iterations" + "Time limit" |
| **Maker ≠ checker** | 15 | Fresh-context or CLI verification, not self-approval | Does verify.py exist? Separate verifier role? |
| **Memory safety** | 10 | No secrets in any layer; cold layer grep-only | `grep -r "key\|token\|password" .windsurf/` = nothing |
| **Red lines** | 10 | REDLINES.md exists, referenced in entry file | `grep REDLINES AGENTS.md` or `CLAUDE.md` |
| **Skills loaded** | 10 | ≥1 skill deployed (auditor, gap-scan, etc.) | `ls .claude/skills/` or equivalent |
| **Warning signals** | 5 | Warning signal table exists in canon | `grep "Warning signals" LOOP_PROTOCOL.md` |

### Score interpretation

| Score | Status | Action |
|-------|--------|--------|
| 90-100 | Loop-ready | Can run unattended loops (L3) |
| 70-89 | Mostly ready | Run assisted loops (L2); fix gaps before unattended |
| 50-69 | Partially ready | Report-only loops (L1); significant setup needed |
| <50 | Not ready | No loops. Fix state, memory, and verification first |

### How to use

1. **At harness setup:** Run rubric manually. Score each category. Fix gaps. 2. **After major changes:** Re-score. 3. **Before unattended loops:** Must score ≥90. <90 = unattended mistakes. 4. **Track over time:** Log to `.windsurf/loop_state/<session_id>.md` and `.windsurf/session_state/<session_id>.json`. Dropping score = harness decay.

## Failure reverse-engineering (proactive weak-model defense)

> Source: community Fable 5 harness-building prompt "失敗逆向推導" concept. Warning signals are reactive (signal → respond). F.R.E. is proactive (predict failure → pre-build defense). Important for weak models (Sonnet, Haiku) in long sessions.

### The method

1. Identify failure mode (exact cognitive/mechanical failure, not "it makes mistakes").
2. Find root cause (trigger).
3. Design defense (observable precursor + preventive action).
4. Add to signal table.

### Three weak-model failure scenarios

| # | Failure mode | Root cause | Observable precursor | Defense | Signal |
|---|-------------|------------|---------------------|---------|--------|
| 1 | Tool-call degradation: wrong/stale params as context grows | Context bloat pushes tool schema out of attention | Tool call fails "invalid parameter" 2+ times | (a) Context >60% → subagent dispatch. (b) 2nd error → re-read schema. (c) Log `tool_call_degradation: true` | 11 |
| 2 | Semantic drift: re-edits completed work | GoalSpec + completed-work scroll out of context | Edits file marked "done" or contradicts `knowledge_distill.md` | (a) Read `.windsurf/loop_state/<session_id>.md` every iteration. (b) Before editing: grep state+knowledge for filename. (c) Contradicts decision → STOP, re-read, confirm | 12 |
| 3 | False completion: claims "written" but file missing/unchanged | Completion narrative before tool call, or tool silently fails | Claims "written" but read-back shows missing/unchanged | (a) Every write → `read(path, limit=5)`. (b) `verify.py` at session end. (c) Read-back fails → re-write. (d) Log `false_completion_detected: true` | 13 |

### When to run failure reverse-engineering

At harness setup (predict top 3 failure modes, pre-build defenses). After a failure (reverse-engineer → add new signal). On model change (re-run for new model's failure modes). Every 50 iterations (review for new failure modes).

### Relationship to warning signals

Warning signals (1-10) = reactive ("signal appeared — what do I do?"). F.R.E. (11-13) = proactive ("what will go wrong before it does?"). Both feed same signal table. Signals = harness health; F.R.E. = model cognition.

## Kickoff prompt templates

Copy-paste templates. Fill the brackets. Every kickoff must specify goal, max iterations, check command, and exit condition.

### Standard kickoff template (both modes)

```
Start the "[LOOP NAME]" [goal|cadence]-loop.
Goal/Purpose: [verifiable end state OR what to monitor]
Max iterations: [N]  Budget cap: [tokens]  Time limit: [wall-clock]
[For /loop only: Cadence: [interval]]
Between iterations run: [check command, e.g. "python -m pytest tests/ --tb=short"]
Exit when: [exit condition, e.g. "check returns 0 AND no new failures for 2 consecutive runs"]
[For /loop: Exit when: max iterations OR time limit OR user stops]

Step 1: [first action]  Step 2: [second action]  Step 3: [third action]
Convergence: if 3 consecutive iterations produce no new fix, STOP and report. [/goal only]
State: §State contract
Maker/checker: the agent that fixes does not judge exit condition. Re-run check command cold.
```

**Mode differences:** `/goal` has convergence check + exit condition. `/loop` has cadence interval, no convergence (monitors don't converge). `/loop` state includes timestamp + result.

### Hook-based variant (event-driven, no prompt needed)

For tools with hooks (Cursor `.cursor/hooks.json`, Claude `.claude/settings.json`): configure `afterEdit` hook to run check command on `exit_code != 0` → `notify_agent_with_output`. Agent receives hook output, decides fix or escalate. `/goal` loop without explicit kickoff — edit event starts each iteration.

### Rules for all kickoffs

1. Every bracket must be filled. `[TBD]` = wish, not kickoff. 2. Check command must be deterministic. "Does it look good?" ≠ check command. 3. Exit condition must be testable by check command. Can't evaluate → can't terminate. 4. Max iterations mandatory even for `/goal`. Never hits condition → must still stop. 5. State write is non-negotiable. No state = can't resume.

## Concrete loop library

> Source: loops.elorm.xyz pre-built loop collection. Concrete instances for common scenarios (7 loops: ship, watch, guard, verify, triage, sweep, cleanup).

### Loop variable table

| # | Name | Mode | Goal/Purpose | Max iter | Check command | Convergence | Unique |
|---|------|------|--------------|----------|---------------|-------------|--------|
| 1 | Ship PR Until Green | `/goal` | PR open with all CI passing | 10 | `gh pr checks --watch` | 3 no new fix → STOP | Budget: 100K, 60 min |
| 2 | CI Failure Watcher | `/loop` | Monitor CI, auto-fix failures | 12 (1hr) | `gh run list --branch $(git branch --show-current) --limit 1` | None (cadence) | Cadence: 5 min |
| 3 | Post-Edit Test Guard | hook | Regression protection during editing | — | `npm test -- --findRelatedTests $(git diff --name-only HEAD)` | — | Event-driven (afterEdit) |
| 4 | Independent Verifier Pass | `/goal` | Build, lint, tests pass independently | 8 | `npm run build && npm run lint && npm test` | 3 no new fix → STOP + escalate | Verifier never fixes — dispatches to Builder |
| 5 | Daily Triage | `/loop` | Scan repo: issues, failing tests, stale branches | 7 (1wk) | `git fetch --all && gh issue list --state open && npm test -- --listTests` | None (cadence) | Report only, L1 |
| 6 | Dependency Sweeper | `/loop` | Check outdated + vulnerable deps; patch if safe | 4 (24hr) | `npm audit --json && npm outdated --json` | 2 same vuln → STOP | Cadence: 6h |
| 7 | Post-Merge Cleanup | `/loop` | Clean stale branches, rebuild indexes, archive | 4 (24hr) | `git branch --merged main \| grep -v main` | None (cadence) | Cadence: 6h |

**When to use:** Ship change with CI → Loop 1. Monitor CI → Loop 2. Regression protection → Loop 3. Verify "done" → Loop 4. Daily health scan → Loop 5. Dep vulnerability → Loop 6. Post-merge cleanup → Loop 7.

### Standard loop body (applies to all)

All loops follow the kickoff templates above. Steps: (1) check status/read state/run check command. (2) If problem found → read logs, fix, verify. (3) Re-check, write `.windsurf/loop_state/<session_id>.md` and `.windsurf/session_state/<session_id>.json`, then call `python .windsurf/scripts/loop_memory_sync.py` to update the registry; wait for cadence if `/loop`. State: §State contract. Maker/checker: CI/verifier checks; agent fixes. No self-approval.

### Loop-specific notes + variants

| # | Unique steps | Variants |
|---|-------------|----------|
| 1 | Branch → push → PR → wait CI → fix → re-check | No CI → `npm test`/`pytest`. Multi-CI → `gh pr checks --watch` |
| 2 | Check CI → if failed: fix+push → if ok: wait | Multi-branch → `--branch`. Non-GitHub → `curl` API |
| 3 | Edit → hook runs tests → if fail: fix before more edits | Python → `pytest --testmon`. No testmon → `pytest -k "<file>"` |
| 4 | Run build/lint/tests cold → if fail: dispatch to Builder → re-run | Python → `pytest && ruff . && mypy .`. Go → `go test && go vet`. Multi-agent → 2 agents |
| 5 | Fetch → list issues → list tests → stale branches >14d → report | No GitHub → tracker CLI. Python → `pytest --collect-only` |
| 6 | audit+outdated → if high/critical: `npm audit fix` + test → if breaking: report | Python → `pip-audit`. Go → `govulncheck`. L1 → report only |
| 7 | List merged → delete → archive >30d → rebuild deep-memory | Protected → `grep -v "main\|develop\|release"`. No deep-memory → skip |

### Adding new loops

1. Identify repeated scenario (same structure 3+ times → belongs in library). 2. Pick mode (endpoint → `/goal`, monitors → `/loop`, event-driven → hook). 3. Write concrete kickoff (fill all brackets, no `[TBD]`). 4. Add variants (different stacks need different commands). 5. Test it (run on real task, fix if doesn't converge/monitor).

## Phased rollout (L1 → L2 → L3)

> Source: cobusgreyling/loop-engineering. Loops amplify judgment — good and bad. Unattended loops make unattended mistakes.

### The three levels

| Level | What the loop does | Human involvement | Readiness |
|-------|-------------------|-------------------|-----------|
| **L1 — Report-only** | Observe, analyze, report. No changes. | Human reads report, decides action. | ≥50 |
| **L2 — Assisted fixes** | Apply fixes, human approves before commit/push. | Human reviews each fix. | ≥70 |
| **L3 — Unattended** | Full autonomy: fix, commit, push, PR. | Human reviews after the fact. | ≥90 |

### Rollout rules

1. Start at L1. Always. No exceptions. Never ran L1 → cannot skip to L3. 2. L1→L2: ≥5 iterations, 0 harmful actions. 3. L2→L3: ≥10 iterations, 0 harmful actions reaching production. 4. Demotion: L3 harm → L2. L2 harm → L1. 5. Never skip levels. L1→L3 skip is a red line.

### What counts as "harmful"

Auto-fixing something not broken (false positive). Pushing code that fails CI. Deleting needed branch/file. Modifying protected file without approval. Spending >2x estimated token budget.

### Logging the level

Every kickoff must state: `Level: L1 (report-only) | L2 (assisted) | L3 (unattended)`. Log to `.windsurf/loop_state/<session_id>.md` and `.windsurf/session_state/<session_id>.json`. Track promotion/demotion history.

## Comprehension debt + Intent debt

> Source: cobusgreyling/loop-engineering. Two silent failure modes in long-running loops.

### Comprehension debt

- **What:** Human stops reading loop output. Nobody checks.
- **Signal:** Loop ran 20+ iterations, human hasn't read last 5 reports.
- **Defense:** Every 10 iterations → **summary diff** (delta, not full report). 3 unacknowledged → auto-demote one level. Log `comprehension_debt_risk: true`.

### Intent debt

- **What:** Loop drifts from original intent. "Fix tests" → now refactoring, updating deps, renaming.
- **Why:** Loops optimize for exit condition. "Tests pass" → will delete tests, comment out assertions.
- **Signal:** Actions don't map to GoalSpec. Diff includes unrelated changes.
- **Defense:** Every 10 iterations → re-check behavior vs GoalSpec. Not in GoalSpec → STOP, re-confirm. Signal 14. GoalSpec immutable during run — if intent changes, start new loop.

## Multi-session coordination

> Source: cobusgreyling/loop-engineering multi-loop concept. When 2+ sessions run simultaneously, they can conflict.

### Conflict types

| Conflict | What happens | Prevention |
|----------|-------------|------------|
| **File race** | Two sessions edit same file | Worktree isolation per session (`.windsurf/scripts/worktree.py --session <session_id>`) |
| **CI race** | Two sessions push same branch | One session per branch. Tag commits. |
| **Duplicate work** | Two sessions fix same issue | Shared `.windsurf/loop_state.md` registry with `active_sessions[]` |
| **Resource contention** | Two sessions run expensive commands | Stagger cadences. |

### Coordination protocol

1. **Register every session** before starting — `.windsurf/scripts/loop_memory_sync.py` writes the registry `.windsurf/loop_state.md` with `active_sessions: [{session_id, goal, status, tags, owned_files, last_heartbeat}]`.
2. **Check before starting.** Read `.windsurf/loop_state.md` registry. If another `active_session` owns `owned_files`/`affected_files` overlapping the new task, ask the human whether to wait, continue, or serialize. **Never auto-resume.**
3. **Worktree isolation.** Each session's parallel workers run in their own worktree (`.windsurf/scripts/worktree.py create --session <session_id> <worker_id>`). No session edits the main checkout directly.
4. **Deregister on exit.** When a session completes or crashes, `.windsurf/scripts/loop_memory_sync.py` updates the registry and archives the per-session file to `.windsurf/loop_state_archive/<session_id>.md`.
5. **Max 3 concurrent sessions.** More = resource contention + comprehension debt risk. Stagger cadences if needed.

### When sessions collide

1. STOP both sessions. 2. Compare outputs — which is correct, which is collateral? 3. Merge manually — human resolves, don't let the agent auto-resolve. 4. Restart with coordination — fix `active_sessions` in the registry, then restart.

## Loop-ifiability gate (3 conditions)

> Source: Wisely Chen's Loop Engineering implementation guide. Before building a loop, ask: *should this be looped at all?*

### The 3 conditions (all must pass)

| # | Condition | If it fails |
|---|-----------|-------------|
| 1 | **Auto-measurable metric?** Script/command can objectively score output? | No metric → cannot loop, OR loop only to "produce draft for human review" |
| 2 | **Failure cost controllable?** Can catch + revert mistakes cheaply? | Uncontrollable → human IN the loop (L2), not outside (L3) |
| 3 | **Harness hard enough?** State persistence, maker≠checker, stop conditions, red lines? | Not hard enough → fix harness first. |

### Decision tree

Task → auto-measurable metric? → No: don't loop (or loop only the "edge" — see Edge loop pattern). → Yes: failure cost controllable? → No: loop at L1/L2 only, human in the loop. → Yes: harness ready (Readiness Score ≥70)? → No: fix harness first. → Yes: safe to loop at L3 (unattended).

### Examples

| Task | Metric? | Failure cost? | Verdict |
|------|---------|---------------|---------|
| Fix bug until tests pass | ✅ | ✅ revert | L3 |
| Monitor CI + auto-fix | ✅ | ✅ revert | L2→L3 |
| Write blog post | ❌ | — | Don't loop writing. Loop edge (link/fact check). |
| Refactor "cleaner code" | ❌ subjective | ⚠️ break behavior | Don't loop. Human steers. |
| Update dependencies | ✅ audit | ⚠️ breaking | L2 (assisted). |

### The gate is mandatory

Before writing any loop kickoff, run the 3 conditions. If any fails: don't loop, loop only the edge, or fix the condition first. Skipping the gate = building a loop that amplifies problems.

## Cognitive surrender (human-side failure mode)

> Source: Boris Cherny's warning, via Wisely Chen's guide. Comprehension debt = stop reading output *after* it runs. Cognitive surrender = build loop *to avoid understanding* the work *before* it's built.

You build a loop not because the task is well-understood, but to avoid understanding it. Person A understands deeply → loop multiplies judgment. Person B doesn't → loop amplifies ignorance, producing confident output wrong in ways they can't detect.

**Observable signals:** Builder cannot explain correct output, cannot describe a failure mode the loop would miss, or says "let the loop figure it out" for a domain-knowledge decision.

**Defense (red line if detected):**
1. Builder must describe correct output + failure modes before building. Can't describe "good" → can't define exit condition.
2. Builder must review output for first N iterations — read and judge, not skim. Can't judge → don't understand domain → stop.
3. Cognitive surrender detected → stop. Human hasn't done the understanding work.

(See cross-cutting relationships for comprehension debt vs cognitive surrender.)

## Karpathy Loop (named pattern)

> Source: Karpathy's experiment design, via Wisely Chen's guide. Named pattern for autonomous research/optimization loops.

### The 3 elements

| # | Element | What it means |
|---|---------|---------------|
| 1 | **Agent with file modification access** | Read + write code/files, not just observe |
| 2 | **Auto-measurable metric** | Script/command objectively scores each iteration |
| 3 | **Fixed time limit per iteration** | Wall-clock cap. No open-ended runs. |

### The pattern

```
Start the "[NAME]" Karpathy-loop.
Agent: has read+write access to [files/dirs]
Metric: [command that outputs a number]  Time limit per iteration: [N min]
Max iterations: [N]  Budget cap: [N tokens]
Steps: (1) Read prior experiment log. (2) Generate hypothesis + code modification.
(3) Run experiment, capture metric score. (4) Write result to log.
(5) Metric improved → keep change; not → revert. (6) Check stop condition.
Convergence: 5 consecutive iterations, no metric improvement → STOP.
State: §State contract (with hypothesis + score + outcome)
Maker/checker: the metric script is the checker. Agent does not self-judge.
```

### When to use / NOT to use

- **Use:** Optimization with clear metric. Research with hypothesis generation. Parameter tuning.
- **NOT:** No auto-metric → Edge loop. Subjective output → human steers. Catastrophic failure → human in loop.
- **Agent swarm variant:** Karpathy's full vision = many loops in parallel, each informing others. Requires multi-loop coordination, shared experiment log, worktree isolation. **Start with one loop.** Scale to swarm only after single loop reliably converges.

## Edge loop pattern

> Source: Reddit user's workflow design, via Wisely Chen's guide. The *edges* of creative/judgment work — repetitive, verifiable parts before and after the human's creative core — can be looped safely.

### The pattern

`[Loop: Before human] → [Human: Creative core] → [Loop: After human]`. Before: gather candidates, de-duplicate, check sources, verify links → cleaned draft. Human: selection decisions, argument construction, narrative structure, final polish. After: verify output (links, formatting, cross-refs), run lint/test/build → validated final.

### When to use

No auto-metric for core (e.g., "is this a good argument?"). Verifiable edges (e.g., "are all links valid?"). Human's judgment is irreplaceable core.

### Examples

| Task | Before loop | Human core | After loop |
|------|-------------|------------|------------|
| Blog post | Gather research, check sources | Write argument | Check links, formatting |
| Architecture | Survey patterns, list constraints | Make decisions | Verify diagram consistency |
| Code review PR | Run lint/test/coverage | Judge architecture | Verify comments addressed |
| Marketing page | Gather assets, check copy length | Write messaging | Check layout, validate forms |

### Rules

1. **Human core is never looped.** Looping judgment = cognitive surrender.
2. **Before-loop produces draft, not final.** Human decides what to use.
3. **After-loop validates, doesn't create.** Checks output, doesn't generate.
4. **Both edges L1 by default.** Promote to L2 only after human trusts edge loop.

**Loop the edges. Keep the core human.**

## Proactive loop pattern (no human present, workflow generated on the spot)

> Source: Inside article (2026-07-14) on Loop Engineering, fourth type. The most automated of the four: trigger and done-decision both handed to the system, **and** the workflow itself is generated at trigger time. Distinct from hook-based variant (§"Hook-based variant") which fires a fixed prompt on a known event; proactive fires on unpredictable input and assembles the agents it needs.

### The pattern

A **routine** (long-running watcher) monitors a channel (GitHub issues, Slack, alert stream, PR queue). When something needs handling, the routine generates a fresh workflow on the spot:

```
[routine: watch channel]
   └─ event arrives (unpredictable content)
      └─ triage agent: classify + decide if action needed
         └─ fix agent: produce the change
            └─ adversarial review agent: attack the fix
               └─ passes → close task. Fails → back to fix (cap 2 rounds → escalate to human).
```

Three agents, three roles, **never the same agent across roles** (maker≠checker extended to triage≠fix≠review).

### Kickoff template

```
Start the "[NAME]" proactive-loop.
Routine: watch [channel: GitHub issues / Slack #channel / alert stream / PR queue]
Trigger: [observable condition that means "needs handling"]
Max concurrent tasks: [N]  Budget cap per task: [tokens]  Time limit per task: [wall-clock]
Max retries per task: 2  (3rd → escalate to human, do NOT keep retrying)

Per triggered task:
  Step 1 — Triage agent (fresh context): classify incoming event.
    Is action needed? What kind? What's the scope? Write triage result to state.
  Step 2 — Fix agent (fresh context, ≠ triage): produce change from triage result.
  Step 3 — Adversarial review agent (fresh context, ≠ fix): attack the fix.
    Try to break it. Find edge cases. Check it doesn't solve X by breaking Y.
    Pass → close task. Fail → back to Step 2 (count toward retry cap).
  Step 4 — Write outcome to .windsurf/loop_state/<session_id>.md and
    .windsurf/session_state/<session_id>.json, then call
    python .windsurf/scripts/loop_memory_sync.py to update the registry.

Exit per task: adversarial review passes OR retry cap hit (escalate).
Exit routine: user stops OR channel decommissioned.
State: §State contract (per task: triage result, fix diff, review verdict, retries)
Maker/checker: triage ≠ fix ≠ review. Three separate agents. No agent plays two roles.
```

### When to use / NOT to use

- **Use:** You can't predict what comes in, only that something will. Standing duty: PR queue, alert stream, issue triage, on-call bot.
- **NOT:** Predictable content → use `/loop` or `/schedule` with a fixed prompt (cheaper, simpler). Measurable endpoint → use `/goal`. Needs human judgment on each item → don't go proactive, stay turn-based or L1.

### Why adversarial review is the gate (not optional)

Proactive runs **while no human is watching**. Without an adversarial reviewer, errors compound silently — the article's core warning: "少了對抗式審查這類把關，主動式迴圈的錯誤也可能在無人盯場時被放大." The adversarial reviewer is the substitute for the human who would otherwise catch the mistake.

Adversarial ≠ lenient review. The reviewer's job is to **try to break the fix**, not to confirm it's fine. Concrete attacks:
- Does the fix solve the symptom by breaking something else? (grep for collateral damage)
- Does it pass the stated test but fail an adjacent one? (run the broader test suite)
- Does it hardcode what should be parameterized? (check for magic values)
- Does it match `knowledge_distill.md` anti-patterns? (grep state+knowledge)
- Does it touch files outside the triage scope? (diff vs triage result)

### Guardrails (mandatory — proactive without these is a red line)

1. **Retry cap = 2 per task.** 3rd failure → escalate to human. Never let a proactive loop retry indefinitely on one item — that's the "infinite loop burns API budget" failure mode, running 24/7.
2. **Budget cap per task.** Hit → escalate, don't silently continue.
3. **Time limit per task.** Wall-clock cap. Hit → escalate.
4. **Adversarial review is non-skippable.** No review = no close. "Looks fine" from the fix agent ≠ review.
5. **Three distinct agents.** Triage = fix = review (same agent) = self-approval = red line.
6. **Max concurrent tasks.** Unbounded concurrency = resource contention + comprehension debt. Default 3.
7. **Escalation queue.** Failed/capped tasks land in a human-readable queue, not silently dropped. Human reviews the queue periodically (this is where comprehension debt lives — see §"Comprehension debt").
8. **State write per task.** Every triggered task writes state. No state = next routine iteration can't tell what was handled.

### Relationship to other patterns

- **vs Hook-based variant (§"Hook-based variant"):** Hook fires a *fixed* prompt on a *known* event (afterEdit → run tests). Proactive fires on *unpredictable* content and *generates* the workflow. Hook = known event, fixed response. Proactive = unknown event, generated response.
- **vs Entropy sweep (§"Entropy Management"):** Sweep is time-based (cadence) scanning for drift. Proactive is event-based responding to incoming work. Both can run together: sweep handles internal drift, proactive handles external events.
- **vs Harness gap loop (§"Harness Gap Loop"):** Gap loop is reactive to a *specific* regression. Proactive is reactive to *any* incoming event. Gap loop closes one gap; proactive handles a stream.
- **vs Edge loop (§"Edge loop pattern"):** Edge loop wraps a human core (before/after). Proactive has no human in the per-task loop — the adversarial reviewer *replaces* the human. This is exactly why the adversarial reviewer must be real, not ceremonial.

### L-level constraint

Proactive loops are **L3 (unattended) by definition** — no human present per task. Per §"Phased rollout," L3 requires Readiness Score ≥90 and prior L1→L2→L3 progression. Do **not** deploy a proactive loop on a harness that hasn't earned L3. A proactive loop on a soft harness = unattended mistakes at scale, 24/7.

### Cognitive surrender check (extra, proactive-specific)

Before deploying a proactive loop, the builder must answer:
1. For each plausible incoming event type, what does correct handling look like?
2. What's a failure mode the adversarial reviewer would miss?
3. What's the escalation criteria — when does the routine give up on a task?

Can't answer → cognitive surrender (§"Cognitive surrender"). You're building the loop to avoid understanding the work. Stop. Do the understanding first.

## Entropy Management (background sweep)

> Source: OpenAI's Harness Engineering blog, via Wisely Chen's guide. Agents replicate existing patterns — including bad ones. Without a background sweep, entropy accumulates and hardens.

### The defense: background sweep loop

A dedicated `/loop` that periodically: (1) scans for pattern drift, (2) updates quality scores, (3) opens refactor PRs. Cadence: [e.g. every 24 hours]. Max iterations: [1 per run]. Time limit: [30 min per run]. Steps: scan repo for anti-patterns → score each module (clean/drift/degraded) → drift: open refactor PR (L2), degraded: flag in `knowledge_distill.md` + escalate → write sweep results to `.windsurf/loop_state/<session_id>.md` and `.windsurf/session_state/<session_id>.json`, then call `python .windsurf/scripts/loop_memory_sync.py` to update the registry. Exit when: sweep complete. State: §State contract (with sweep results).

### Entropy accumulation chain

Without sweep: anti-pattern in A → replicated to B → C, D → becomes "the convention" → refactoring requires breaking 4+ modules. With sweep: anti-pattern in A → sweep detects within 24h → refactor PR for A only → fixed before it spreads.

### Rules

- **Every repo with daily agent output needs entropy sweep.** Weekly min, daily preferred.
- **Sweep is L2 (assisted).** Human reviews refactor PR before merge.
- **Degraded modules escalate to human.** Don't auto-fix deeply degraded — fix might add entropy.
- **Track quality scores.** Dropping score needs architectural attention, not just refactor.

## Harness Gap Loop (regression → test case → SLA)

> Source: Ryan Carson's Control-Plane Pattern, via Wisely Chen's guide. Every production regression is a harness gap to close. Without this loop, same regression repeats; with it, harness grows stronger.

### The principle

`production regression → harness gap issue → test case added → SLA tracked`. 1. Regression occurs. 2. Open harness gap issue ("why didn't harness catch it?"). 3. Add test case from reproduction conditions. 4. Add to harness (CI/benchmark). 5. Track SLA.

### The loop

```
Start the "Harness Gap Closure" goal-loop (triggered by production regression).
Goal: regression fixed AND test case exists that would have caught it
Max iterations: [5]  Budget cap: [30K tokens]  Time limit: [2 hours]
Steps: (1) Reproduce regression, confirm. (2) Fix regression. (3) Write test case
that fails on pre-fix, passes on post-fix. (4) Add to security benchmark.
(5) Open harness gap issue: what happened, why harness missed it, test added.
(6) Track SLA: time from regression → test added.
Exit when: fix merged AND test case in CI AND harness gap issue closed.
State: §State contract
```

### SLA tracking

| Metric | Target |
|--------|--------|
| Regression → issue opened | < 1 hour |
| Issue → test case added | < 24 hours |
| Test added → running in CI | < 1 hour |
| Recurring regressions (same root cause) | 0 |

### Rules

- **Every regression opens a harness gap issue.** No exceptions. "Small bug" not an excuse.
- **Fix not complete until test case in CI.** Fix without test = patch, not fix.
- **Track SLA over time.** Growing SLA = gap loop degrading.
- **Recurring regressions = red line.** Same root cause recurs → gap loop failed. Escalate.

## PRD iteration principle (spec is never done on first pass)

> Source: Wisely Chen's ATPM QA articles. First-pass requirement accuracy is 60-80%. 30-40% found wrong in Dev, another 30-40% in QA. Spec must be iterable.

Traditional: PRD (fixed) → Code (expensive) → QA (expensive). AI-era: PRD (iterable) → Code (regenerated) → QA (regenerated from PRD).

### The iteration loop

```
Start the "PRD Iteration" goal-loop.
Goal: PRD accurately reflects what user actually wants (verified by working code)
Max iterations: [5]  Budget cap: [40K tokens]  Time limit: [4 hours]
Steps: (1) Write initial PRD from user request (accept 60-80% accuracy).
(2) Generate code from PRD, run it. (3) Compare output vs user intent — diverge?
(4) Divergence = PRD gap, not code bug. Update PRD. (5) Regenerate code + QA.
(6) Repeat until user confirms "yes, this is what I want."
Exit when: user confirms PRD matches intent AND code passes QA derived from PRD.
State: §State contract
```

### Rules

- **GoalSpec is a draft, not a contract.** Expect change. Design loop to accommodate.
- **Code generation is spec validation.** Generate early, run early, find PRD gaps early.
- **When code is wrong, check PRD first.** If PRD wrong, "correct" code is still wrong.
- **QA regenerated from PRD, not manually maintained.** When PRD changes, regenerate QA.
- **User confirmation is exit condition, not "all tests pass."** If PRD doesn't match intent, passing tests = false confidence.
- **"通靈" (mind-reading) is not a skill.** Harness must accommodate ambiguous, evolving specs.

## Throughput changes merge philosophy

> Source: deusyu/harness-engineering, based on OpenAI's Harness Engineering article. When agent throughput far exceeds human attention, norms invert: **error correction becomes cheap; waiting becomes expensive.**

Traditional: human time expensive + low throughput → careful review → many gates. Harness: agent time cheap + high throughput → fast iteration fixes errors → few gates.

Prerequisite: **sufficient back-pressure** (tests, lint, structural checks) must exist. Without them, "fast iteration" = "fast rot."

### What changes

- **PR lifecycle shortens:** Small, fast-flowing changes. Optimize for flow + fix, not review beauty.
- **Merge gates minimize:** Flaky tests → retry, don't block. Gate is CI/lint/test, not human review.
- **Agent reviews agent:** Most reviews agent-to-agent (maker≠checker still applies). Human reviews summary, not every PR.

### Rules

- **Don't apply low-throughput norms to high-throughput.** Gates at 5 PRs/week wrong at 50.
- **Back-pressure is prerequisite.** Fast merge without tests/lint = fast rot.
- **Flaky tests → retry, not block.** Track flakiness — rising rate = regression.
- **Agent-to-agent review valid.** Human reviews summary + escalated disagreements.
- **Optimize for iteration speed, not first-time success.** Fast discovery + fix > slow first attempt.
- **Cheap models for subtasks, expensive for orchestration.** Sonnet/Haiku for work, Opus for planning.

## Cross-cutting relationships

| Principle | Relationship |
|-----------|-------------|
| Comprehension debt vs Cognitive surrender | Both silent, degrade quality. Debt = stop reading after loop runs; Surrender = build loop to avoid understanding. |
| Entropy sweep vs Harness gap loop | Both needed. Sweep = proactive (find drift). Gap loop = reactive (close gap). Together: harness grows stronger. |
| Warning signals (1-10) vs F.R.E. (11-13) | Reactive vs proactive. Same signal table. Signals = harness health; F.R.E. = model cognition. |
| Maker≠checker (VERIFICATION_PROTOCOL) | Agent-to-agent review valid if maker ≠ checker. |
| Entropy + Throughput | High throughput = more entropy. Sweep cadence must match throughput. |
| Convergence + Throughput | "Retry flaky tests" = convergence strategy. Track retry rate. |
| Bottleneck shift (VERIFICATION_PROTOCOL) | Throughput shifted bottleneck to merging/verifying. PRD iteration = spec side; throughput = merging side. |
| PRD iteration + Cognitive surrender | Not iterating PRD = accepting first guess = surrender. |
| PRD iteration + Loop-ifiability gate | PRD iteration is a `/goal` loop: run until user confirms. |
| PRD iteration + Start small (VERIFICATION_PROTOCOL) | Start with rough PRD + 1 test case. Iterate both. |
| Proactive loop + Cognitive surrender | Proactive runs unattended — cognitive surrender risk is highest here. Extra pre-deploy check mandatory. |
| Proactive loop + Comprehension debt | No human per task → escalation queue is where comprehension debt hides. Periodic queue review non-skippable. |
| Proactive loop + Maker≠checker | Extended to triage ≠ fix ≠ review. Three roles, three agents. |
| Four types + Loop-ifiability gate | The gate runs before any of the four types. Type choice is downstream of "should this loop at all?" |

## The deepest trap

> "Two people can build the exact same loop and get opposite results. One uses it to run
> faster on work they deeply understand. The other uses it to avoid understanding the work."

When you design a loop with judgment, it's medicine. When you design it to save thinking,
it's an accelerator — for the problem, not the solution. The loop can't tell the difference.
You can.

## Source references

- Addy Osmani / Boris Cherny / Karpathy autoresearch — Loop Engineering concept.
- Anthropic, "Getting started with loops" (2026-07-07) — official 4-type framework (turn/goal/time/proactive), evaluator-as-smaller-model, cadence-matches-change-rate, deterministic-work-to-script, turn-based+Skills.
- Inside article (2026-07-14), "Loop engineering 是什麼？四種迴圈決定你要盯 AI 代理多緊" — four-type handoff 2×2 framework (turn-based / goal-based / time-based / proactive), `/schedule` cloud vs `/loop` local distinction, adversarial review as proactive gate.
- aiposthub.com (2026-07-13), "Claude Code 官方把 AI Agent 拆成 4 種循環" — operator-level details: evaluator = smaller/faster model, over-polling cost, deterministic work → script, turn-based + SKILL.md as cheapest upgrade.
- loops.elorm.xyz — loop primitives + pre-built loop collection.
- cobusgreyling/loop-engineering — loop-audit, phased rollout (L1→L2→L3), comprehension/intent debt.
- govin999999 Threads (Loopkit Vault) — vault pattern.
- oh-my-openagent's Todo Enforcer (Sisyphus Labs) — idle-yank protocol.
- community Fable 5 harness-building prompt — failure reverse-engineering concept.
