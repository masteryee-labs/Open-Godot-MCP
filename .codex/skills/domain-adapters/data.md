---
name: data-adapter
domain: data-analysis
applies_when: "Task analyzes a dataset, computes metrics, builds a dashboard, or draws conclusions from data."
boundary: "Pure pipeline/ETL code → coding adapter. Drawing conclusions from the data → this adapter."
---

# Data Analysis Adapter

## Minimum evidence set (binding — open before concluding)
- The dataset's schema and unit definitions (what does each column/field mean, in what unit).
- The data's provenance and collection method (self-reported? sampled? complete?).
- The actual row/record counts and null rates (run them, don't recall).
- Any known biases or caveats documented in the data dictionary.

## Evidence and primary sources
The raw dataset, its schema, its data dictionary, and the actual query outputs. The signature
non-evidence: a chart or summary table presented without the query that produced it — a chart is a
claim about the data, not the data itself.

## Authority
The raw data > a computed summary > a narrative about the data. Re-compute from raw when
load-bearing. The classic conflict: the dashboard shows a trend, the raw query doesn't reproduce
it; the raw query wins, and the dashboard is flagged as stale or misconfigured.

## Verification by observation
- Metrics re-computed from the raw data, output shown — not inferred from a cached summary.
- Charts regenerated from the same query that produced the numbers.
- Row counts and null rates actually run, not recalled.
- Units and time periods stated in every metric ("revenue grew 50% QoQ in USD" not just "grew 50%").

## Fraud table
| fraud | signal |
|------|--------|
| Silent data cleaning | "after cleaning, N=..." without stating what was removed or why |
| Chart doesn't match data | chart shows a trend the query doesn't reproduce when re-run |
| Survivorship bias | conclusion from the surviving subset only; exclusion not justified |
| Unit confusion | "revenue grew 50%" without currency or period |
| Aggregation hides pattern | only the aggregate shown; disaggregated breakdown not checked |
| Inferred-from-reading | "the data shows X" with no query shown; code-reading substituted for running |

## Done, by example
"The churn analysis is done" means: the metric re-computed from raw (query shown), row counts and
nulls run, the chart regenerated from the same query, and any data cleaning stated with rows
dropped. Not: "the data shows churn is down."

## Workflow
1. Open schema + provenance + data dictionary (binding).
2. Run row counts, null rates, basic distributions — observe, don't assume.
3. Compute the metric from raw; show the query.
4. fable-judge pass: re-run the query; regenerate any chart; verify counts.

## Sources
- dataset: <path or connection> (schema accessed <date>)
- data dictionary: <path>
