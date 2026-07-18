# GitHub Repository Metadata — Open Godot MCP

> This file contains the recommended GitHub repository description, topics, About section, and social preview text for SEO/AEO/GEO/LLMO optimization.
> Copy these into the GitHub repo settings (Settings → General → Description, Topics, About).

---

## Repository Description (350 chars max)

```
Open-source MCP server for AI-autonomous Godot game development. Deterministic playtesting, multiplayer testing, DAP debugging, LSP, token-efficient. 100% MIT.
```

**Alternative (shorter, 160 chars for social previews):**
```
Open-source MCP server for AI-driven Godot game dev — deterministic playtesting, multiplayer testing, DAP debugging, LSP, token-efficient. MIT.
```

---

## Repository Topics (max 20)

Copy these into GitHub Settings → Topics:

```
godot
godot-engine
godot-4
mcp
model-context-protocol
ai
game-development
game-testing
playtesting
debugging
dap
lsp
gdscript
game-debugger
multiplayer
automated-testing
ai-coding-assistant
claude-mcp
open-source
mit-license
```

---

## About Section (GitHub sidebar)

```
🎮 Open-source MCP server for AI-autonomous Godot game development, testing & debugging.

✨ Unique features (no other Godot MCP has these):
  • Deterministic playtesting (freeze/step/step_until)
  • Multiplayer game testing (multi-instance, peer simulation)
  • DAP debugger (breakpoints, stack_trace, variables, evaluate)
  • LSP integration (diagnostics, autocompletion)
  • Token-efficient design (JSON digest, diff, screenshot compression)

📦 30+ MCP tools, 130+ actions
🔧 Godot 4.5+ | Python 3.11+ | GDScript + C#
🤖 Works with Claude, Cursor, Windsurf, VS Code, Zed, any MCP client
💻 Windows, macOS, Linux
📄 100% MIT — no freemium, no paywall

🌐 README in 20 languages
```

---

## Social Preview Image Text (for OG image / GitHub social preview)

If you create a social preview image (1280×640px), use this text:

```
Open Godot MCP

AI-Driven Godot Game Development,
Testing & Debugging

✅ Deterministic Playtesting
✅ Multiplayer Game Testing
✅ DAP Debugging
✅ LSP Integration
✅ Token-Efficient Design

100% MIT Open Source | 20 Languages
```

---

## GitHub SEO/AEO/GEO/LLMO Checklist

### SEO (Search Engine Optimization)
- [x] Repository description contains primary keywords: "godot", "mcp", "ai", "game development", "testing", "debugging"
- [x] 20 topics covering all major search terms
- [x] README has H1 with project name
- [x] README has keyword-rich tagline in first paragraph
- [x] README has structured tables (Google loves tables for featured snippets)
- [x] README has FAQ section (targets "People Also Ask" boxes)
- [x] README has comparison table (targets "best godot mcp", "godot mcp comparison" queries)
- [x] All 20 language versions have localized keywords in meta block
- [x] Internal links to Docs/ folders (improves crawling)
- [x] External links to Godot Engine, MCP protocol (authoritative outbound links)

### AEO (Answer Engine Optimization)
- [x] FAQ section with 8 Q&A pairs (directly answerable by AI assistants)
- [x] "What is Open Godot MCP?" section (answers the primary question)
- [x] "Who Is This For?" section (answers audience questions)
- [x] "Use Cases" table (answers "what can I do with it?")
- [x] Comparison table (answers "how does it compare to X?")
- [x] Quick Start section (answers "how do I install it?")
- [x] Tool list table (answers "what tools are available?")
- [x] Attribute table (answers "what are the specs?")

### GEO (Generative Engine Optimization)
- [x] JSON-LD structured data (Schema.org SoftwareApplication)
- [x] Feature list in structured format
- [x] Clear entity definitions (what it is, what it does)
- [x] Relationship to known entities (Godot, MCP, Claude, Cursor)
- [x] Unique value proposition stated explicitly ("only Godot MCP that supports...")
- [x] Quantified claims ("30+ tools", "130+ actions", "20 languages", "saves 90% tokens")
- [x] Attribution to known projects (helps LLMs establish credibility)

### LLMO (LLM Model Optimization)
- [x] HTML comment meta block with @keywords (machine-readable)
- [x] JSON-LD structured data (machine-readable)
- [x] Consistent entity naming across all 20 languages
- [x] Code examples that LLMs can reproduce
- [x] Clear section headers (H2/H3) for chunk retrieval
- [x] Table format for structured data (LLMs parse tables well)
- [x] FAQ in Q&A format (matches LLM retrieval patterns)
- [x] Language-agnostic technical terms (tool names, commands stay in English)
- [x] @language tag in meta block for each language version

---

## Recommended GitHub Settings

1. **Settings → General → Description**: Paste the repository description above
2. **Settings → General → Topics**: Add all 20 topics listed above
3. **Settings → General → Features**: Enable Issues, Wiki, Discussions
4. **Repository → About (sidebar)**: Paste the About section text, add website URL if any
5. **Settings → Social preview**: Upload a 1280×640 image with the social preview text
6. **Settings → Pages**: Enable GitHub Pages if you want a docs site (use Docs/ folder)
7. **Release tags**: Use semantic versioning (v0.1.0, v0.2.0, etc.)
8. **LICENSE**: Already MIT — ensure it's in the repo root (✅ exists)
9. **CITATION.cff**: Consider adding for academic citations
10. **.github/FUNDING.yml**: Add if you want sponsorship

---

## Recommended GitHub Issues Templates

Create `.github/ISSUE_TEMPLATE/` with:
- `bug_report.md` — Bug report template
- `feature_request.md` — Feature request template
- `question.md` — Question/discussion template

Create `.github/ISSUE_TEMPLATE/config.yml`:
```yaml
blank_issues_enabled: false
contact_links:
  - name: Open Godot MCP Discussions
    url: https://github.com/masteryee-labs/Open-Godot-MCP/discussions
    about: Ask questions and discuss with the community
```

---

## Recommended GitHub Actions (CI/CD)

Create `.github/workflows/` with:
- `ci.yml` — Run pytest + ruff + mypy on push/PR
- `release.yml` — Auto-publish to PyPI on tag push
- `docs.yml` — Deploy Docs/ to GitHub Pages

---

*This file is a reference guide. Apply the settings manually in the GitHub web UI.*
