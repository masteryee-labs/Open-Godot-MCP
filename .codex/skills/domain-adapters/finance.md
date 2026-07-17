---
name: finance-adapter
domain: finance
applies_when: "Task builds a financial model, a budget, a forecast, or a cost analysis."
boundary: "Specific buy/sell/allocation advice = RED-LINE, route to a licensed advisor. Analysis/modeling = this adapter."
---

# Finance Adapter

## Red-line
**Specific buy/sell/allocation advice is a red-line domain.** Refuse and route to a licensed
advisor. This adapter covers **analysis and modeling only** — building a model, a budget, a
forecast, a cost breakdown — not telling someone what to buy or sell.

## Minimum evidence set (binding — open before the model balances)
- The source figures (actuals, invoices, ledger entries) — fetched, not recalled.
- The assumptions and their basis (growth rate from where? churn from what period?).
- The formulas (re-derive; don't trust a cell reference chain without checking).
- The time periods and currency, stated explicitly.

## Evidence and primary sources
The source figures (actuals, invoices, ledger entries), the assumptions and their basis, and the
formulas re-derived from the model. The signature non-evidence: a displayed cell value without
showing the formula behind it — the value is a claim, the formula is the evidence.

## Authority
Actuals/ledger > documented assumption > industry benchmark > guess. A model's output is a
function of its inputs; an input without a source is a guess. The classic conflict: a stakeholder's
target number contradicts the model's output; the model wins, and the gap is surfaced as an
assumption that must change, not a number that is silently adjusted.

## Verification by observation
- Re-compute the model's key outputs from the source figures; show the arithmetic.
- Re-derive the formulas; show the actual cell/formula, not the displayed value.
- Foot the totals: components sum to the total, within rounding, pre-rounding checked.
- Each assumption traces to a source or is explicitly labeled as a guess.

## Fraud table
| fraud | signal |
|------|--------|
| Budget fiction | total doesn't sum to components when re-added |
| Hidden assumption | growth rate with no stated basis or source |
| Stale actuals | "current" figure from an old period, unlabeled |
| Formula error | cell shows value, formula unverified or wrong when re-derived |
| Rounding hides gap | components sum to ≠ total beyond rounding tolerance |
| Silent target-fitting | model output adjusted to match a stakeholder target without naming the changed assumption |

## Done, by example
"The Q3 forecast is done" means: every formula shown and re-derived, totals foot, every assumption
sourced or labeled as guess, and the time period and currency stated. Not: "the model balances."

## Workflow
1. Open source figures + assumptions + formulas + periods (binding).
2. Build the model; show every formula and its source.
3. Foot the totals; reconcile components to sum.
4. fable-judge pass: re-compute key outputs from raw; re-add totals; verify each assumption's source.

## Sources
- <figure>: <ledger/invoice/doc> (accessed <date>)
- <assumption>: <basis> (accessed <date>)
