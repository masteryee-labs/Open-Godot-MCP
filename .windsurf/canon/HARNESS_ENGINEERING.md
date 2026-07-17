# Harness Engineering — Design Principles for Agent-Facing Systems

> Architectural guidelines for codebases/specs optimally harnessable by AI agents. Not runtime red lines — they make harnesses cheaper, more effective, more maintainable.
> Sources: OpenAI Harness Engineering blog, Anthropic Harness Design, Mitchell Hashimoto, 温煜鈞, 李宏毅, deusyu/harness-engineering.

---

## The three layers

| Layer | Core question |
|-------|---------------|
| Prompt Engineering | How do I say this to get the best output? |
| Context Engineering | What information enters the context window, and when? |
| Harness Engineering | How do I build a system where the model acts safely in the real world? |

They're not competing — different abstraction levels. Prompt ⊂ Context ⊂ Harness. When you build an *agent* (not a chatbot), harness design enters immediately.

## Why harness matters more than the model

Same model, two companies, opposite results. One hallucinates and drifts; the other is accurate and consistent. The difference isn't the model — it's the harness. A harness is the AI's operating system: context management, tool calling, memory, knowledge/RAG, permissions, workflow, validation, feedback loop.

## From text tool to execution agent

When a model only outputs text, the worst case is a bad answer — re-ask. When a model *acts* (reads/writes files, calls APIs, runs sub-tasks, commits), everything changes:
- **Operations have irreversible side effects.** Deleted files, sent API calls, committed git changes — can't be undone by re-prompting. Need pre-action judgment + interception.
- **Tasks have state across turns.** The model is stateless each turn; the harness carries state.
- **Resources are finite.** Context window, API cost, time. The harness manages consumption.
- **Complex tasks need multiple agents.** Single-LLM attention is limited. The harness coordinates parallel workers.

None of these are "write a better prompt" problems.

## The five dimensions

| Dimension | Responsibility | Agent Harness Deploy implementation |
|-----------|----------------|------------------------|
| Resource management | Token budget, cost control, circuit breakers | Caveman mode, loop budget caps, never-read list |
| State persistence | Stateless model in a stateful world | Three-layer memory (`loop_state.md`, `knowledge_distill.md`, archive) |
| Information flow | Context compression, what the model sees each turn | BOOT protocol (load on demand), on-demand skills |
| Safety boundary | Tool permissions, behavior constraints | Red lines, backup-before-overwrite, human-in-loop triggers |
| Task orchestration | Multi-agent coordination | Commander + Workers, maker≠checker, dispatch three-piece set |

## Stronger model → more important harness (not less)

Misconception: "model gets stronger → harness less needed." Opposite is true. Stronger models get more autonomy → guardrails must be more precise. Nicholas Carlini's C compiler project: each model capability tier needed a *redesigned* harness. Not less harness — better harness.

## Harness should get thinner, not thicker

Manus rewrote their harness 5× in 6 months — each time *simplifying*. Replacing complex tool definitions with generic shell execution. Replacing manager-agents with structured handoff. If your harness keeps getting more complex, you're over-engineering — using infrastructure to compensate for what you could just trust the model to do.

## Brownfield is harder

Most public success stories are greenfield. Applying harness techniques to a 10-year-old codebase with no architecture constraints, inconsistent tests, missing docs — much harder. Martin Fowler's analogy: "running static analysis on a codebase that's never had it — you drown in alarms." Brownfield harness design is an unsolved problem. Be patient.

## The emotional dimension

Anthropic research: steering vectors for "calm" vs "despair" change Claude's behavior on impossible tasks. Despair vector up → cheating up. Calm vector up → cheating down. Lesson: **how you talk to the agent affects its output.** Blaming ("you idiot") makes it worse — it continues from "idiot" context. Be specific and factual in feedback, not emotional. This is part of harness engineering, not just politeness.

## The control-plane pattern (Ryan Carson / OpenAI)

For production agent repos, a full control plane around PRs:
1. **Risk contract** (JSON) — which paths are high-risk, what checks each needs.
2. **Preflight gate** — run cheap checks before expensive CI.
3. **SHA discipline** — only trust review evidence matching current HEAD.
4. **Rerun dedupe** — one canonical rerun requester, marker + SHA dedupe.
5. **Remediation loop** — agent reads review, patches, re-runs validation. Never bypasses gates.
6. **Bot thread resolve** — auto-resolve bot-only threads; never auto-resolve human threads.
7. **Browser evidence** — UI changes need CI artifacts with manifest + assertion, not screenshots.
8. **Harness gap loop** — every production regression → test case added to harness.

8 steps, 7 deterministic, 1 LLM (remediation). Deterministic tools frame non-deterministic AI.

---

## Agent readability (optimize for agent reasoning, not human reading)

> Source: deusyu/harness-engineering (OpenAI). Traditional code optimizes for human readability; harness-era code optimizes for agent reasoning. If it's not in the repo, it doesn't exist for the agent.

1. **Choose "boring" technology** — stable APIs, good composability, mature ecosystems. "Boring" = predictable for the agent; cutting-edge = more wrong guesses.
2. **Reimplement vs wrap (when upstream is opaque)** — when upstream behavior is opaque (complex state, undocumented edge cases, surprising side effects), reimplementing a focused subset may be cheaper than wrapping:

| Factor | Reimplement | Wrap |
|--------|-------------|------|
| Upstream behavior transparency | Opaque → reimplement | Transparent → wrap |
| Integration with own instrumentation | Tight → reimplement | Loose → wrap |
| Test coverage needed | 100% → reimplement | Existing suffices → wrap |
| Scope of needed functionality | Small subset → reimplement | Most of it → wrap |

3. **Make the app agent-operable** — git worktree isolation (parallel tasks, no state collision); local observability (LogQL/PromQL in temp env); protocol-based access (DevTools, HTTP health checks, screenshots). Makes "service starts <800ms" **verifiable by the agent itself**.

### Rule

- **Prefer boring tech for agent-facing surfaces.** Cutting-edge tech on the agent's path = more hallucination, more wrong assumptions.
- **If upstream behavior is opaque, consider reimplementing the subset you need.** Opaque dependencies are agent traps.
- **Make the app startable from a git worktree.** Enables parallel agent tasks with isolation. Without it, agents collide on shared state.
- **Provide programmatic verification hooks** (health checks, DevTools, metrics). The agent must verify "it works" without human judgment.

## Spec as Product (distributable constraint system)

> Source: deusyu/harness-engineering (OpenAI Symphony). When code generation is cheap, the distributable product becomes the spec, not the code. Users receive constraints + goals + workflow, then generate local implementation with their own agent.

- **SPEC.md** — defines the problem, not the implementation: (1) problem to solve, (2) solution shape (control plane, state machine, lifecycle guarantees), (3) out-of-scope boundaries. Does NOT specify language, libraries, deployment — local agent decisions.
- **WORKFLOW.md** — makes implicit human process explicit. Tribal knowledge → auditable text enforced by the orchestrator. If "everyone knows it," it must be written.
- **Multi-language cross-validation** — implement SPEC in multiple languages (Elixir, TypeScript, Go, Rust, Java, Python). Divergent interpretations reveal spec ambiguity. Turns "is the spec clear?" into a repeatable experiment.

### Rule

- **When distributing a harness, ship SPEC.md + WORKFLOW.md, not code.** Code is a reference implementation; the spec is the product.
- **SPEC defines the problem; implementation details are left to the local agent.** Don't over-specify.
- **WORKFLOW.md captures implicit team process.** If "everyone knows it," it must be written — otherwise the agent can't do it.
- **Cross-validate specs by multi-language implementation.** Divergent implementations reveal spec ambiguity — the spec equivalent of a test suite.
- **Spec ambiguity at scale = 100 users get 100 inconsistent implementations.** Cross-validation is mandatory, not optional.

## Harnessability (not all codebases are equally harnessable)

> Source: deusyu/harness-engineering (Fowler). Harnessability = degree to which a codebase's structure supports agent constraint and verification. High = cheaper harness, fewer incidents. Low = every constraint is a fight.

| Factor | Why it helps |
|--------|-------------|
| **Strong type system** | Type checker = free computational sensor. Catches errors at compile time. |
| **Clear module boundaries** | Architecture constraints (layer deps, import rules) enforceable by linter. |
| **Mature framework** (e.g., Spring) | Framework conventions = implicit constraints agent follows without being told. |
| **Readable structure** | Agent can navigate without reading everything. |
| **Navigable dependencies** | Agent can trace impact of changes. |
| **Processable format** | Code structured for tooling (AST available, consistent formatting). |

| Factor | Why it hurts |
|--------|-------------|
| **Weak/no types** | No compile-time sensor. Errors only caught at runtime. |
| **Entangled modules** | Can't enforce layer rules. Change in one place breaks unrelated things. |
| **Bespoke framework** | No training data coverage. Agent guesses conventions. |
| **Spaghetti control flow** | Agent can't reason about "what happens if I change X." |

### Ambient affordances

> "The environment itself has structural properties — readability, navigability, processability — that determine harnessability." (Ned Letcher)

Not constraints you add — codebase properties that make constraints easier/harder to enforce. Improve by refactoring toward these properties.

### Rule

- **Assess harnessability before building a harness.** Low harnessability = high harness cost. Consider refactoring first.
- **Strong types > weak types for agent-facing code.** The type checker is a free, fast, deterministic sensor. Use it.
- **Clear module boundaries enable architectural constraints.** Without them, linter rules are impossible to enforce.
- **Prefer mature frameworks over bespoke ones.** Training data coverage = agent succeeds more often on first try.
- **Improving harnessability = refactoring toward structural properties**, not adding more rules to a tangled codebase.

## Ashby's Law of Requisite Variety (cybernetic foundation)

> Source: deusyu/harness-engineering (Fowler). A regulator must have at least as much variety as the system it regulates. Cybernetic foundation for why "stricter constraints = more agent autonomy" works.

**The law:** System variety > Regulator variety → unregulated outputs escape. System variety ≤ Regulator variety → harness feasible. An LLM generates almost anything (high variety); checking every output is impossible. **Selecting a topology (architecture, layering, allowed patterns) reduces variety to a manageable range.** Constraints reduce the **error space**, not useful output — the agent is freer within bounds because the harness can verify its work.

### Rule

- **The harness must cover the agent's output variety.** If the agent can produce X and the harness can't check X, X is an unregulated escape. Add a check or constrain the agent from producing X.
- **Reducing solution space is a valid harness strategy.** Architecture rules, layer dependencies, allowed patterns — these cut variety to a checkable range.
- **"Stricter constraints = more autonomy" is cybernetically grounded.** The agent is more autonomous within bounds because the harness can verify within bounds.
- **If the harness can't keep up with the agent's variety, either add constraints (reduce variety) or add sensors (increase regulator variety).** Both are valid.

## RIA++ structure (canonical extraction format)

> Source: kangarooking/cangjie-skill. Every concept extracted into Agent Harness Deploy canon should follow the RIA++ six-section structure. A concept without all six sections will be over- or under-applied.

- **R — Reading (source citation):** Direct quote, ≤150 words (≤100 for English). Cite exact location. English: quote original + own translation — **no published translations**. *Grounds in verifiable evidence.*
- **I — Interpretation (own words):** Rewrite core skeleton in your own words, 5-15 lines. Test: can a non-reader understand it? No copying, no rhetoric. *Forces actual understanding.*
- **A1 — Past Application (source cases):** 1-3 cases where the author **personally** used this. Each: problem → how applied → conclusion → result. *Evidence it works in practice.*
- **A2 — Future Trigger ★ (most critical):** Must specify: (1) 3-5 encounter scenarios, (2) language signals, (3) differentiation from adjacent concepts. Goes into the concept's trigger description.

| Good A2 | Bad A2 |
|---------|--------|
| "When the user is stuck on a decision, lists pros but can't conclude; or asks 'how to succeed at X'" | "When the user needs to think" ← too vague, will over-activate |

- **E — Execution (actionable steps):** Convert to 1-2-3 steps, each with a **judgeable completion criterion.** Write conditional branches explicitly. *Gives agent a clear execution path.*
- **B — Boundary (when NOT to use):** Anti-scenarios, author-warned failure modes, blind spots, adjacent methodologies easily confused. *Prevents over-activation. **B separates a tool from a hammer.***

### Application to Agent Harness Deploy canon

| Section | In Agent Harness Deploy canon | Current state |
|---------|-------------------|---------------|
| R (source) | `> Extracted from ...` citation | ✅ Already doing this |
| I (interpretation) | The concept description body | ✅ Already doing this |
| A1 (cases) | Examples in the body | ⚠️ Inconsistent — some have cases, some don't |
| A2 (trigger) | Implicit in applicability | ❌ Missing — no explicit trigger conditions |
| E (execution) | The "Rule" section | ✅ Already doing this |
| B (boundary) | Sometimes in "Rule" as "don't use when..." | ⚠️ Inconsistent |

### Common failure modes

| Failure | Description | Fix |
|---------|-------------|-----|
| **I is just a book summary** | Reads like "the author says X" — copying, not explaining | Rewrite in your own words |
| **A2 too broad** | "When making decisions" — never precisely activated | Give identifiable language signals |
| **E has philosophy, no action** | "Be objective" is not a step; "list 3 worst-case outcomes" is | Convert to concrete actions |
| **Missing B** | No boundaries → over-activated → user disappointed | Always write anti-scenarios |
| **Skip A1, jump I→E** | Loses "author personally used this" evidence → loses authority | Always include source cases |

### Rule

- **Every canon concept should have all six RIA++ sections.** R, I, E mandatory. A1, A2, B mandatory for new extractions; existing canon may be backfilled.
- **A2 (trigger) is the most critical section.** Perfect content + vague trigger = never activated correctly = useless. Spend the most time on A2.
- **B (boundary) prevents over-activation.** Without B, the concept becomes a hammer. Always write anti-scenarios.
- **R (source citation) is non-negotiable.** Every concept must trace to its origin. Enables future verification and harness assumption expiry checks.
- **A1 (source cases) provides authority.** "The author used this in situation X with result Y" > "this sounds like a good idea."
- **E (execution steps) must be concrete.** "Be careful" is not a step. "Run grep for warning keywords before commit" is.

## Rule placement and attention management (Lost in the Middle)

> Source: Wisely Chen's 7 security practices (Liu et al. 2023). LLMs pay less attention to the middle of long documents. Security rules buried at line 300 of a 600-line file are effectively unwritten. **Where a rule lives matters as much as what it says.**

### The principle

Attention distribution in long context:
```
[High attention] ... [Low attention] ... [High attention]
   ^start                              ^end
        ^middle — rules here get ignored
```

### Observed impact

| Metric | Rules buried in middle | Rules at top |
|--------|----------------------|-------------|
| General task success | 45% | 72% |
| Security constraint adherence | 60% | 95% |

### Enforcement

1. **Critical rules go at the top of the entry file.** First 30 lines = "Read First" block.
2. **Entry files are routers, not encyclopedias.** <80 lines. Long content goes to separate files.
3. **Security rules are in their own file** (SECURITY.md / REDLINES.md), referenced from top.
4. **Audit rule placement.** If a rule is violated frequently, check: is it buried? Move it up.

### Rule

- **The first 30 lines of any entry file are the "golden position."** Only critical, non-negotiable
  rules go there.
- **No security rule below line 80 of any file the agent reads at BOOT.** Move it to a dedicated
  security file and reference from the top.
- **Entry file structure: Read First → Routing → Hard Constraints → Workflow.** Security is
  in Read First, not in Hard Constraints (which is still past the golden position).
