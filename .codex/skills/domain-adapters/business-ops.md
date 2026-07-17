---
name: business-ops-adapter
domain: business-ops
applies_when: "Task defines a process, an SOP, an ops runbook, a vendor evaluation, or an internal workflow."
boundary: "Sales/support = this plus marketing. Finance/budget figures → finance adapter. Live infra changes → devops adapter."
---

# Business / Ops Adapter

## Minimum evidence set (binding — open before proposing a process)
- The current-state process (interview, doc, or observation) — not the assumed state.
- The stakeholders and their actual authority/decision rights.
- Any existing SOP/policy that governs this area.
- The constraint set (budget, headcount, tooling, regulatory).

## Evidence and primary sources
The current-state process (interview notes, existing docs, direct observation), the stakeholders'
actual decision rights, and existing SOPs/policies. The signature non-evidence: "industry best
practice" cited without a source — it is opinion wearing a suit.

## Authority
Documented policy > stakeholder with decision authority > general best-practice. The classic
conflict: a stakeholder wants a step that violates existing policy; policy wins, and the gap is
surfaced as a decision the stakeholder must escalate, not silently overridden.

## Verification by observation
- The proposed process maps 1:1 to the current-state evidence; each step traces to a real observation.
- Each step's owner is a named person who exists and has the authority for that decision.
- Each step's required resources (tool, headcount, budget) are within the stated constraint set.
- A step that no one owns or no one funded = a gap, flagged, not papered over.

## Fraud table
| fraud | signal |
|------|--------|
| Process for a non-existent role | step owned by "the team" with no named individual |
| Best-practice without source | "industry standard says..." with no citation |
| Ignored current state | proposed process assumes a state that was never verified |
| Unfunded mandate | step requires tool/headcount not in the constraint set |
| Authority gap | step needs a decision no listed stakeholder can make |
| Silent policy override | step contradicts existing SOP without naming the conflict |

## Done, by example
"The onboarding SOP is done" means: every step has a named owner with authority, every step is
funded within constraints, every policy conflict surfaced, and the current-state mapped before
proposing the to-be. Not: "the process is documented."

## Workflow
1. Open current-state evidence + stakeholders + existing policy + constraints (binding).
2. Map the current process as-is; note gaps.
3. Propose the to-be process; each step owned + funded + within authority.
4. fable-judge pass: re-verify each owner exists, each step is funded, each policy reference is real.

## Sources
- current-state: <doc or interview notes> (accessed <date>)
- policy: <doc path>
