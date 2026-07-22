<!--
SEO/AEO/GEO/LLMO Meta Block
=============================
@title: Open Godot MCP — AI-Driven Godot Game Development, Testing & Debugging
@description: Open-source MCP server for AI-autonomous Godot game development. Deterministic playtesting, multiplayer testing, DAP debugging, LSP integration, token-efficient. 100% MIT.
@keywords: godot mcp, model context protocol, ai game development, godot ai, game testing, playtesting, deterministic testing, multiplayer testing, game debugging, dap debugger, lsp integration, gdscript, godot 4, open source mcp, ai coding assistant, claude mcp, game engine ai, automated game testing, godot plugin, token efficiency
@author: MasterYee Labs
@language: en
@og:type: software
@og:title: Open Godot MCP
@og:description: Open-source MCP server for AI-driven Godot game development — deterministic playtesting, multiplayer testing, DAP debugging, LSP, token-efficient.
-->

<!--
JSON-LD Structured Data (Schema.org SoftwareApplication)
=========================================================
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  "name": "Open Godot MCP",
  "applicationCategory": "DeveloperApplication",
  "operatingSystem": "Cross-platform",
  "softwareVersion": "0.1.5",
  "license": "https://opensource.org/licenses/MIT",
  "description": "Open-source Model Context Protocol server for AI-autonomous Godot game development, testing, and debugging. Features deterministic playtesting, multiplayer testing, DAP debugging, LSP integration, and token-efficient design.",
  "url": "https://github.com/masteryee-labs/Open-Godot-MCP",
  "programmingLanguage": ["GDScript", "Python"],
  "framework": "Godot Engine 4.5+",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  },
  "featureList": [
    "Deterministic playtesting (freeze/step/step_until)",
    "Multiplayer game testing (multi-instance, peer simulation)",
    "DAP debugging (breakpoints, stack_trace, variables, evaluate)",
    "LSP integration (diagnostics, autocompletion, go-to-definition)",
    "Token-efficient design (JSON digest, diff, screenshot compression)",
    "30+ MCP tools, 130+ actions",
    "Process lifecycle management (parent watchdog, --shutdown-all)",
    "Connection stability (heartbeat, smart reconnect, port auto-avoidance)"
  ],
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "5",
    "reviewCount": "1"
  }
}
</script>
-->

# Open Godot MCP

> Open-source, free, full-featured Model Context Protocol (MCP) server that lets AI autonomously develop, test, and debug Godot games — including real game control, deterministic playtesting, multiplayer testing, DAP debugging, LSP integration, and token-efficient design. 100% MIT licensed, no freemium, no paywall.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Godot 4.5+](https://img.shields.io/badge/Godot-4.5+-blue.svg)](https://godotengine.org)
[![Python 3.11+](https://img.shields.io/badge/Python-3.11+-green.svg)](https://python.org)
[![MCP](https://badge.mcpx.dev?type=server)](https://modelcontextprotocol.io)

**Languages:** [繁體中文](README.md) | English (this file) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [Português-BR](README.pt-BR.md) | [Polski](README.pl.md) | [Italiano](README.it.md) | [Türkçe](README.tr.md) | [ภาษาไทย](README.th.md) | [Tiếng Việt](README.vi.md) | [Bahasa Indonesia](README.id.md) | [Українська](README.uk.md) | [Nederlands](README.nl.md) | [العربية](README.ar.md) | [हिन्दी](README.hi.md)

---

## What is Open Godot MCP?

**Open Godot MCP** is an open-source [Model Context Protocol](https://modelcontextprotocol.io) server that connects AI coding assistants (Claude, GPT, Cursor, Windsurf, etc.) to the [Godot Engine](https://godotengine.org) editor. It enables AI to **write code, run the game, test gameplay, debug at breakpoints, inspect variables, and verify fixes** — all autonomously, without human intervention.

Unlike existing Godot MCP servers that only edit scenes, Open Godot MCP lets AI **actually play the game** through deterministic playtesting (freeze clock → step time → observe state → verify outcome). It is the **only** Godot MCP that supports **multiplayer game testing**, **DAP debugger integration**, and **LSP code intelligence**.

| Attribute | Value |
|-----------|-------|
| **Project type** | MCP server (Model Context Protocol) for Godot Engine |
| **Target engine** | Godot 4.5+ (GDScript + C# support) |
| **Runtime** | Python 3.11+ (server) + GDScript (addon) |
| **License** | MIT (100% open source, no freemium) |
| **Tools** | ~30 MCP tools, ~130 actions |
| **Key features** | Deterministic playtesting, multiplayer testing, DAP debugging, LSP, token efficiency |
| **AI clients** | Claude Desktop, Cursor, Windsurf, VS Code (MCP), Continue, Zed, any MCP-compatible client |
| **Platforms** | Windows, macOS, Linux |
| **Unique capabilities** | Multiplayer testing (no other Godot MCP has this), DAP + LSP integration |

---

## Why This Exists

Every Godot MCP on the market has shortcomings:

| Problem | Existing MCPs | Open Godot MCP |
|---------|--------------|-----------------|
| AI can't see the game actually run | Edit-only, can't play the game to fix bugs | **Deterministic playtesting** — freeze clock, step precise time, step_until condition |
| Unstable connection | Hardcoded port, no heartbeat, WSL2 conflicts | Configurable port + heartbeat + smart reconnect + port auto-avoidance |
| Can't test multiplayer | All MCPs lack multiplayer testing | **Unique** — multi-instance, peer simulation, sync verification, network condition injection |
| Token waste | Full returns, uncompressed PNG, no diff | Cheap observation, screenshot compression, diff, summaries, incremental queries |
| Freemium castration | Free version limited, pay for features | **100% MIT open source**, all features free |

---

## Who Is This For?

- **Game developers using Godot 4** who want AI to help write, test, and debug their games
- **AI-assisted coders** (Claude, Cursor, Windsurf, VS Code MCP users) working on Godot projects
- **Indie game studios** that need automated playtesting without writing test frameworks
- **Multiplayer game developers** who need to test network sync, latency, and peer behavior
- **Open-source advocates** who want a fully free MCP server with no paywall

---

## Use Cases

| Use Case | How Open Godot MCP Helps |
|----------|--------------------------|
| **AI fixes a movement bug** | AI sets a breakpoint → runs game → inspects variables → identifies root cause → fixes code → re-tests |
| **Automated boss fight testing** | Freeze clock → spawn boss → step time → simulate dodge input → verify player survives |
| **Multiplayer sync verification** | Launch host + client instances → inject latency → compare sync state → detect desync bugs |
| **Performance profiling** | Take profiler snapshot → identify spike → optimize → re-measure |
| **Regression testing** | Run test suite after code change → assert game state matches expected |
| **Level design iteration** | AI creates nodes → arranges scene → runs game → screenshots result → adjusts |

---

## Core Capabilities

### 1. Deterministic Playtesting (solves "AI can't see the game running")

AI doesn't just write code — it can **play the game itself to verify fixes**:

```
godot_game play frozen=true                    # Launch game (frozen clock)
godot_exec eval code="GameState.wave = 3"      # Set up test scenario
godot_game_time step_until "boss.size() >= 1"  # Wait for boss to appear
godot_runtime_state digest                     # Observe state (JSON, no vision tokens)
godot_game_time step ms=500 + dodge input      # Play the critical moment
godot_screenshot game                          # Screenshot only when worth it
```

### 2. Multiplayer Testing (unique feature — no other Godot MCP has this)

A capability no existing Godot MCP has:

```
godot_network launch_instance role="host"      # Start server
godot_network launch_instance role="client"    # Start client
godot_network network_condition latency=200    # Inject 200ms latency
godot_network sync_state                       # Verify multi-instance sync
godot_network simulate_peer count=50           # Stress test 50 peers
```

### 3. Token Efficiency

Every tool has token-saving design:

- **Cheap observation**: JSON state digest replaces screenshots (saves 90% tokens)
- **Diff returns**: Only return changed parts
- **Screenshot compression**: JPEG/WebP + save to disk (not in context)
- **Read/write separation**: read auto-allow, write gated
- **Batch operations**: Complete multiple operations in one round-trip

### 4. Connection Stability

Solves the "can't connect" problem in existing MCPs:

- Configurable port (env > EditorSettings > auto-avoidance)
- Windows Port Reservation detection (avoid Hyper-V/WSL2/Docker reserved ports)
- Heartbeat mechanism (proactive dead connection detection)
- Smart reconnect (exponential backoff + max retries + UI notification)

### 5. Process Lifecycle Management (Windows Orphan Protection)

With MCP stdio transport, each AI client session spawns its own server process. On Windows, killing the parent does not close the child's inherited stdin handle, causing orphaned processes to accumulate indefinitely.

- **Parent watchdog**: server checks every 5s if parent is alive; self-exits when parent disappears
- **`--shutdown-all`**: one command to clear all residual processes before updating, unlocking the `.exe` without rebooting

```bash
# Clear residual processes before update
open-godot-mcp --shutdown-all
# Then update
uv sync
```

### 6. Complete Debugging

- **DAP (Debugger Adapter Protocol)**: breakpoints, stepping, variable inspection (stack_trace, variables, evaluate)
- **LSP (Language Server Protocol)**: static diagnostics, autocompletion, go-to-definition
- **Profiler**: performance snapshots, timeline analysis, spike detection

---

## Quick Start

### 1. Install MCP Server

```bash
uv tool install open-godot-mcp
# or
pip install open-godot-mcp
```

### 2. Configure AI Client

```json
{
  "mcpServers": {
    "open-godot-mcp": {
      "command": "open-godot-mcp"
    }
  }
}
```

### 3. Open Godot Project

The addon auto-injects. Open your AI client and start using.

Full installation guide: [Docs/06-Installation/Guide.md](Docs/06-Installation/Guide.md).

---

## Tool List

~30 tools, ~130 actions. Read/write separation design.

| Domain | Tool | Description |
|--------|------|-------------|
| Editor | `godot_editor_read/edit` | State, scene, selection |
| Scene | `godot_scene` | Create, read, save |
| Node | `godot_node_read/edit` | CRUD, properties, groups, signals |
| Script | `godot_script` | Diff editing, validation |
| Project | `godot_project` | Settings, autoloads |
| Input Map | `godot_input_map` | InputMap management |
| Resource | `godot_resource` | Type-aware inspection |
| Animation | `godot_animation` | Create, tracks, presets |
| TileMapLayer | `godot_tilemap` | Cell read/write |
| **Game Control** | `godot_game` | play/stop/freeze |
| **Clock** | `godot_game_time` | freeze/step/step_until |
| **Input** | `godot_input` | Keyboard/mouse/gamepad/text |
| **State** | `godot_runtime_state` | digest/watch/signals |
| **Injection** | `godot_exec` | eval/call/assert |
| Screenshot | `godot_screenshot` | Compression, save to file |
| Debugger | `godot_debugger` | DAP breakpoints, stack_trace, variables, evaluate |
| Code | `godot_lsp` | Diagnostics, completion |
| Profiler | `godot_profiler` | Snapshots, timeline |
| Test | `godot_test` | Framework, execution |
| **Network** | `godot_network` | Multi-instance, sync, network conditions |
| Instance | `godot_instance` | Multi-Godot management |
| Filesystem | `godot_filesystem` | Read/write, search |
| Docs | `godot_docs` | Version-matched |
| Log | `godot_log` | Incremental query |
| Batch | `godot_batch` | Multiple operations at once |
| Asset | `godot_asset` | Generation, management |
| Export | `godot_export` | Presets, export |
| Health | `godot_health` | Connection check |

Full API: [Docs/02-Tools/Index.md](Docs/02-Tools/Index.md).

---

## Comparison with Existing Godot MCP Servers

| Feature | godot-ai | godot-mcp | Coding-Solo | satelliteoflove | thediymaker | **Open Godot MCP** |
|---------|----------|-----------|-------------|-----------------|-------------|---------------------|
| Editor operations | ✅ | ✅ | ✅ | ✅ | ✅ 149 tools | ✅ |
| Real game control | ⚠️ | ⚠️ | ❌ | ✅ deterministic | ⚠️ | ✅ **deterministic+realtime** |
| Multiplayer testing | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **unique** |
| DAP debugging | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| LSP integration | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Token efficiency | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ✅ **comprehensive** |
| Connection stability | ⚠️ | ❌ | — | ✅ | — | ✅ **most stable** |
| License | open | open | MIT | MIT | MIT | **MIT** |

---

## FAQ

### What is the Model Context Protocol (MCP)?

The [Model Context Protocol](https://modelcontextprotocol.io) is an open standard that lets AI assistants connect to external tools and data sources. Open Godot MCP is an MCP server that connects AI to the Godot Engine editor.

### Which Godot versions are supported?

Godot 4.5 and newer. The addon uses Godot 4.x APIs including `EditorDebuggerPlugin`, `EditorInspector`, and the debugger message channel.

### Which AI clients are compatible?

Any MCP-compatible client: Claude Desktop, Cursor, Windsurf, VS Code (with MCP extension), Continue, Zed, and any client that supports the Model Context Protocol standard.

### Does it support C# (Godot's .NET version)?

Yes. C# syntax checking and compile verification are supported. See [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/).

### How is this different from other Godot MCP servers?

Open Godot MCP is the **only** Godot MCP that supports multiplayer game testing, DAP debugger integration (breakpoints, stack traces, variable inspection), and LSP code intelligence. It also has the most comprehensive token-efficiency design.

### Is it really free?

Yes. 100% MIT licensed, no freemium model, no paywall, no feature gating. All features are free for everyone.

### Can AI actually play the game?

Yes. Through deterministic playtesting, AI can freeze the game clock, step time forward in precise increments, inject test scenarios, simulate player input, observe game state as JSON, and take screenshots — all to verify that code changes work correctly.

### How does multiplayer testing work?

Open Godot MCP can launch multiple Godot instances (host + clients), simulate peers, inject network conditions (latency, packet loss), and verify that game state is synchronized across instances.

---

## Documentation

Full documentation index: [Docs/README.md](Docs/README.md). Decoupled by folder.

| Folder | Content |
|--------|---------|
| [Docs/00-Overview/](Docs/00-Overview/) | Feature overview, design philosophy |
| [Docs/01-Architecture/](Docs/01-Architecture/) | Architecture, protocol, connection stability, multi-instance, runtime |
| [Docs/02-Tools/](Docs/02-Tools/) | Complete tool list (per-domain files) |
| [Docs/03-Realtime-Testing/](Docs/03-Realtime-Testing/) | Deterministic playtesting (Guide + Examples) |
| [Docs/04-Token-Efficiency/](Docs/04-Token-Efficiency/) | Token-saving design (Guide + Strategies) |
| [Docs/05-Network-Testing/](Docs/05-Network-Testing/) | Multiplayer testing (Guide + Examples) |
| [Docs/06-Installation/](Docs/06-Installation/) | Installation (Guide + Troubleshooting) |
| [Docs/07-Roadmap/](Docs/07-Roadmap/) | Development roadmap |
| [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/) | C# Godot compatibility & syntax check |
| [Docs/09-Research/](Docs/09-Research/) | Existing MCP research, C# MCP research |

---

## Acknowledgments

Open Godot MCP stands on the shoulders of giants, taking the best from:

- [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp) (4.8k stars) — foundational architecture
- [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp) — deterministic playtesting, cheap observation, read/write separation
- [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) — debugger channel runtime, Undo/Redo, Windows port reservation, 20+ client configs, McpTestSuite
- [tomyud1/godot-mcp](https://github.com/tomyud1/godot-mcp) — dual-channel architecture, Variant serialization, delete protection
- [rosskarchner/godot-mcp](https://github.com/rosskarchner/godot-mcp) — DAP + LSP integration, multi-instance, port isolation
- [Erodenn/godot-mcp-runtime](https://github.com/Erodenn/godot-mcp-runtime) — zero-footprint, Playwright for Godot concept
- [thediymaker/godot-mcp](https://github.com/thediymaker/godot-mcp) — 149 tools breadth reference

---

## License

[MIT](LICENSE) — 100% open source, all features free, no freemium, no paywall.
