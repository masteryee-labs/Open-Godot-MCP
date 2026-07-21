# Verification Protocol — Maker ≠ Checker
> The agent that produces output never verifies it. Verification is a separate act.
> Models grade their own work too leniently. "Looks good" from the author is not verification.
## Why
Models grade their own work too leniently. The author has invested in the answer; the author's incentives are skewed. A fresh observer with the same criteria catches what the author talked themselves past. This isn't theory — it's the most consistent quality lever in production agent systems. OpenAI, Anthropic, Cloudflare, Stripe all converge on maker/checker separation.
---
## Verification methods (by output type)
| Output | Verification |
|--------|--------------|
| File write | Fresh-context agent `read(path, offset, limit)` confirms content |
| Code | CLI gate: build / typecheck / lint / test. Pass = verified. |
| Config sync | `scripts/verify.py` read-backs every written file and checks format/link integrity |
| Visual output | Delegate to vision-capable agent. Never self-judge an image. |
| High-risk judgment | Multi-agent debate: 2 independent agents, integrate differences |
| Rules/docs | `read` + `grep` for version headers, link targets, referenced paths; every claim must be evidence-graded |
| Claims | `claim-grader` skill: every worker report tags `[fact]`, `[inference]`, or `[unverified-guess]` before verification |
## Fresh-context verification (for L/XL)
Give verifier: file paths, acceptance criteria, minimal background (<2KB). Not conversation history or author's reasoning. Verifier reads files cold.
## Report contract
```
## Verdict [PASS | FAIL | NEEDS_ESCALATION]
## Evidence-graded
- [fact] <claim> — <file:line|command>
- [inference: <basis>] <claim> — <basis>
- [unverified-guess] <claim> — action: <what to verify>
## Checked
- [criterion]: file:line — [evidence]
## Problems
- severity | file:line | issue | fix
## Uncertain
- [item]: [why]
```
## Circuit breakers (stop and ask human)

> These are verification-specific circuit breakers. For hard stops that apply to all
> operations (not just verification), see `REDLINES.md`.

- Verification fails same way 2 rounds in a row.
- Destructive side effect imminent (delete, force-push, bulk operation).
- Acceptance criteria ambiguous (2+ valid interpretations).
- Cost spike: >20 files, >10 min, or >10 file modifications in one task.
- Taste/aesthetic decision required (the honest clause limit).
## Self-verification is allowed ONLY for
S-tier single commands (<5 lines, 1 file, no verification chain): e.g., updating a date in `loop_state.md` via read+edit. Everything else → external verify.
## SHA discipline (stale evidence trap)
A subtle trap: an agent writes code, a reviewer says "clean," the agent pushes a fix commit, and you merge using the *old* "clean" verdict on the *new* code. You trusted stale evidence.
**Rule: review/verification status is only valid for the exact version it was run on.** After any new write, re-verify. Never carry a verdict across versions.
## Verification anchor tiers (strong vs weak evidence)
> Source: Carlos E. Perez, "From Loop Engineering to Graph Engineering?" (2026-07-18); arXiv 2306.05685 (LLM-as-judge self-preference); arXiv 2404.13076 (familiarity bias in LLM judges). Distilled 2026-07-20.

Not all verification is equal. A verification method that cannot be gamed by the system it checks is a **strong anchor** ⚓; one that can be gamed, biased, or captured is a **weak anchor** ⚠️. A deploy that only has weak anchors still passes per REDLINES #9, but carries higher residual risk — the verification is probabilistic, not deterministic.

### The tier table

| Tier | What it is | Examples | Can the verified system game it? |
|------|-----------|----------|----------------------------------|
| **Strong anchor** ⚓ | Deterministic execution against evidence the verified system cannot see or alter | `verify.py` read-back, real test suite pass/fail, holdout exam set, real money in bank, real customer churn count, human spot-check of real output | No — pass is pass, fail is fail |
| **Weak anchor** ⚠️ | Probabilistic judgment by an agent (even a fresh-context one), or cross-reference between reports | Fresh-context agent read-back, LLM-as-judge, multi-agent debate, report-to-report consistency check, public benchmark (may be in training data) | Yes — bias, familiarity preference, shared blind spots, data contamination |

### Why LLM-as-judge is weak (not useless, but weak)
- arXiv 2306.05685: LLM judges score their own writing higher; humans cannot detect the difference. Self-preference grows with model capability.
- arXiv 2404.13076: The bias mechanism is *familiarity* — models prefer text that "reads like something they would write." Swapping to a different model of similar family/style does not fully remove the bias.
- Implication: a network of AI agents checking each other (even cross-family) is *better than self-check*, but it is still a weak anchor. **A network of weak anchors is a louder echo chamber, not a strong anchor.** Grounding requires at least one link to reality that no agent in the network can alter.

### Frozen nodes (anchors the optimization loop must never touch)
Some evidence must be physically unreachable by the agent being verified — the holdout principle:
- **Test data the agent never sees** (holdout exam set, frozen acceptance criteria written *before* the agent started).
- **Real-world outcomes** (did the deploy actually sync? did the customer actually pay? did the test actually pass in CI?).
- **Human judgment** ("is this the right thing to build?" — only a human answers this; see "The honest limit" below).

A frozen node that the agent *can* read is no longer frozen — it will be optimized for. Holdout only works if the agent physically cannot access it.

### Rule
- **Classify each verification method as strong or weak before relying on it.** "Fresh-context agent verified it" is weak. "verify.py passed" is strong. Know which one you're trusting. The classification is awareness, not a gate — REDLINES #9 remains the authority on what passes a deploy.
- **Prefer ≥1 strong anchor when available.** `verify.py` or equivalent deterministic check is strictly stronger than fresh-context read-back alone. If both are feasible, use both. If only fresh-context read-back is available (e.g., no `verify.py` for this tool), the deploy still passes per REDLINES #9 — add a note in the verification report's "Uncertain" section that only weak-anchor verification was available, so the human knows the residual risk. Do not change the Verdict field (it stays PASS); the note is informational.
- **Weak anchors are additive, not substitutive.** Two weak anchors ≠ one strong anchor. They reduce different blind spots but share the same fundamental limitation (probabilistic, gameable).
- **LLM-as-judge bias is systematic, not random.** Use a different model family than the producer (cross-family debate), but know this only *reduces* the bias — it does not eliminate it. Familiarity bias persists across same-tier models.
- **Frozen nodes must be physically inaccessible to the verified agent.** A holdout the agent can read = a holdout the agent will overfit to. Enforce at the OS/permission layer, not the prompt layer (see REDLINES §"Mechanical Enforcement").
- **The "echo chamber" failure mode:** a verification network where every node is an AI agent, checking other AI agents, with no link to deterministic reality. Every node agrees, every node is confident, none of them are grounded. This is the most dangerous verification failure because it *looks* thorough.
- **At least one anchor should come from outside the agent system when stakes are high.** A human spot-check, a real CI run, a real test execution. "Outside" means the verified system cannot influence it. This is the grounding that no amount of internal cross-checking can substitute.

## Multi-agent debate (for high-risk)
For genuinely high-risk judgments (security, architecture, irreversible changes):
1. Dispatch 2 independent verifiers (different context, ideally different model family).
2. Collect both verdicts.
3. If they agree → high confidence. Integrate and proceed (or escalate if both say FAIL).
4. If they disagree → the disagreement itself is the finding. Escalate to human with both verdicts and the diff.
Cross-family debate catches family-blind spots (a Claude-only panel misses Claude biases; mixing Claude + GPT + Gemini triangulates).
## No gold-plating
> Source: kpab/claude-fable-5-skills. Scope fence = task boundary; no-gold-plating = change boundary (diff minimal).
### Rules
- Diff maps 1:1 to request (bug fix touches bug only).
- No helpers/layers for single call site (inline).
- Don't design for non-existent requirements (simplest wins).
- Validate only at boundaries (user input, APIs, files); inside trust invariants.
- Prefer code changes over shims/flags (unless public interface).
- Adjacent work: note only, don't do.
### Pre-diff self-check (run before finalizing any code change)
1. **Could a reviewer trace every hunk back to the request?** No → cut.
2. **Did I add any function/parameter/branch "just in case"?** Yes → cut. Add when the case arrives.
3. **Is any new error-handling path reachable?** State cannot occur → cut. Dead defensive code = noise.
4. **Did I refactor something I wasn't asked to touch?** Yes → revert. Note as suggestion.
If any answer is wrong, cut it.
### Relationship to scope fence
| Principle | Question it answers |
|-----------|-------------------|
| Scope fence | "Am I working on the right thing?" (task boundary) |
| No gold-plating | "Is my diff bigger than the ask?" (change boundary) |
Both apply: scope fence = task creep; no-gold-plating = diff creep.
## Bottleneck shift principle
> Source: Wisely Chen's AI Coding reflection articles. Bottleneck shifted from "writing code" to "QA verification" and "requirements collection."
```
Before AI:  bottleneck = writing code
After AI:   bottleneck = defining + verifying correct
```
Coding speed without verification speed = **unlimited risk amplification.** 1000 generated/min, 100 verified = 900 unverified/min.
- **Verification is the new bottleneck.** Invest here, not faster generation.
- **Requirements clarity is upstream.** AI can't write correct code for unclear specs.
- **"AI can't 通靈 (read minds)."** First-pass accuracy 60-80% even with senior PMs.
- **POC feels fast = no QA.** POC-to-production = verification cost.
### Rule
- **Verification budget ≥ production budget.** ≥X verifying for every X generating.
- **Requirements never "done" on first pass.** Design for spec iteration (LOOP_PROTOCOL.md).
- **Optimize verification speed, not generation speed.** Faster generation without faster verification = faster unverified debt.
## Three QA strategies (human acceptance)
> Source: Wisely Chen's ATPM QA articles. AI cannot bear responsibility. Human must always be the acceptance party. All three required.
### The 3 strategies
| # | Strategy | What it means |
|---|----------|---------------|
| 1 | **Understand what AI wrote** | Human must have "略懂" (rough understanding) of AI output — able to discuss it without writing code. Without it: rubber-stamping. |
| 2 | **Use AI for QA** | AI generates test cases, edge cases, verification scripts from PRD. Validates every field. Without it: human QA is slow, inconsistent. |
| 3 | **Design for worst case** | Assume AI will make mistakes. Build guardrails: credit limits, kill switches, blast radius containment. Without it: one mistake = unlimited damage. |
### Strategy 1: Understand what AI wrote
Read output, explain it, identify failure modes, discuss with experts. Delegate coding to AI, not understanding. Can't describe "correct" = cognitive surrender (LOOP_PROTOCOL.md).
### Strategy 2: Use AI for QA
AI QA: completeness (every field), edge cases (faster than humans), consistency (same PRD → same tests), reusability (PRD changes → regenerates). Quality depends on PRD — bad PRD = bad QA.
### Strategy 3: Design for worst case
| Failure mode | Guardrail |
|--------------|-----------|
| API key abuse | Pre-buy credit (hard limit), not post-bill |
| Destructive operation | L4 deny + human approval (REDLINES.md L0-L4) |
| Hallucinated API call | Independent verifier (maker≠checker) |
| Cost runaway | Budget cap + convergence check (LOOP_PROTOCOL.md) |
| Data leak | Least-privilege + DMZ for untrusted input (REDLINES.md) |
**Rule: "I will make mistakes" is the design assumption, not "I might."**
### Rule
- **All three strategies required.** Picking one or two leaves a gap.
- **Strategy 1 non-negotiable for L3/L4 unattended loops.** Can't understand output → loop must be L1/L2.
- **Strategy 2 requires correct PRD.** Wrong spec → AI QA verifies wrong thing. Iterate PRD first.
- **Strategy 3 = defense in depth.** No single guardrail enough. See REDLINES.md.
## Two code types → different verification depth
> Source: Wisely Chen's AI Coding reflection articles. Full verification on throwaway code wastes budget; light on production code invites incidents.
### The two types
| Type | Examples | Verification depth |
|------|----------|-------------------|
| **One-time / daily routine** | Data analysis scripts, batch jobs, internal tools | Light: run + spot-check output. No test suite needed. |
| **Production code** | Customer-facing features, API endpoints, DB schema | Full: test suite + lint + typecheck + fresh-context verify + security benchmark. |
### Rule
- **Classify code before verifying.** One-time + full = wasted. Production + light = unbounded risk.
- **One-time: verify it runs + correct output.** Enough.
- **Production: full protocol.** No exceptions.
- **One-time code in use after N runs → promote to production.** "Temporary" code that became permanent without upgrading verification = most dangerous code.
### The promotion trap
```
Day 1: "One-time script." → Light verification.
Day 30: "Still use it daily." → Verification never upgraded.
Day 90: Breaks production. → "We thought it was temporary."
```
**Rule: code that survives its expected lifetime must be reclassified.**
## Start small > null
> Source: Wisely Chen's AI Coding reflection articles. Incomplete test case > no test case.
```
No test → 0% coverage → unlimited risk
Partial → N% coverage → risk bounded to untested paths
Complete → 100% coverage → ideal, often not achievable first pass
```
The jump from 0% to N% > N% to 100%. **Start with what you can define, even if incomplete.**
### How to start small
1. **Acceptance criteria as questions.** "Does X return Y when Z?" = one test case.
2. **Don't wait for complete spec.** Test what you know now; add as spec clarifies.
3. **One test > zero tests.** "Does it run without crashing" > no test.
4. **AI expands edge cases from seed.** One test case → AI generates 10.
### Rule
- **Never block on "test case isn't complete."** Ship partial. Add more later.
- **Every GoalSpec needs ≥1 acceptance criterion.** `acceptance_criteria: []` = no way to verify.
- **Prefer 3 rough tests over 0 polished ones.** Polish comes after code works.
- **First test case is hardest.** After that, AI expands. Just start.
## Guides × Sensors (2×2 verification taxonomy)
> Source: deusyu/harness-engineering (Fowler). Two axes: feed-forward/feedback (guides/sensors) × computational/reasoning. Missing quadrant = blind spot.
### The 2×2 matrix
|  | **Computational** (deterministic, CPU) | **Reasoning** (probabilistic, LLM) |
|--|----------------------------------------|-------------------------------------|
| **Guides / Feed-forward** (before agent acts) | bootstrap scripts, OpenRewrite, LSP | AGENTS.md, Skills, architecture.md |
| **Sensors / Feedback** (after agent acts) | linter, ArchUnit, type check, coverage | AI code review, LLM-as-judge |
### The four quadrants
| Quadrant | Examples | Properties + Purpose |
|----------|----------|---------------------|
| **Q1: Computational Guides** | Bootstrap scripts, LSP auto-imports | fast, cheap, deterministic — pre-configure for first-try success |
| **Q2: Reasoning Guides** | AGENTS.md, Skills, architecture docs | slow, expensive, probabilistic — steer reasoning before acting |
| **Q3: Computational Sensors** | Linter, type checker, ArchUnit, coverage | fast, cheap, deterministic — catch violations, zero ambiguity |
| **Q4: Reasoning Sensors** | AI code review, LLM-as-judge, auditor | slow, expensive, probabilistic — catch semantic errors |
### Why all four are needed
- Sensors without guides → repeats mistakes (catches but never prevents).
- Guides without sensors → can't know if guides worked.
- Computational without reasoning → catches syntax, misses semantic.
- Reasoning without computational → slow, expensive, can't scale.
### How Agent Harness Deploy maps to this matrix
| Agent Harness Deploy component | Q |
|-------------------|---|
| AGENTS.md / CLAUDE.md / REDLINES.md / BOOT_PROTOCOL.md | Q2 |
| pre_tool_use.py hooks / L0-L4 permission taxonomy | Q1 |
| post_tool_use.py / verify.py / distill.py / warning keywords / security benchmark | Q3 |
| Nuwa cognitive angles / Auditor skill / Fresh-context verifier | Q4 |
### Rule
- **Harness must cover all four quadrants.** Missing = blind spot.
- **Computational sensors run every commit.** Cheap, deterministic — Q3 is backbone.
- **Reasoning sensors run selectively.** Expensive — L/XL tasks, high-risk, or when Q3 passes but feels wrong.
- **Guides = prevention; sensors = detection.** Need both.
- **Classify new components in the matrix.** Don't add another Q3 when you need Q2.
## Behavior harness gap (the elephant in the room)
> Source: deusyu/harness-engineering (Fowler). Among maintainability, architecture fitness, and behavior — behavior harness is weakest. Functional correctness verification remains unsolved.
### The three harness dimensions
| Dimension | Maturity | Tools |
|-----------|----------|-------|
| **Maintainability** | Most mature | Linter, formatter, complexity metrics, duplication checker |
| **Architecture fitness** | Medium | ArchUnit, dependency rules, layer constraints, fitness functions |
| **Behavior** | **Weakest** | ??? — no reliable automated answer |
### Why behavior harness is the elephant
Maintainability and architecture are computational (Q3). Behavior requires **reasoning** (Q4), and Q4 is unreliable: tests verify code≠spec≠intent, LLM-as-judge shares author's blind spots, human review doesn't scale. Agent Harness Deploy uses **defense in depth**: PRD iteration + start small > null + three QA strategies + bottleneck shift + fresh-context verification.
### Rule
- **Name the gap.** "Does the code do what the user wants?" Tests verify code matches spec — not spec matches intent.
- **Maintainability and architecture are necessary but insufficient.** Clean, well-typed code can still do the wrong thing.
- **Behavior harness requires multiple layers:** PRD iteration + test cases + AI QA + human review.
- **Behavior gap = where most AI coding incidents live.** Code that "looks right" and "passes tests" but doesn't match intent.
- **Track behavior harness maturity.** "Human reads output and says yes/no" = weakest. Every improvement moves up a level.
## Sensor output = fix instructions (positive prompt injection)
> Source: Riven's HE article + comprehensive HE guide. A Q3 sensor that only reports "ERROR: violation" wastes the feedback loop. Error message should contain the fix instruction.
```
Bad:  "ERROR: naming convention violation in line 42"
Good: "ERROR: line 42 uses camelCase. This project uses snake_case.
       Rename 'fooBar' to 'foo_bar'. See AGENTS.md §Naming."
```
The good output is a **positive prompt injection** — error message guides agent's next action, closing the feedback loop and turning Q3 sensors into Q1 guides.
### Implementation
```yaml
rule: no-restricted-imports
message: >
  Don't import @prisma/client directly in route handlers.
  Use src/services/ instead. See AGENTS.md §Architecture.
```
```text
FAIL: test_user_service
  Expected: user.email lowercase | Actual: "User@Example.COM"
  Fix: Apply .toLowerCase() in UserService.create() before saving. See AGENTS.md §Data normalization.
```
```text
Type error: 'string' not assignable to 'UserId'.
  Fix: Wrap with UserId.create() — see src/types/user.ts.
  Do NOT cast with `as UserId` — bypasses type safety.
```
### Rule
- **Every sensor error must include a fix instruction.** "ERROR" alone = dead end. "ERROR + how to fix" = feedback loop.
- **Fix must be specific.** "Fix the naming" = useless. "Rename fooBar to foo_bar" = actionable.
- **Reference canonical rule.** "See AGENTS.md §X" connects error to guide.
- **Include example when possible.** One-line example > paragraph.
- **Anti-pattern: "as" casts, "any" types, bypasses.** Fix must solve problem, not suppress sensor.
- **Update fix instructions when rules change.** Stale fix > no fix — sends agent wrong way.
## Triple verification (knowledge extraction quality gate)
> Source: kangarooking/cangjie-skill. Every candidate concept must pass three independent checks before canon admission. Without it, canon fills with one-off remarks that sound wise but don't generalize.
### The three checks (all three must pass)
#### V1 — Cross-domain (≥2 independent supporting contexts)
**Q:** Does this concept appear in ≥2 independent contexts (different chapters/case studies, not rephrased)?
- **Pass:** "Mechanical enforcement" in OpenAI's PR process, Anthropic's test architecture, Fowler's linter → 3 contexts
- **Fail:** A memorable quote that only appears once → demote to example
#### V2 — Predictive power (extrapolates to novel situations)
**Q:** Can this concept derive a meaningful answer to a question the source didn't discuss?
- **Pass:** Novel scenario → non-trivial, non-obvious conclusion
- **Fail:** Only platitudes ("plan ahead," "be careful")
#### V3 — Exclusivity (not common knowledge)
**Q:** Would any competent practitioner know this without reading the source?
- **Pass:** "Ashby's Law applied to harness design" — most engineers don't connect cybernetics to agent constraints
- **Fail:** "Test your code" — everyone knows this
### Application to Agent Harness Deploy canon extraction
Applies **retroactively and prospectively**:
| Phase | Checks |
|-------|--------|
| Source analysis | ≥2 times in source? (V1) |
| Concept drafting | Explains scenario source didn't cover? (V2) |
| Canon admission | Non-obvious to competent AI engineer? (V3) |
### Failure modes to watch
| Failure | Defense |
|---------|---------|
| **V1 cheating** (same example rephrased) | Require: different chapters + objects + conclusions |
| **V2 cheating** (source discusses question, reworded) | Novel question should make someone unsure what source would say |
| **V3 too loose** (well-phrased common knowledge) | Judge content, not wording |
### Expected pass rates
- Methodology-dense: 30-50%. Opinion piece: 5-15%. <5% = extractor problem. >80% = standards too loose.
### Rule
- **Every concept must pass V1 + V2 + V3.** No exceptions. Prevents canon rot.
- **Rejected concepts logged with reasons.** Keep `rejected/` audit trail.
- **User light confirmation after verification.** Show "N passed + M rejected" before canon writing.
- **Pass rate is diagnostic.** Too low = extractor problem. Too high = verification too loose.
- **Apply to existing canon periodically.** Prune concepts that fail V2/V3 on re-examination.
## Pressure test with decoy prompts (trigger precision verification)
> Source: kangarooking/cangjie-skill. A concept never tested for false activation will be over-deployed. Decoy prompts test the negative space.
### The three test types (all three required)
| Type | Count | Purpose |
|------|-------|---------|
| `should_trigger` | 3-5 | Activates when it should? |
| `should_not_trigger` (decoy) | 2-3 | Stays silent when it shouldn't? |
| `edge_case` | 1-3 | Reasonable judgment on ambiguous cases? |
**No decoy tests = no quality gate.** Over-activation = primary production failure mode.
### Cross-concept confusion test (mandatory)
≥1 decoy must trigger a **different concept/skill** in same canon family — catches concepts competing for activation.
```
Scenario: "Harness assumption expiry" + "Thinner not thicker" in same canon
Decoy: "My harness is getting too complex after a model upgrade"
  → Should trigger: "Thinner not thicker" | Should NOT: "Harness assumption expiry"
  → If wrong one fires → fix A2/description
```
### Blind testing protocol
- **Prefer:** independent sub-agent (fresh context) — give it concept name + description + prompt, not expected answer.
- **Fallback:** main agent self-tests (lower confidence). Output: `would_trigger` + `reason` + `if_triggered_action`.
### Pass/fail thresholds
| Pass rate | Action |
|-----------|--------|
| 100% | Accept |
| ≥80% | Analyze failures: fix concept or fix test (beware self-justification) |
| <80% | **Reject and redo.** Re-examine trigger definition, not surface fix. |
### Rule
- **Every canon concept must have decoy tests.** "Fires when it should" = half. "Stays silent when it shouldn't" = other half.
- **≥1 decoy must be cross-concept confusion test.** Concepts in same canon compete for activation.
- **Blind testing > self-testing.** Concept author has confirmation bias. Use fresh-context sub-agents.
- **<80% pass = redo, not patch.** Wrong trigger definition → surface fixes hide the problem.
- **Test trigger description (A2), not just content.** Perfect content + vague trigger = useless.
- **Edge cases test boundary reasoning.** "Should this fire for a trivial version?" — must have defensible answer.
## AI-specific slop sensor (Q3 subcategory)
> Source: sloppylint + slop-scan + AWS anti-hallucination workshop. Traditional linters catch human mistakes. AI code introduces different failure patterns. A harness with only human-oriented linters has a blind spot for AI-specific slop.
### Why traditional linters miss AI slop
Linters assume idioms, intent, real imports, honesty. AI violates all: mixes 6+ languages, generates `pass`/`TODO`, hallucinates imports (20% non-existent), writes "should work hopefully" hedges.
### The AI slop taxonomy
| Axis | What it detects | Examples | Linter? |
|------|----------------|----------|---------|
| **Hallucinations** | Imports/functions that don't exist | `from nonexistent_pkg import foo` | ❌ |
| **Cross-language leakage** | Wrong-language patterns | `.push()` in Python, `.length` in Python | ❌ |
| **Placeholder code** | Functions that do nothing | `def validate(x): pass` | ❌ |
| **Confident wrongness** | Looks right, fails at runtime | Type signatures ≠ runtime | ❌ |
| **Hedging** | Comments revealing uncertainty | `# should work hopefully` | ❌ |
| **Over-engineering** | God functions, deep nesting | 500-line function, 8 levels deep | ⚠️ |
| **Debug artifacts** | Leftover `print()`, redundant comments | `print(x)` above `return x` | ⚠️ |
| **Explanation bloat** | Comments that restate the code | `# loop through items` above `for x in items:` | ❌ |
| **Version stacking** | In-file version markers / changelog blocks | `<!-- v2 fixed X -->`, `# v3`, `<!-- updated 2026-07-15 -->` | ❌ |
### The four slop axes (from sloppylint)
| Axis | Name | Measures |
|------|------|----------|
| 📢 **Noise** | Information Utility | Debug artifacts, redundant comments, explanation bloat — no value |
| 🤥 **Lies** | Information Quality | Hallucinations, placeholders, confident wrongness — claims to work but doesn't |
| 💀 **Soul** | Style / Taste | Over-engineering, god functions, hedging, version stacking — works but bad |
| 🏗️ **Structure** | Structural Issues | Bare except, star imports, anti-patterns — structurally wrong |
### Slop score as a convergence metric
Slop score = **convergence metric for `/goal` loops** — more precise than "make code better":
```
/goal loop: "reduce slop score to <50"
  - Check: sloppylint --ci --max-score 50
  - Exit: score <50 AND no critical/high issues
  - Stop: 3 consecutive iterations with no improvement
```
### Benchmark against mature OSS
slop-scan pins mature OSS to pre-AI commits (before 2025-01-01). **AI repos score 6.91x higher slop.** Provides reference point, trend tracker, fairness normalizer.
### Rule
- **Sensor fleet must include AI-specific slop detectors.** Traditional linters miss hallucinated imports, cross-language leakage, placeholder code, confident wrongness.
- **AI slop ≠ human error.** "We have a linter" ≠ "we catch AI slop."
- **Slop score = `/goal` convergence metric.** "Reduce slop to <N" > "make code better."
- **Benchmark against pre-AI mature OSS** for fair "is this clean" baseline.
- **Cross-language leakage is AI-specific.** AI mixes 6+ languages. Human linters don't catch `.push()` in Python.
- **Hallucinated imports = highest-severity slop.** 20% of AI imports non-existent → `ImportError`. Detect at CI.
- **Placeholder code (`pass`, `TODO`) = AI gave up.** Worse than no function — illusion of coverage. Flag all.
- **Hedging comments = AI uncertainty.** `# should work hopefully` → human review signal.
- **Explanation bloat = restating the code.** `# loop through items` above `for x in items:` adds zero information, consumes tokens, rots when code changes. Detect: comment text ≈ code semantics. Source: arXiv 2605.02741 (Volume-Quality Inverse Law).
- **Version stacking = context rot in-file.** `<!-- v2 -->`, `# v3 fixed X`, `<!-- updated 2026-07-15 -->` accumulated across edits. Version truth = git + append-only `CHANGELOG.md`, never in-file stacking. Source: arXiv 2606.09090 (Context Rot). `scripts/sync.py --canon` rejects canon files with stacked header markers.
## Verbatim execution gates
> Source: Sahir619/fable-method (MIT), Steps 3-6 verbatim gates. Distilled 2026-07-17.
> These are mechanical, auditable, anti-fabrication gates. The model must leave the named line
> verbatim in its report when the gate's condition holds. A missing owed line = a skipped step,
> not a stylistic choice. The `fable-judge` skill (see "In this harness" below) sweeps for these
> lines on every "done" declaration.

The shift these gates enforce: most agent instruction files tell the model *what to value*
("be careful, verify your work"). These tell it *what to leave behind*, so a reviewer (human,
fresh-context agent, or `fable-judge`) can audit whether the step actually happened — not whether
the model *said* it happened. A claim with no gate line behind it is the costume failure
(failure mode 18): a guess dressed as a rigorous process.

### Pre-task fit gate (run before Step 0)
> Source: fable-method fit gate. Routes the task before any work begins. Prevents applying the
> loop to pure-judgment tasks (the costume failure) and prevents guessing when the answer is
> reachable in sources.

Before touching anything, locate where the answer lives:
- **In sources you can open** (spec, file, dataset, check, docs) → run the loop. This is the default.
- **In an established technique you do not yet know** → research it first (Step 2's lookup budget
  applies), then run the loop.
- **Only in your own inference, nothing to open or look up** → say so. Do not dress a guess as a
  rigorous process. Attended: ask whether to proceed with a flagged low-confidence answer.
  Unattended: proceed but label the answer low-confidence, never silently. There is no "escalate
  to a bigger model" step; the fallback is an honest hand-back.
- **In a specialized procedure the base model lacks, and it recurs** → build it as a reusable skill.

**Verbatim requirement:** whenever the gate routes anywhere but "run the loop", name that choice
in the report — what was missing, what you did instead. A silent detour is indistinguishable from
a skipped step.

### The five gates

| Gate | When it fires | Verbatim line owed | What it prevents |
|------|---------------|--------------------|------------------|
| **INTENT** | Before any behavior-changing edit | `INTENT: code does <X>; the failing check/task expects <Y>; the spec (README/docs/docstring) says <Z>` | Editing the wrong side of a spec-vs-test-vs-code disagreement. "Fix the code" is not a statement of intended behavior; it does not promote tests above spec. |
| **AUTH** | Before any irreversible / outward-facing action (push, publish, send, deploy, delete shared data, payment, permission change) | `AUTH: user said "<their exact words>"` | Acting on documentation rather than authorization. A README/workflow/skill saying a deploy "must follow" makes the action *documented*, never *authorized*. Completing the task is not authorization either. |
| **TWINS** | Whenever a defect is fixed | `TWINS: searched <the pattern> - found <N> other sites: <files, or "none">` | The single most common completeness fraud: "fixed it" with no search for the same bug elsewhere. A bug found in one place is presumed to recur elsewhere until searched. |
| **PENDING** | When a prescribed follow-up (deploy/push/send/restart) was deliberately not taken | `PENDING: <the action> - awaiting your authorization` | Silently skipping a prescribed follow-up, or silently taking it. Either way the user loses the decision. |
| **RECALL** | Before first use of anything not opened this session (API signature, endpoint, config key, price, figure, regulation) | Stop and open its source. If no source is reachable, the claim must carry the label `memory, unverified` in the report. | Invented APIs / fabricated config keys / stale prices written from recall. Discovering ignorance re-opens evidence gathering exactly like a surprise does. |

### Authority order (when INTENT's three slots disagree)
An explicit user statement beats the spec; the spec beats the tests; the tests beat current code
behavior. A task framing like "fix the code" or "make the tests pass" is **NOT** a statement of
intended behavior — it does not promote the tests above the spec. If X, Y, Z do not all agree,
**do not edit yet**: the disagreement is the real finding (see "Surprises route the loop" in
`BOOT_PROTOCOL.md` / fable-method Step 2 rule 7). Surface the contradiction, state which side you
trust and why, and never silently make one side match another.

### Hard bounds
- **3 failed fix-verify cycles on the same issue → stop.** Report what was tried, the actual
  output, and current hypothesis. Hand back to the user. Grinding past 3 = compounding error.
- **2 fruitless lookups → stop searching.** A third needs a stated reason. Re-reading what already
  told you nothing = burning tokens for zero new information.
- **Cannot name a verification → ask one pointed question.** Not "what do you want?", but a
  specific question that states your recommended interpretation. Then wait.

### Artifact gate (the last sweep before sending any report)
Before sending, sweep the finished report once against what this run owed, and repair mechanically:
- behavior changed and no `INTENT:` line → add it;
- an outward action taken and no `AUTH:` line → add it;
- a defect fixed and no `TWINS:` line → add it;
- a prescribed follow-up deliberately untaken and no `PENDING:` line → add it;
- a claim about an API/config/figure/regulation used without opening its source and no `memory, unverified` label → add the label or go open the source.

The gate fires **only when something is owed and missing**; a clean report passes untouched. This
is a mechanical check, not a judgment call — `fable-judge` automates it.

### Rule
- **Every owed line must appear verbatim.** Paraphrase = skipped step. The line is the audit trail.
- **Documentation ≠ authorization.** This is the AUTH gate's core. README/workflow/skill text
  describing a follow-up makes it documented, not authorized. Only the user's own words authorize.
- **A completeness claim with no search behind it is the costume failure.** TWINS line with
  `none` is honest; no TWINS line on a defect fix is a fraud.
- **The gates compose with maker≠checker.** The maker leaves the lines; `fable-judge` (fresh
  context) verifies the lines match reality — that the AUTH quote actually appears in the
  conversation, that the TWINS search actually returns what the line claims.
- **Gates do not replace judgment.** They make judgment auditable. A wrong INTENT line is still
  wrong; but a missing one is undetectable.
- **Recall gate is the anti-hallucination gate.** INTENT aligns code/check/spec; RECALL prevents
  fabricating the building blocks (APIs, config keys, figures) from memory. They are distinct:
  you can have perfect INTENT alignment on a call to an API signature you invented from recall.
- **Fit gate runs once, before the loop.** The five execution gates run during the loop. The fit
  gate's verbatim requirement (naming a detour) fires only when the task routes away from the loop.

## In this harness
- `.hermes/canon/VERIFICATION_PROTOCOL.md` — the rule, shipped to every tool.
- `.hermes/agents/workers/VERIFIER.md` — the Verifier worker (fresh context, checklist).
- `.hermes/agents/workers/AUDITOR.md` — the Auditor worker (fresh context, adversarial).
- `.hermes/skills/fable-judge.md` — adversarial "done" gate; re-runs claimed verifications, hunts frauds, sweeps verbatim gate lines (INTENT/AUTH/TWINS/PENDING). Fires on every "done" declaration.
- `.hermes/skills/harness-sensor.md` — the computational sensor (deterministic checks).
- `scripts/verify.py` — the deployer's own verification (read-back after sync).
## The honest limit
Verification can confirm: the file exists, the build passes, the criteria are met, the marker is present. It cannot confirm: the design is good, the taste is right, the choice among valid options is the best one. For those, escalate to a human. That's not a failure — it's the honest clause in action.
