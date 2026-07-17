# Domain Adapter Template

> Source: Sahir619/fable-method (MIT), `references/domains/TEMPLATE.md`. Distilled 2026-07-17.
> Schema for sector adapters. An adapter changes only the **nouns**, never the loop
> (`.agents/canon/LOOP_PROTOCOL.md`, fable-method 7-step). It defines: what counts as evidence,
> who the authority is, what verification-by-observation means, and what the frauds are.
> Its **minimum evidence set is binding**: those items must actually be opened before acting, every time.

## When to use an adapter
The default domain is **coding** (files, tracebacks, the spec is authority). Load a sector adapter
only when the task's evidence/authority/frauds genuinely differ from coding. If they don't, the
coding default already covers it — do not generate a duplicate. (Scope stop, per fable-domain
Stage 1.)

## Red-line domains (no adapter, route to qualified human)
If the domain requires professional licensure or a wrong answer causes physical/legal/financial
harm — medical/clinical, legal advice (≠ compliance research), specific financial buy/sell advice
(≠ analysis), mental health, safety-critical engineering — **refuse the checklist and route to a
qualified human.** A smoke eval cannot catch advice that gets someone hurt or sued.

## Schema (keep section headers exact — tooling greps them)

```markdown
---
name: <sector>-adapter
domain: <sector>
applies_when: <one sentence: when this adapter loads>
boundary: <one sentence: nearest adapter or coding default, and which side takes over when>
---

# <Sector> Adapter

## Applies when
<one sentence>

## Boundary
<one sentence vs coding default or nearest adapter>

## Minimum evidence set (binding — must open before acting)
- <item 1>: <what to open, and what to do when it does not exist>
- <item 2>: <what to open>
- <one live external reference fetched now, not recalled>

## Evidence and primary sources
<2-3 sentences: what counts as a primary source here, and the sector's signature
non-evidence — the thing that looks like evidence but is decoration.>

## Authority
<ordered chain using ">", from explicit user/client instruction down to your own
preference or memory. Then one sentence: the sector's classic conflict and which side wins.>

## Verification by observation
<3-5 bullets. Each: what "observed" means for this sector's claims — checks that must
actually be run or opened, exactness requirements (names, prices, dates, versions).
Include the sector's equivalent of "rendered surfaces are actually rendered and looked at".>

## Fraud table (hunt these with fable-judge)
| fraud | signal |
|------|--------|
| <6-7 rows. Name each fraud in 2-3 words> | <observable symptom a judge can hunt by diffing, re-running, or re-fetching> |

## Done, by example
"<A typical deliverable> is done" means: <the observed checklist in one sentence>.
Not: "<the sector's classic hollow claim>".

## Workflow (the ordered steps for this domain)
1. <step — name what to open, produce, or check>
2. <step>
...

## Sources
- <claim>: <url or file> (accessed <date>)
```

## Rule
- **Adapter changes nouns, never the loop.** The 7-step loop (classify → define done → evidence →
  decide → act → verify → report) is invariant.
- **Minimum evidence set is binding.** Those items must be opened, every time, before acting.
  Research is never optional; the adapter defines how much is enough.
- **"Evidence and primary sources" names the signature non-evidence.** Every domain has a thing
  that looks like evidence but is decoration (devops: green pipeline; marketing: unsourced stat;
  research: abstract-only citation). fable-judge hunts it.
- **"Done, by example" is the per-domain anti-fake-done.** The "Not:" clause names the hollow
  claim fable-judge should flag. Without it, "done" is uncalibrated per domain.
- **Fraud table is what fable-judge hunts.** 6-7 rows, each a observable symptom. Not exhaustive —
  the domain's classic frauds, not every possible one.
- **Sources carry access dates.** A named regulation/policy/figure without a fetched source =
  memory, unverified. No web access → no trustworthy adapter (fable-domain Stage 2 stop).
- **One adapter per dispatch.** Keep context lean. Sales/support = marketing + business-ops (load
  both only if the task spans both).
