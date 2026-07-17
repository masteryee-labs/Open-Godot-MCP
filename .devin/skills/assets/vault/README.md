# .devin/skills/assets/vault/ ??The Local Asset Vault

> **Anti-link-rot architecture.** All external technical configuration mechanics are
> vendored and native-cached here. the deployer never fetches schemas from external
> repositories at runtime. This directory is the immutable local template database.

## Purpose

The vault guarantees that the harness works **even if every external GitHub repo and
reference URL goes offline**. Each file hardcodes the structural mechanics of an external
project, reverse-engineered from its public source. No runtime fetch. No network dependency.

## Files

| File | Hardcodes | Source |
|------|-----------|--------|
| `caveman_template.json` | Caveman token-compression prompt syntax & compression levels | JuliusBrussee/caveman, cheeseonamonkey/Lean-Caveman, JuliusBrussee/caveman-code |
| `agency_framework.toml` | Multi-persona Commander/Worker operational architecture | msitarzewski/agency-agents, obra/superpowers |
| `memory_mcp_schema.json` | Persistent state storage, three-layer memory, deep-memory retrieval, SHA discipline | DeusData/codebase-memory-mcp, kevintsai1202/deep-memory |
| `strix_security_rules.json` | Penetration-testing detection rules, auto-remediation checklist, JSON Risk Contracts | usestrix/strix |
| `graphify_knowledge_spec.json` | Code-to-knowledge-graph parsing definitions, node/edge schema, query patterns | safishamsi/graphify |

## The 5 Technical Pillars (mapped to vault files)

| Pillar | Vault file | Canon file |
|--------|-----------|------------|
| 1. Caveman Token Compression | `caveman_template.json` | `.devin/canon/CAVEMAN_PROTOCOL.md` |
| 2. Commander-Worker Hierarchy | `agency_framework.toml` | `.devin/agents/COMMANDER.md` |
| 3. Loop Engineering & Vault Controls | `memory_mcp_schema.json` (SHA discipline) + `agency_framework.toml` (maker/checker) | `.devin/canon/LOOP_PROTOCOL.md` |
| 4. Deep Repository Memory | `memory_mcp_schema.json` | `.devin/canon/MEMORY_PROTOCOL.md` |
| 5. Sandbox Boundary Re-alignment | `strix_security_rules.json` (risk contracts + sandbox policy) | `.devin/canon/REDLINES.md` |

## How the deployer uses the vault

1. `scripts/sync.py` reads the canonical body from `.devin/canon/`.
2. The vault files are **referenced by** the canon (e.g., CAVEMAN_PROTOCOL.md cites the
   caveman_template.json compression levels). The vault is the **structural source**; the
   canon is the **prose rendering** of that structure for AI consumption.
3. Adapters translate the canon + vault references into each tool's native format.
4. The vault files themselves are copied into each tool's skills/assets directory when
   the tool supports a skills/ or assets/ layout (Claude Code, Devin, Codex). For tools
   that only read a single entry file (Cursor, Claude Desktop), the vault content is
   inlined into the entry file's canonical body.

## Modification policy

- **Vault files are immutable templates.** Do not edit them during a deploy.
- To update a vault file: edit the source canon, update the vault file, run
  `python scripts/sync.py --canon`, then re-deploy.
- Vault file changes require human approval (Red Line #12 ??no modifying canon during deploy).

## Reference links (preserved for attribution, not required at runtime)

### Pillar 1 ??Caveman Token Compression
- https://vocus.cc/article/6a10254ffd897800017eaac1
- https://www.reddit.com/r/ClaudeAI/comments/1sble09/taught_claude_to_talk_like_a_caveman_to_use_75/
- https://github.com/JuliusBrussee/caveman
- https://github.com/cheeseonamonkey/Lean-Caveman-originall-
- https://github.com/JuliusBrussee/caveman-code

### Pillar 2 ??Commander-Worker Hierarchy
- https://github.com/msitarzewski/agency-agents
- https://www.threads.com/@krumjahn/post/DaZuvrPm6Fw
- https://substack.com/@rumjahn
- https://github.com/obra/superpowers

### Pillar 3 ??Loop Engineering & Vault Controls
- https://loops.elorm.xyz/
- https://www.threads.com/@govin999999/post/DaXprW2GFbT
- https://www.threads.com/@govin999999/post/DZwNh9oGC-l
- https://www.threads.com/@aiposthub/post/DZpiC-FAWZR
- https://www.threads.com/@noktvng/post/DZuYFVWDw_E

### Pillar 4 ??Deep Repository Memory
- https://github.com/DeusData/codebase-memory-mcp
- https://github.com/kevintsai1202/deep-memory
- https://kevintsai1202.github.io/deep-memory/
- https://www.threads.com/@ekcheungai/post/DaZ8cfjjHUP
- https://www.threads.com/@lawrenceteh_/post/DaPtdrBCNdO
- https://www.threads.com/@cai.chengkai/post/DaVIELxEni9
- https://www.threads.com/@jsfiend32/post/DaTUVldEzIL

### Pillar 5 ??Sandbox Boundary Re-alignment
- https://github.com/p-e-w/heretic
- https://www.threads.com/@ray.realms/post/DZkWgzXgQZQ

### Vault asset sources
- https://github.com/usestrix/strix (strix_security_rules.json)
- https://github.com/safishamsi/graphify (graphify_knowledge_spec.json)

### Vendored skills (core/assets/skills/)
- https://github.com/alchaincyf/nuwa-skill (nuwa-skill ??cognitive-diversity skill distillation factory, MIT)
  - Vendored at `.devin/skills/nuwa-skill/` with 3 example perspectives (munger/feynman/taleb)
  - See `.devin/skills/nuwa-skill/ATTRIBUTION.md` for full attribution
  - Deployed automatically by the deployer ??no user download needed
