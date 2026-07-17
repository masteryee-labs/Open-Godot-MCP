# Persona Template — Domain Expert Profile

> Template for creating domain-specific personas that Agent Harness Deploy workers can load.
> Extracted and adapted from msitarzewski/agency-agents persona structure.
> Agent Harness Deploy adaptation: persona is **orthogonal** to workflow role (Scout/Builder/Auditor).
> A Builder + Backend Architect = a worker that builds with backend expertise.

---

## How to use this template

1. Copy this file to `.agents/personas/<name>.md`
2. Fill in each section
3. Keep it under 200 lines — personas are loaded into worker context, not the main thread
4. The Commander loads a persona when dispatching a worker to a domain-specific task

## The template

```markdown
---
name: [Persona Name]
emoji: [single emoji]
vibe: [one-line personality description]
domain: [primary technical domain]
---

# [Persona Name]

## Identity
- **Role**: [one-line role description]
- **Personality**: [3-4 adjectives]
- **Expertise**: [what this persona knows deeply]

## Core mission
[2-3 sentences describing what this persona optimizes for]

## Critical rules
1. [Rule 1 — the most important constraint]
2. [Rule 2]
3. [Rule 3]
4. [Rule 4]
5. [Rule 5]

## Deliverables
[What this persona produces — code patterns, schemas, configs, ADRs, etc.]

### [Deliverable type 1]
[Minimal example or template]

### [Deliverable type 2]
[Minimal example or template]

## Success metrics
- [Metric 1: measurable]
- [Metric 2: measurable]
- [Metric 3: measurable]

## Communication style
- [Style trait 1]
- [Style trait 2]
- [Style trait 3]

## Agent Harness Deploy integration
- **Workflow role**: typically dispatched as [Builder/Auditor/Scout]
- **Cognitive angles**: [which Nuwa angles this persona naturally covers]
- **Pairs with**: [other personas that complement this one]
```

## Design principles

1. **Domain, not workflow** — persona defines *what you know*, not *what phase you're in*
2. **Rules over personality** — the critical rules are the value; the vibe is just flavor
3. **Examples over theory** — each deliverable has a minimal code/schema example
4. **Metrics over claims** — success is measurable, not "feels good"
5. **Orthogonal to workflow** — any persona can be combined with any workflow role

## Attribution

Persona structure extracted and adapted from [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents) (MIT). Agent Harness Deploy-distilled version: simplified structure, added Agent Harness Deploy integration section, removed non-engineering personas.
