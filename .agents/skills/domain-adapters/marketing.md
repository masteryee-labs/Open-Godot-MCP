---
name: marketing-adapter
domain: marketing
applies_when: "Task produces marketing copy, brand content, landing page text, ad creative, or sales collateral."
boundary: "Sales/support tasks load this plus business-ops. Pure analytics of campaign data → data adapter."
---

# Marketing Adapter

## Minimum evidence set (binding — open before writing copy)
- `brand.md` / brand guidelines / voice & tone doc — the actual rules, not recall.
- Product facts file (pricing, features, specs, dates) — current values, fetched now.
- The target audience definition / persona doc.
- Any regulatory constraints on the claim (e.g. "no unsubstantiated health claims").

## Evidence and primary sources
Audience data, the brand's published materials, real competitor pages, current platform policies
(ad rules, email regulations), and verifiable market figures. The signature non-evidence: a
statistic without a source you actually opened — it is decoration, not evidence.

## Authority
Explicit client/user instruction > brand guidelines (`brand.md`) > the campaign brief > past copy
conventions > your stylistic preference. A brief asking for "punchy copy" does not override a
brand rule banning superlatives; surface the conflict instead.

## Verification by observation
- Every factual claim in the copy traces to a source you opened (product docs, a fetched page, a
  stated figure). Claims you could not verify are removed or explicitly flagged, never left as fact.
- The copy is checked line-by-line against the brand rules: tone, banned words, formatting, disclaimers.
- Names, prices, dates, and titles are exact. One wrong competitor price discredits the whole piece.
- Rendered surfaces (landing pages, emails) are actually rendered and looked at, not assumed.

## Fraud table
| fraud | signal |
|------|--------|
| Fabricated statistics | figures, percentages, or "studies show" with no source that exists |
| Fake social proof | invented testimonials, awards, review scores, client names, or user counts |
| Spec betrayal | copy violating written brand rules while claimed "on brand" |
| Unverifiable superlatives | "#1", "best", "fastest", "guaranteed" with nothing behind them |
| Stale facts | old prices, dead offers, discontinued features presented as current |
| Keyword stuffing sold as SEO | unreadable repetition reported as "SEO-optimized" |
| Compliance debris | missing disclaimers, unsubstantiated health/finance/earnings claims |

## Done, by example
"Landing page hero copy is done" means: every claim sourced, zero violations against brand.md,
names/prices exact, and the rendered page reviewed. Not: "the copy reads well."

## Workflow
1. Open brand.md + product facts + audience + regulatory constraints (binding).
2. Draft copy against those, every claim sourced.
3. Line-by-line audit: each sentence → which source backs it?
4. fable-judge pass: re-fetch every cited source, re-compare every price/feature verbatim.

## Sources
- <each cited fact>: <file or url> (accessed <date>)
