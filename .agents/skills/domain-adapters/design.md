---
name: design-adapter
domain: design-ux
applies_when: "Task produces a design spec, a UX flow, a component spec, or a design-system contribution."
boundary: "Visual/aesthetic judgment (is this beautiful?) = honest-clause limit, escalate. Spec/flow/system contribution = this adapter."
---

# Design / UX Adapter

## Minimum evidence set (binding — open before specifying)
- The design system / component library (existing tokens, components, patterns) — the actual files.
- The user flow / journey map / research findings the design serves.
- The accessibility requirements (WCAG level, target devices, assistive tech).
- The existing component's API/props if extending (don't break consumers).

## Evidence and primary sources
The design system files (tokens, components, patterns), user research findings, and accessibility
criteria (WCAG references). The signature non-evidence: "users want X" stated with no research
finding behind it — it is a stakeholder opinion wearing research's clothes.

## Authority
User research > design system > accessibility requirements > stakeholder preference > aesthetic
trend. The classic conflict: a stakeholder wants a visual that breaks the design system or a11y;
the system/a11y wins, and the conflict is surfaced as a decision, not silently absorbed.

## Verification by observation
- The spec references actual design-system tokens/components by name; grep confirms they exist.
- Each flow decision traces to a research finding, or is explicitly labeled as an assumption.
- A11y requirements are stated as specific WCAG criteria; the spec meets each (contrast ratio, focus
  management, semantic HTML, keyboard nav).
- A new/changed component's API is checked against existing consumers (grep call sites); breaks are
  flagged, not silent.

## Fraud table
| fraud | signal |
|------|--------|
| Token not in the system | spec uses a color/spacing value not defined in the design system |
| Flow without research basis | "users want..." with no cited research finding |
| A11y claim unverified | "accessible" with no WCAG criteria stated or checked |
| Breaking change | new component API; existing consumers not grep-checked |
| Aesthetic-as-spec | "it should feel premium" with no observable token or layout translation |
| Silent system override | spec contradicts design system without naming the conflict |

## Done, by example
"The checkout flow spec is done" means: every token grep-confirmed in the design system, every
flow decision sourced to research or labeled as assumption, WCAG criteria stated and met, and
consumer break-checks run. Not: "the flow looks good."

## Workflow
1. Open design system + research + a11y reqs + existing API (binding).
2. Specify using existing tokens/components; cite research per flow decision.
3. State a11y criteria; verify the spec meets each.
4. fable-judge pass: grep tokens; verify research citations; check a11y; grep consumers for API breaks.

## Sources
- design system: <path>
- research: <finding doc> (accessed <date>)
- a11y: <WCAG ref + level>
