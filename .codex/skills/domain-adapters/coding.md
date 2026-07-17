---
name: coding-adapter
domain: coding
applies_when: "The task touches code, tests, build, or config — the default domain."
boundary: "This IS the default. Load a sector adapter only when evidence/authority/frauds differ from this."
---

# Coding Adapter (the default)

> The base domain. Listed for completeness and as the reference point other adapters diverge from.
> No separate load needed — the loop runs on this by default.

## Minimum evidence set (binding)
- The code being changed (read the actual function/region, not recall).
- The check that's failing or the spec being satisfied (test file, README, docstring, type).
- For library APIs: current docs (context7 if available, else official docs page or installed source).

## Evidence and primary sources
The actual code, the failing check's output, the spec text (README/docstring/type) are primary
sources. The signature non-evidence: reading the code and nodding "looks right" without running
the check — code-reading is inference, not observation.

## Authority
Explicit user statement > spec (README/docs/docstring) > tests > current code behavior.
A task framing ("fix the code", "make tests pass") is NOT a statement of intended behavior.
The classic conflict: the test says one thing, the spec says another; the spec wins, and the
fix targets whichever side actually disagrees with the spec, named explicitly.

## Verification by observation
- The test/build/lint runs and the output is shown, not inferred from reading the code.
- A green targeted check with a broken build = failed verification, not passed.
- Read-back of the changed span confirms the edit landed (anti false-completion).
- The surrounding system still works: existing tests for the touched area pass, not just the new one.

## Fraud table
| fraud | signal |
|------|--------|
| Weakened test | test file changed in a fix commit; assertion loosened, deleted, mocked, or expected value shifted to match new behavior |
| False completion | "all pass" with no run shown; "should work now"; success language on a failure transcript |
| Spec betrayal | code changed to satisfy a check that contradicts README/spec/docstring |
| Scope creep | diff beyond ask's blast radius; drive-by refactors, reformatting, new deps |
| Debris | scratch files, debug prints, commented-out code, orphaned imports |
| Invented API | code calls an endpoint/signature not opened this session, unlabeled | 
| Missed twins | defect fixed in one spot; no project-wide search for the same construct |

## Done, by example
"The date test is fixed" means: the test passes (output shown), the full suite stays green, the
fix touched only the function that dropped timezones, and a TWINS search for the same pattern was
run. Not: "the test passes now."

## Workflow
The 7-step loop as-is. No domain-specific steps.

## Sources
N/A — this is the default.
