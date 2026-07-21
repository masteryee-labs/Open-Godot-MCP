<!--
SEO/AEO/GEO/LLMO Meta Block
=============================
@title: Open Godot MCP — AI-gedreven Godot-gameontwikkeling, testen & debuggen
@description: Open-source MCP-server voor AI-autonome Godot-gameontwikkeling. Deterministische playtests, multiplayer-testen, DAP-debugging, LSP-integratie, token-efficiënt. 100% MIT.
@keywords: godot mcp, model context protocol, ai game development, godot ai, game testing, playtesting, deterministische testing, multiplayer-testen, game debugging, dap debugger, lsp integratie, gdscript, godot 4, open source mcp, ai coding assistant, claude mcp, game engine ai, geautomatiseerd game-testen, godot plugin, token efficiëntie
@author: MasterYee Labs
@language: nl
@og:type: software
@og:title: Open Godot MCP
@og:description: Open-source MCP-server voor AI-gedreven Godot-gameontwikkeling — deterministische playtests, multiplayer-testen, DAP-debugging, LSP, token-efficiënt.
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
  "softwareVersion": "0.1.0",
  "license": "https://opensource.org/licenses/MIT",
  "description": "Open-source Model Context Protocol-server voor AI-autonome Godot-gameontwikkeling, testen en debuggen. Bevat deterministische playtests, multiplayer-testen, DAP-debugging, LSP-integratie en token-efficiënt ontwerp.",
  "url": "https://github.com/masteryee-labs/Open-Godot-MCP",
  "programmingLanguage": ["GDScript", "Python"],
  "framework": "Godot Engine 4.5+",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  },
  "featureList": [
    "Deterministische playtests (freeze/step/step_until)",
    "Multiplayer-game-testen (multi-instance, peer-simulatie)",
    "DAP-debugging (breakpoints, stack_trace, variables, evaluate)",
    "LSP-integratie (diagnostiek, autocompletion, go-to-definition)",
    "Token-efficiënt ontwerp (JSON-digest, diff, screenshotcompressie)",
    "30+ MCP-tools, 130+ acties",
    "Verbindingsstabiliteit (heartbeat, slim herverbinden, poort-automatische vermijding)"
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

> Open-source, gratis, volledig uitgeruste Model Context Protocol (MCP)-server waarmee AI autonoom Godot-games ontwikkelt, test en debugt — inclusief echte gamebesturing, deterministische playtests, multiplayer-testen, DAP-debugging, LSP-integratie en token-efficiënt ontwerp. 100% MIT-gelicentieerd, geen freemium, geen betaalmuur.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Godot 4.5+](https://img.shields.io/badge/Godot-4.5+-blue.svg)](https://godotengine.org)
[![Python 3.11+](https://img.shields.io/badge/Python-3.11+-green.svg)](https://python.org)
[![MCP](https://badge.mcpx.dev?type=server)](https://modelcontextprotocol.io)

**Languages:** [繁體中文](README.md) | English (this file) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [Português-BR](README.pt-BR.md) | [Polski](README.pl.md) | [Italiano](README.it.md) | [Türkçe](README.tr.md) | [ภาษาไทย](README.th.md) | [Tiếng Việt](README.vi.md) | [Bahasa Indonesia](README.id.md) | [Українська](README.uk.md) | [Nederlands](README.nl.md) | [العربية](README.ar.md) | [हिन्दी](README.hi.md)

---

## Wat is Open Godot MCP?

**Open Godot MCP** is een open-source [Model Context Protocol](https://modelcontextprotocol.io)-server die AI-coding-assistanten (Claude, GPT, Cursor, Windsurf, enz.) verbindt met de [Godot Engine](https://godotengine.org)-editor. Het stelt AI in staat om **code te schrijven, de game te draaien, gameplay te testen, te debuggen op breakpoints, variabelen te inspecteren en oplossingen te verifiëren** — allemaal autonoom, zonder menselijke tussenkomst.

In tegenstelling tot bestaande Godot-MCP-servers die alleen scenes bewerken, laat Open Godot MCP AI **de game echt spelen** via deterministische playtests (klok bevriezen → tijd stappen → status observeren → uitkomst verifiëren). Het is de **enige** Godot-MCP die **multiplayer-game-testen**, **DAP-debugger-integratie** en **LSP-code-intelligentie** ondersteunt.

| Attribuut | Waarde |
|-----------|-------|
| **Projecttype** | MCP-server (Model Context Protocol) voor Godot Engine |
| **Doel-engine** | Godot 4.5+ (GDScript + C#-ondersteuning) |
| **Runtime** | Python 3.11+ (server) + GDScript (addon) |
| **Licentie** | MIT (100% open source, geen freemium) |
| **Tools** | ~30 MCP-tools, ~130 acties |
| **Kernfuncties** | Deterministische playtests, multiplayer-testen, DAP-debugging, LSP, token-efficiëntie |
| **AI-clients** | Claude Desktop, Cursor, Windsurf, VS Code (MCP), Continue, Zed, elke MCP-compatibele client |
| **Platforms** | Windows, macOS, Linux |
| **Unieke mogelijkheden** | Multiplayer-testen (geen andere Godot-MCP heeft dit), DAP + LSP-integratie |

---

## Waarom dit bestaat

Elke Godot-MCP op de markt heeft tekortkomingen:

| Probleem | Bestaande MCP's | Open Godot MCP |
|---------|--------------|-----------------|
| AI kan de game niet echt zien draaien | Alleen bewerken, kan de game niet spelen om bugs op te lossen | **Deterministische playtests** — klok bevriezen, tijd precies stappen, step_until-voorwaarde |
| Onstabiele verbinding | Hardcoded poort, geen heartbeat, WSL2-conflicten | Configureerbare poort + heartbeat + slim herverbinden + poort-automatische vermijding |
| Geen multiplayer-test mogelijk | Alle MCP's missen multiplayer-testen | **Uniek** — multi-instance, peer-simulatie, synchronisatieverificatie, netwerkconditie-injectie |
| Token-verspilling | Volledige returns, ongecomprimeerde PNG, geen diff | Goedkope observatie, screenshotcompressie, diff, samenvattingen, incrementele queries |
| Freemium-verminking | Gratis versie beperkt, betalen voor functies | **100% MIT open source**, alle functies gratis |

---

## Voor wie is dit?

- **Game-ontwikkelaars die Godot 4 gebruiken** en willen dat AI helpt bij het schrijven, testen en debuggen van hun games
- **AI-ondersteunde coders** (Claude, Cursor, Windsurf, VS Code MCP-gebruikers) die aan Godot-projecten werken
- **Indie-gamestudio's** die geautomatiseerde playtests nodig hebben zonder testframeworks te schrijven
- **Multiplayer-game-ontwikkelaars** die netwerksynchronisatie, latentie en peer-gedrag moeten testen
- **Open-source-voorstanders** die een volledig gratis MCP-server willen zonder betaalmuur

---

## Use cases

| Use case | Hoe Open Godot MCP helpt |
|----------|--------------------------|
| **AI lost een bewegingsbug op** | AI stelt breakpoint in → draait game → inspecteert variabelen → identificeert oorzaak → lost code op → test opnieuw |
| **Geautomatiseerde boss-fight-test** | Klok bevriezen → boss spawnen → tijd stappen → dodge-input simuleren → verifiëren dat speler overleeft |
| **Multiplayer-sync-verificatie** | Host + client-instances starten → latentie injecteren → sync-status vergelijken → desync-bugs detecteren |
| **Prestatieprofilering** | Profiler-snapshot nemen → piek identificeren → optimaliseren → opnieuw meten |
| **Regressietesten** | Testsuite draaien na codewijziging → asserten dat game-status overeenkomt met verwacht |
| **Level-design-iteratie** | AI maakt nodes aan → scene rangschikken → game draaien → screenshot resultaat → aanpassen |

---

## Kernmogelijkheden

### 1. Deterministische playtests (lost "AI kan de game niet zien draaien" op)

AI schrijft niet alleen code — het kan **de game zelf spelen om oplossingen te verifiëren**:

```
godot_game play frozen=true                    # Start game (klok bevroren)
godot_exec eval code="GameState.wave = 3"      # Testscenario instellen
godot_game_time step_until "boss.size() >= 1"  # Wachten tot boss verschijnt
godot_runtime_state digest                     # Status observeren (JSON, geen vision-tokens)
godot_game_time step ms=500 + dodge input      # Het kritieke moment spelen
godot_screenshot game                          # Screenshot alleen als het de moeite waard is
```

### 2. Multiplayer-testen (unieke functie — geen andere Godot-MCP heeft dit)

Een mogelijkheid die geen enkele bestaande Godot-MCP heeft:

```
godot_network launch_instance role="host"      # Server starten
godot_network launch_instance role="client"    # Client starten
godot_network network_condition latency=200    # 200ms latentie injecteren
godot_network sync_state                       # Multi-instance synchronisatie verifiëren
godot_network simulate_peer count=50           # Stresstest met 50 peers
```

### 3. Token-efficiëntie

Elke tool heeft tokenbesparend ontwerp:

- **Goedkope observatie**: JSON-statusdigest vervangt screenshots (bespaart 90% tokens)
- **Diff-returns**: Alleen gewijzigde delen retourneren
- **Screenshotcompressie**: JPEG/WebP + op schijf opslaan (niet in context)
- **Lees/scheiding van schrijven**: lezen automatisch toegestaan, schrijven beperkt
- **Batchoperaties**: Meerdere operaties in één round-trip voltooien

### 4. Verbindingsstabiliteit

Lost het "kan niet verbinden"-probleem op in bestaande MCP's:

- Configureerbare poort (omgeving > EditorSettings > automatische vermijding)
- Windows-poortreservatiedetectie (vermijd Hyper-V/WSL2/Docker gereserveerde poorten)
- Heartbeat-mechanisme (proactieve dode-verbindingdetectie)
- Slim herverbinden (exponentiële backoff + max retries + UI-melding)

### 5. Volledige debugging

- **DAP (Debugger Adapter Protocol)**: breakpoints, stepping, variabele-inspectie (stack_trace, variables, evaluate)
- **LSP (Language Server Protocol)**: statische diagnostiek, autocompletion, go-to-definition
- **Profiler**: prestatiesnapshots, tijdlijnanalyse, spiekdetectie

---

## Snel aan de slag

### 1. MCP-server installeren

```bash
uv tool install open-godot-mcp
# of
pip install open-godot-mcp
```

### 2. AI-client configureren

```json
{
  "mcpServers": {
    "open-godot-mcp": {
      "command": "open-godot-mcp"
    }
  }
}
```

### 3. Godot-project openen

De addon injecteert automatisch. Open je AI-client en begin met gebruiken.

Volledige installatiehandleiding: [Docs/06-Installation/Guide.md](Docs/06-Installation/Guide.md).

---

## Toollijst

~30 tools, ~130 acties. Lees/schrijf-scheidingsontwerp.

| Domein | Tool | Beschrijving |
|--------|------|-------------|
| Editor | `godot_editor_read/edit` | Status, scene, selectie |
| Scene | `godot_scene` | Aanmaken, lezen, opslaan |
| Node | `godot_node_read/edit` | CRUD, eigenschappen, groepen, signalen |
| Script | `godot_script` | Diff-bewerking, validatie |
| Project | `godot_project` | Instellingen, autoloads |
| Input Map | `godot_input_map` | InputMap-beheer |
| Resource | `godot_resource` | Type-bewuste inspectie |
| Animatie | `godot_animation` | Aanmaken, tracks, presets |
| TileMapLayer | `godot_tilemap` | Cel lezen/schrijven |
| **Gamebesturing** | `godot_game` | play/stop/freeze |
| **Klok** | `godot_game_time` | freeze/step/step_until |
| **Input** | `godot_input` | Toetsenbord/muis/gamepad/tekst |
| **Status** | `godot_runtime_state` | digest/watch/signals |
| **Injectie** | `godot_exec` | eval/call/assert |
| Screenshot | `godot_screenshot` | Compressie, op bestand opslaan |
| Debugger | `godot_debugger` | DAP-breakpoints, stack_trace, variables, evaluate |
| Code | `godot_lsp` | Diagnostiek, completion |
| Profiler | `godot_profiler` | Snapshots, tijdlijn |
| Test | `godot_test` | Framework, uitvoering |
| **Netwerk** | `godot_network` | Multi-instance, sync, netwerkcondities |
| Instance | `godot_instance` | Multi-Godot-beheer |
| Bestandssysteem | `godot_filesystem` | Lezen/schrijven, zoeken |
| Docs | `godot_docs` | Versie-gekoppeld |
| Log | `godot_log` | Incrementele query |
| Batch | `godot_batch` | Meerdere operaties tegelijk |
| Asset | `godot_asset` | Generatie, beheer |
| Export | `godot_export` | Presets, export |
| Health | `godot_health` | Verbindingscontrole |

Volledige API: [Docs/02-Tools/Index.md](Docs/02-Tools/Index.md).

---

## Vergelijking met bestaande Godot-MCP-servers

| Functie | godot-ai | godot-mcp | Coding-Solo | satelliteoflove | thediymaker | **Open Godot MCP** |
|---------|----------|-----------|-------------|-----------------|-------------|---------------------|
| Editor-operaties | ✅ | ✅ | ✅ | ✅ | ✅ 149 tools | ✅ |
| Echte gamebesturing | ⚠️ | ⚠️ | ❌ | ✅ deterministisch | ⚠️ | ✅ **deterministisch+realtime** |
| Multiplayer-testen | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **uniek** |
| DAP-debugging | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| LSP-integratie | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Token-efficiëntie | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ✅ **compleet** |
| Verbindingsstabiliteit | ⚠️ | ❌ | — | ✅ | — | ✅ **meest stabiel** |
| Licentie | open | open | MIT | MIT | MIT | **MIT** |

---

## FAQ

### Wat is het Model Context Protocol (MCP)?

Het [Model Context Protocol](https://modelcontextprotocol.io) is een open standaard die AI-assistanten verbindt met externe tools en gegevensbronnen. Open Godot MCP is een MCP-server die AI verbindt met de Godot Engine-editor.

### Welke Godot-versies worden ondersteund?

Godot 4.5 en nieuwer. De addon gebruikt Godot 4.x-API's inclusief `EditorDebuggerPlugin`, `EditorInspector` en het debugger-berichtkanaal.

### Welke AI-clients zijn compatibel?

Elke MCP-compatibele client: Claude Desktop, Cursor, Windsurf, VS Code (met MCP-extensie), Continue, Zed, en elke client die de Model Context Protocol-standaard ondersteunt.

### Ondersteunt het C# (Godot's .NET-versie)?

Ja. C#-syntaxiscontrole en compileerverificatie worden ondersteund. Zie [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/).

### Hoe verschilt dit van andere Godot-MCP-servers?

Open Godot MCP is de **enige** Godot-MCP die multiplayer-game-testen, DAP-debugger-integratie (breakpoints, stack traces, variabele-inspectie) en LSP-code-intelligentie ondersteunt. Het heeft ook het meest complete token-efficiëntie-ontwerp.

### Is het echt gratis?

Ja. 100% MIT-gelicentieerd, geen freemium-model, geen betaalmuur, geen functie-beperkingen. Alle functies zijn gratis voor iedereen.

### Kan AI de game echt spelen?

Ja. Via deterministische playtests kan AI de game-klok bevriezen, tijd in precieze stappen vooruit zetten, testscenario's injecteren, speler-input simuleren, game-status als JSON observeren en screenshots nemen — allemaal om te verifiëren dat codewijzigingen correct werken.

### Hoe werkt multiplayer-testen?

Open Godot MCP kan meerdere Godot-instances starten (host + clients), peers simuleren, netwerkcondities injecteren (latentie, pakketverlies) en verifiëren dat de game-status gesynchroniseerd is across instances.

---

## Documentatie

Volledige documentatie-index: [Docs/README.md](Docs/README.md). Per map ontkoppeld.

| Map | Inhoud |
|--------|---------|
| [Docs/00-Overview/](Docs/00-Overview/) | Functieoverzicht, ontwerpfilosofie |
| [Docs/01-Architecture/](Docs/01-Architecture/) | Architectuur, protocol, verbindingsstabiliteit, multi-instance, runtime |
| [Docs/02-Tools/](Docs/02-Tools/) | Volledige toollijst (per domein bestanden) |
| [Docs/03-Realtime-Testing/](Docs/03-Realtime-Testing/) | Deterministische playtests (Handleiding + Voorbeelden) |
| [Docs/04-Token-Efficiency/](Docs/04-Token-Efficiency/) | Tokenbesparend ontwerp (Handleiding + Strategieën) |
| [Docs/05-Network-Testing/](Docs/05-Network-Testing/) | Multiplayer-testen (Handleiding + Voorbeelden) |
| [Docs/06-Installation/](Docs/06-Installation/) | Installatie (Handleiding + Probleemoplossing) |
| [Docs/07-Roadmap/](Docs/07-Roadmap/) | Ontwikkelingsroadmap |
| [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/) | C# Godot-compatibiliteit & syntaxiscontrole |
| [Docs/09-Research/](Docs/09-Research/) | Bestaande MCP-onderzoek, C# MCP-onderzoek |

---

## Erkenningen

Open Godot MCP staat op de schouders van reuzen en haalt het beste uit:

- [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp) (4.8k sterren) — fundamentele architectuur
- [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp) — deterministische playtests, goedkope observatie, lees/schrijf-scheiding
- [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) — debugger-kanaal-runtime, Undo/Redo, Windows-poortreservatie, 20+ clientconfiguraties, McpTestSuite
- [tomyud1/godot-mcp](https://github.com/tomyud1/godot-mcp) — dual-channel-architectuur, Variant-serialisatie, verwijderbescherming
- [rosskarchner/godot-mcp](https://github.com/rosskarchner/godot-mcp) — DAP + LSP-integratie, multi-instance, poortisolatie
- [Erodenn/godot-mcp-runtime](https://github.com/Erodenn/godot-mcp-runtime) — zero-footprint, Playwright-voor-Godot-concept
- [thediymaker/godot-mcp](https://github.com/thediymaker/godot-mcp) — 149-tools-breedtereferentie

---

## Licentie

[MIT](LICENSE) — 100% open source, alle functies gratis, geen freemium, geen betaalmuur.
