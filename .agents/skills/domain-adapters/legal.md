---
name: legal-adapter
domain: legal-compliance
applies_when: "Task researches regulatory compliance, maps obligations, or summarizes what a regulation requires."
boundary: "Legal ADVICE (what you should do in your specific case) = RED-LINE, route to a lawyer. Compliance RESEARCH = this adapter."
---

# Legal / Compliance Adapter

## Red-line
**Legal advice is a red-line domain.** Refuse and route to a qualified lawyer. This adapter covers
**compliance research only** — identifying what a regulation says, mapping obligations, summarizing
requirements — not advising on a specific party's legal position.

## Minimum evidence set (binding — open before stating a requirement)
- The actual regulation text (statute, rule, standard) — fetched from the official source.
- The regulation's effective date and any amendments.
- The jurisdiction (which authority's rule applies).
- Any official guidance/FAQ/commentary from the issuing authority.

## Evidence and primary sources
The regulation text itself (statute, rule, standard), fetched from the official source, plus
official agency guidance. The signature non-evidence: a secondary blog or summary quoted as the
rule — it is commentary, not the regulation.

## Authority
The regulation text itself > official agency guidance > reputable secondary commentary > general
legal knowledge. The classic conflict: a well-known secondary summary contradicts the actual
regulation text; the regulation wins, and the discrepancy is named.

## Verification by observation
- Every quoted requirement traces to the regulation text with citation (section, subsection).
- Re-fetch the regulation to confirm the quote is verbatim and in context.
- Access date noted; amendment status checked — a pre-amendment citation is flagged.
- Jurisdiction verified: the regulation cited actually governs the question's jurisdiction.

## Fraud table
| fraud | signal |
|------|--------|
| Quoted text not in the regulation | "the regulation says..." but re-fetch doesn't find the quote |
| Wrong jurisdiction | EU rule applied to a US question, or vice versa |
| Stale regulation | requirement cited without checking amendments since the access date |
| Overgeneralization | "generally, X is required" without citing the specific section or noting conditions |
| Secondary-as-primary | a blog or summary quoted as the rule itself |
| Missing exceptions | requirement stated without the conditions or exceptions that limit its scope |

## Done, by example
"The GDPR compliance map is done" means: every requirement cited with section number, the
regulation re-fetched and quote verified, amendment status checked, jurisdiction confirmed, and
exceptions noted. Not: "the main obligations are covered."

## Workflow
1. Identify jurisdiction + the specific regulation (binding).
2. Fetch the regulation text + effective date + amendments + official guidance.
3. Map obligations with section citations; note conditions and exceptions.
4. fable-judge pass: re-fetch the regulation; verify each quote; check amendment status.
5. State explicitly: this is research, not advice; consult a lawyer for application to a specific case.

## Sources
- <regulation>: <official url> (accessed <date>, effective <date>, last amended <date>)
