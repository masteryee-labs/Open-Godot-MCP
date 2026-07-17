---
name: research-adapter
domain: research
applies_when: "Task produces a report, literature review, competitive analysis, or any synthesis of external sources."
boundary: "Education content uses this. Original data analysis → data adapter. Legal compliance research → legal adapter."
---

# Research Adapter

## Minimum evidence set (binding — open before synthesizing)
- Primary sources for every load-bearing claim (paper, official doc, dataset) — fetched, not recalled.
- Publication dates of each source (a 2018 claim cited as current = fraud).
- The actual methodology section when citing a study's result (not just the abstract).

## Evidence and primary sources
Peer-reviewed primary sources, official reports, datasets, and the actual methodology sections of
studies. The signature non-evidence: an abstract-only citation — quoting a study's result from the
abstract without reading whether the methodology supports the scope of the claim.

## Authority
Peer-reviewed primary source > official report > reputable secondary > blog/opinion. A secondary
source summarizing a primary does not replace reading the primary for load-bearing claims. The
classic conflict: a famous secondary summary contradicts the primary's actual findings; the
primary wins, and the report names the discrepancy.

## Verification by observation
- Every claim in the report traces to a fetched source with URL + access date + quote.
- Re-fetch at least one source to confirm it says what the report claims.
- Spot-check the oldest and the most-load-bearing citations.
- Publication dates are stated; a pre-2020 stat presented as current is flagged or updated.

## Fraud table
| fraud | signal |
|------|--------|
| Cited source doesn't say that | quote attributed to a paper; re-fetch and the quote is not in the text |
| Stale-as-current | a 2018 stat presented as present state without date label |
| Abstract-only citation | study result cited without reading methodology; scope mismatch |
| Cherry-picked | one favorable study among many; counter-evidence not reported |
| Fabricated citation | source URL 404s or doesn't exist; DOI doesn't resolve |
| Missing gap | report presents a synthesis with no "what we could not find" section |

## Done, by example
"The competitive landscape report is done" means: every claim sourced with URL + date + quote, at
least one source re-fetched and verified, gaps explicitly named, and the oldest citation
date-checked. Not: "the report covers the main players."

## Workflow
1. Enumerate what exists (search, glob the literature) before reading specifics.
2. Fetch primary sources in parallel; record URL + date + quote per claim.
3. Synthesize with every claim sourced; note gaps explicitly.
4. fable-judge pass: re-fetch ≥1 source, verify quote; check every citation resolves.

## Sources
- <claim>: <url> (accessed <date>, quote: "...")
