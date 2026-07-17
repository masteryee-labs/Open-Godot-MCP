---
name: harness-sensor
description: "Use when code or files have been modified. Runs structural, build, and syntax checks deterministically. Code changes trigger full sensor; doc-only changes trigger SENSOR-3 only."
---

# Skill: harness-sensor

> Computational verification sensor. Run after code/file changes.
> Two modes: `code` (full sensor) / `doc` (SENSOR-3 only).
> Implements Q3 computational sensors per `.hermes/canon/HARNESS_ENGINEERING.md` and CLI gates per `.hermes/canon/VERIFICATION_PROTOCOL.md`.
> Every failure output must include `Fix: <specific action>` as the last line.

## Trigger
- After any code modification → `code` mode.
- After pure doc/markdown modification → `doc` mode.
- Keywords: harness-sensor, build check, sensor PASS.

## Sensors

### SENSOR-1: Structure (code mode)
- Files claimed changed actually exist at claimed paths.
- `read` each changed file, confirm content present.
- Fail → report path + what's missing.

### SENSOR-2: Build (code mode)
- Run the project's build/typecheck/lint command.
- Pass = green. Fail = report error verbatim + failing file:line.
- If no build system → skip with note "no build system."

### SENSOR-3: Syntax/links (both modes)
- Markdown: check internal links resolve, code fences balanced, headers well-formed.
- Code: syntax check (parse-only if no full build).
- Config files: valid JSON/YAML/TOML parse.

### SENSOR-4: SLOP (doc mode + code report)
- Run `slop-detector` on user-facing prose, naming, and abstractions in the changed set.
- Flag generic names, filler phrases, single-call wrappers, premature interfaces.

### SENSOR-4b: Comment slop (code mode, graceful degradation)
> Detects AI-generated comment slop (explanation bloat, restating the code).
> Implements REDLINES.md #16 + VERIFICATION_PROTOCOL.md "Explanation bloat" axis.
> Source: arXiv 2605.02741 (Volume-Quality Inverse Law).
- **If `uncomment` is installed**: run `uncomment --dry-run <changed_files>` to get an
  AST-precise comment inventory (tree-sitter, 306 languages, 100% accuracy, no false
  positives in strings).
- **If `uncomment` is NOT installed**: skip with note
  `"SENSOR-4b: uncomment not installed — skipping. Install: pip install uncomment. Falling back to comment_checker skill."`
  Then run `comment_checker` skill on changed files as prompt-level fallback.
- Report: comment count per file, lines with comments that restate code.
- **Report-only, never auto-fix.** Maker ≠ checker. Agent or human decides what to delete.
- Fix instruction per finding:
  `"Delete comment at line N — it restates the code. See REDLINES.md #16. Comment discipline: comments explain WHY, not WHAT."`

### SENSOR-4c: Version stacking (code mode, always runs)
> Detects in-file version markers / changelog blocks.
> Implements REDLINES.md #17 + VERIFICATION_PROTOCOL.md "Version stacking" axis.
> Source: arXiv 2606.09090 (Context Rot).
- Scan changed files for: `<!-- v\d+ -->`, `# v\d+ `, `// v\d+ `, `<!-- updated YYYY -->`,
  `# changelog`, `# YYYY-MM-DD ` (date-prefixed edit markers).
- Ignore backtick-wrapped code spans (examples in docs) and single front-matter version
  lines (`> v1.0 | ...`).
- Report: each in-file version marker found.
- Fix instruction per finding:
  `"Remove version marker at line N. Version truth = git history + CHANGELOG.md, not in-file stacking. See REDLINES.md #17."`

## Output
```
## Sensor [PASS/FAIL] mode:[code/doc]
## SENSOR-1 structure: [pass/fail] — evidence
## SENSOR-2 build: [pass/fail/n-a] — command + result
## SENSOR-3 syntax: [pass/fail] — evidence
## SENSOR-4 slop: [pass/fail] — count
## SENSOR-4b comment-slop: [pass/fail/skipped] — count or "uncomment not installed"
## SENSOR-4c version-stacking: [pass/fail] — count
## Failures
- sensor | file:line | issue | fix
Fix: <specific action>
```

## Rules
- Sensor is deterministic. It runs commands. It does not "feel" correctness.
- A sensor FAIL stops the loop. Fix before next iteration.
- Sensor does not replace fresh-context Verifier. Sensor = structural; Verifier = semantic.
- If SENSOR-4 fails, the next iteration should fix the SLOP before moving on.
- **SENSOR-4b is graceful-degradation.** No external tool required. `uncomment` adds Q3
  precision when available; `comment_checker` skill is the always-available fallback.
- **SENSOR-4b is report-only.** Never auto-delete comments. Agent/human reviews and decides.
- **SENSOR-4c always runs** (no external dependency — regex scan). Version stacking is a
  red line (#17), not a suggestion.
