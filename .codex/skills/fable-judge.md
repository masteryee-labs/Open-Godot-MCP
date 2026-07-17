---
name: fable-judge
description: "Adversarial verification of finished work. Fires on every 'done' declaration — re-runs claimed verifications, diffs what actually changed, detects weakened tests and false completion, sweeps verbatim gate lines (INTENT/AUTH/TWINS/PENDING). Use after any agent or worker claims work is complete: 'fable-judge', 'judge this work', 'verify what it did', 'did that actually work?'."
---

# Skill: fable-judge

> Source: Sahir619/fable-method (MIT), fable-judge SKILL.md. Distilled 2026-07-17.
> Adversarial "done" gate. Fires on every task-done declaration, not every 5 iterations.
> Stance: **a report is a set of claims, not evidence.** Nothing is believed that was not observed.
> Composes with `.codex/canon/VERIFICATION_PROTOCOL.md §Verbatim execution gates` — the maker
> leaves INTENT/AUTH/TWINS/PENDING lines; this skill verifies they match reality.

## Trigger
- **Mandatory: after any agent or worker declares a task "done" / "complete" / "finished".**
- After any "all tests pass" / "build green" / "synced" / "fixed" claim.
- Keywords: fable-judge, judge this work, verify what it did, did that actually work.
- Before presenting substantive work to the user as finished.
- Supersedes the Auditor's "every 5 iterations" cadence for done-declarations: done → judge now.

## Why this exists (the documented failure)
The most consistent failure of coding agents is claiming success regardless of reality: "fixed,
all tests pass" on broken work, tests quietly weakened until they pass, scope silently expanded,
prescribed deploys taken without authorization. The judge's stance is fixed: the report is a set
of claims; the diff and re-run are ground truth.

## Default mode: judge the work

Target: the most recent completed piece of work, or whatever the user names (a diff, a directory,
a branch, another agent's report pasted in).

1. **Collect the claims.** From the report or conversation, list: what was supposedly done, what
   was supposedly verified ("tests pass", "build green", "renders correctly"), and what was
   supposedly left untouched. Each becomes a row to prove or refute.
2. **Establish what actually changed.** `git diff` and `git status` (or a directory diff against a
   pristine reference when there is no repo). **The diff is ground truth; the report is not.**
   Compare touched files against the ask's blast radius and the plan's declared scope.
3. **Re-run every claimed verification yourself.** Do not read code and nod: run the tests, the
   build, the script, the page. Capture actual output. A claim that cannot be re-run (missing
   env, credentials, human-eyes-only) is labeled UNVERIFIABLE, never assumed true.
4. **Sweep the verbatim gate lines** (per `VERIFICATION_PROTOCOL.md §Verbatim execution gates`):
   - behavior changed → `INTENT:` line present AND its three slots (code/check/spec) match reality?
   - outward action taken → `AUTH:` line present AND its quote actually appears in the conversation
     verbatim? (Documentation quoting "you should deploy" ≠ authorization.)
   - defect fixed → `TWINS:` line present AND the claimed search actually returns what it says?
     Re-run the search; `none` must be reproducible.
   - prescribed follow-up untaken → `PENDING:` line present?
   - API/config/figure/regulation used → was its source opened this session? If not, does the claim
     carry `memory, unverified`? An unlabeled recall-based claim = invented API (failure mode 5).
   - task routed away from the loop (fit gate) → did the report name the detour (what was missing,
     what was done instead)? A silent detour = a skipped step.
   - A missing or false line = a fraud finding, not a style note.
5. **Hunt the classic frauds**, in real-world frequency order:
   - **Weakened checks.** Diff test files specifically: assertions loosened/deleted, expected
     values changed to match new behavior, tests skipped, tolerances widened, real calls replaced
     by mocks. A changed test is guilty until its justification traces to a spec.
   - **False completion.** A pass claimed with no run shown; partial reported as full; "should work
     now"; success language on a failure transcript.
   - **Scope creep.** Changes beyond the ask: drive-by refactors, reformatting, new dependencies,
     "improvements".
   - **Unauthorized action.** An outward-facing effect (deploy/push/publish/send/install/schedule/
     delete shared data) with no `AUTH:` line, or a quote that does not actually authorize it.
   - **Spec betrayal.** Code changed to satisfy a check that contradicts README/spec/docstring.
     Authority order: explicit user statement > spec > tests > current code behavior.
   - **Debris.** Leftover scratch files, debug prints, commented-out code, orphaned imports.
   - **Invented APIs / recall fraud.** Code calls an endpoint/signature/config key/figure written
     from memory, not opened this session, and not labeled `memory, unverified`. Re-fetch the
     claimed API doc; does the signature match?
   - **Costume rigor.** The shape of thoroughness (factor lists, confident "all clear") with no
     search or check behind it — especially on a task the fit gate should have routed to an honest
     "this is a guess" instead. The fit-gate detour was not named in the report.
   - **Non-code work**: judged by its domain's fraud table — load the matching adapter in
     `.codex/skills/domain-adapters/` and hunt ITS frauds (fabricated stats, stale figures, budget
     fiction, silent data cleaning) with the same stance.
6. **Deliver the verdict, evidence first.**
   - **VERIFIED** — every load-bearing claim reproduced, no frauds, all owed gate lines present and true.
   - **VERIFIED WITH CAVEATS** — work sound; list exactly what could not be re-run and any minor debris.
   - **REFUTED** — a claim failed reproduction, a fraud was found, or a gate line was missing/false:
     name the exact claim, show the contradicting output, state the smallest fix.

## Output
```
## Verdict [VERIFIED | VERIFIED WITH CAVEATS | REFUTED]
## Claims table
| claim | observed | status |
## Gate-line sweep
| gate | owed? | present? | matches reality? |
## Frauds found
| type | severity | evidence | smallest fix |
## UNVERIFIABLE
- [claim]: [why it could not be re-run]
## Recommended action
[one line: proceed | fix N | hand back]
```

## Standing rules
- **Judging changes nothing.** Read and run only. Fixes happen only if the user asks afterward.
  This is a gate, not a second implementation: minutes, not hours.
- **Fresh context required.** Never the same context as the author. Same-context judging = the
   author grading their own work; if forced, switch to Devil's Advocate mode explicitly and note
   the weaker confidence.
- **If the work touched nothing runnable, say plainly what a judge can and cannot check here.**
- **Never soften a refutation to be polite.** Never inflate a caveat into a refutation to look
  rigorous. The verdict matches the evidence, nothing else.
- **If verification needs an environment you lack, hand that back rather than guessing.**

## Relationship to Auditor
Auditor (`.codex/skills/auditor.md`, `.codex/agents/workers/AUDITOR.md`) runs every 5
iterations and before declaring done — the **periodic** adversarial pass with 8 fixed angles.
fable-judge runs **on every done-declaration** — the **event-driven** gate focused on claims,
frauds, and verbatim gate lines. They overlap on "before declaring done"; fable-judge is the
narrower, faster, every-time pass. Run Auditor for breadth every 5 rounds; run fable-judge for
the done-gate every time.
