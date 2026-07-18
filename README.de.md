<!--
SEO/AEO/GEO/LLMO Meta Block
=============================
@title: Open Godot MCP — KI-gesteuerte Godot-Spielentwicklung, Tests & Debugging
@description: Open-Source-MCP-Server für KI-autonome Godot-Spielentwicklung. Deterministisches Playtesting, Mehrspielertest, DAP-Debugging, LSP-Integration, Token-effizient. 100% MIT.
@keywords: godot mcp, model context protocol, ki-spielentwicklung, godot ki, spiele testen, playtesting, deterministisches testen, mehrspieler testen, spiel debugging, dap debugger, lsp integration, gdscript, godot 4, open source mcp, ki coding assistent, claude mcp, game engine ki, automatisiertes spiele testen, godot plugin, token effizienz
@author: MasterYee Labs
@language: de
@og:type: software
@og:title: Open Godot MCP
@og:description: Open-Source-MCP-Server für KI-gesteuerte Godot-Spielentwicklung — deterministisches Playtesting, Mehrspielertest, DAP-Debugging, LSP, Token-effizient.
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
  "description": "Open-Source Model-Context-Protocol-Server für KI-autonome Godot-Spielentwicklung, Tests und Debugging. Bietet deterministisches Playtesting, Mehrspielertest, DAP-Debugging, LSP-Integration und Token-effizientes Design.",
  "url": "https://github.com/masteryee-labs/Open-Godot-MCP",
  "programmingLanguage": ["GDScript", "Python"],
  "framework": "Godot Engine 4.5+",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  },
  "featureList": [
    "Deterministisches Playtesting (freeze/step/step_until)",
    "Mehrspielertest (Multi-Instanz, Peer-Simulation)",
    "DAP-Debugging (breakpoints, stack_trace, variables, evaluate)",
    "LSP-Integration (Diagnostik, Autovervollständigung, Gehe-zu-Definition)",
    "Token-effizientes Design (JSON-Digest, Diff, Screenshot-Komprimierung)",
    "30+ MCP-Tools, 130+ Aktionen",
    "Verbindungsstabilität (Heartbeat, intelligente Wiederverbindung, automatische Port-Vermeidung)"
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

> Open-Source, kostenloser, voll ausgestatteter Model-Context-Protocol-Server (MCP), der es der KI ermöglicht, Godot-Spiele autonom zu entwickeln, zu testen und zu debuggen — einschließlich echter Spielsteuerung, deterministischem Playtesting, Mehrspielertest, DAP-Debugging, LSP-Integration und Token-effizientem Design. 100% MIT-lizenziert, kein Freemium, keine Paywall.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Godot 4.5+](https://img.shields.io/badge/Godot-4.5+-blue.svg)](https://godotengine.org)
[![Python 3.11+](https://img.shields.io/badge/Python-3.11+-green.svg)](https://python.org)
[![MCP](https://badge.mcpx.dev?type=server)](https://modelcontextprotocol.io)

**Sprachen:** [繁體中文](README.md) | English (this file) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [Português-BR](README.pt-BR.md) | [Polski](README.pl.md) | [Italiano](README.it.md) | [Türkçe](README.tr.md) | [ภาษาไทย](README.th.md) | [Tiếng Việt](README.vi.md) | [Bahasa Indonesia](README.id.md) | [Українська](README.uk.md) | [Nederlands](README.nl.md) | [العربية](README.ar.md) | [हिन्दी](README.hi.md)

---

## Was ist Open Godot MCP?

**Open Godot MCP** ist ein Open-Source-[Model-Context-Protocol](https://modelcontextprotocol.io)-Server, der KI-Coding-Assistenten (Claude, GPT, Cursor, Windsurf usw.) mit dem [Godot-Engine](https://godotengine.org)-Editor verbindet. Er ermöglicht der KI, **Code zu schreiben, das Spiel auszuführen, Gameplay zu testen, an Haltepunkten zu debuggen, Variablen zu inspizieren und Fehlerbehebungen zu verifizieren** — alles autonom, ohne menschliches Eingreifen.

Im Gegensatz zu bestehenden Godot-MCP-Servern, die nur Szenen bearbeiten, lässt Open Godot MCP die KI **das Spiel tatsächlich spielen** durch deterministisches Playtesting (Uhr einfrieren → Zeit schrittweise vorgehen → Zustand beobachten → Ergebnis verifizieren). Es ist das **einzige** Godot-MCP, das **Mehrspielertest**, **DAP-Debugger-Integration** und **LSP-Code-Intelligenz** unterstützt.

| Attribut | Wert |
|-----------|-------|
| **Projekttyp** | MCP-Server (Model Context Protocol) für Godot Engine |
| **Ziel-Engine** | Godot 4.5+ (GDScript + C#-Unterstützung) |
| **Laufzeit** | Python 3.11+ (Server) + GDScript (Addon) |
| **Lizenz** | MIT (100% Open Source, kein Freemium) |
| **Tools** | ~30 MCP-Tools, ~130 Aktionen |
| **Schlüsselfunktionen** | Deterministisches Playtesting, Mehrspielertest, DAP-Debugging, LSP, Token-Effizienz |
| **KI-Clients** | Claude Desktop, Cursor, Windsurf, VS Code (MCP), Continue, Zed, jeder MCP-kompatible Client |
| **Plattformen** | Windows, macOS, Linux |
| **Einzigartige Fähigkeiten** | Mehrspielertest (kein anderes Godot-MCP hat dies), DAP + LSP-Integration |

---

## Warum es dieses Projekt gibt

Jedes Godot-MCP auf dem Markt hat Schwächen:

| Problem | Bestehende MCPs | Open Godot MCP |
|---------|-----------------|-----------------|
| KI kann das Spiel nicht wirklich laufen sehen | Nur Editier-Modus, kann das Spiel nicht spielen, um Bugs zu beheben | **Deterministisches Playtesting** — Uhr einfrieren, präzise Zeit schrittweise vorgehen, step_until-Bedingung |
| Instabile Verbindung | Fest codierter Port, kein Heartbeat, WSL2-Konflikte | Konfigurierbarer Port + Heartbeat + intelligente Wiederverbindung + automatische Port-Vermeidung |
| Kein Mehrspieler-Test möglich | Alle MCPs haben keinen Mehrspieler-Test | **Einzigartig** — Multi-Instanz, Peer-Simulation, Synchronisations-Verifikation, Netzwerkbedingungen injizieren |
| Token-Verschwendung | Vollständige Rückgaben, unkomprimierte PNG, kein Diff | Günstige Beobachtung, Screenshot-Komprimierung, Diff, Zusammenfassungen, inkrementelle Abfragen |
| Freemium-Beschneidung | Kostenlose Version eingeschränkt, für Funktionen bezahlen | **100% MIT Open Source**, alle Funktionen kostenlos |

---

## Für wen ist das?

- **Spielentwickler, die Godot 4 nutzen** und wollen, dass die KI beim Schreiben, Testen und Debuggen ihrer Spiele hilft
- **KI-gestützte Coder** (Claude, Cursor, Windsurf, VS Code MCP-Nutzer), die an Godot-Projekten arbeiten
- **Indie-Spielstudios**, die automatisiertes Playtesting benötigen, ohne Test-Frameworks zu schreiben
- **Mehrspieler-Spielentwickler**, die Netzwerk-Synchronisation, Latenz und Peer-Verhalten testen müssen
- **Open-Source-Befürworter**, die einen vollständig kostenlosen MCP-Server ohne Paywall wollen

---

## Anwendungsfälle

| Anwendungsfall | Wie Open Godot MCP hilft |
|----------|--------------------------|
| **KI behebt einen Bewegungs-Bug** | KI setzt Haltepunkt → führt Spiel aus → inspiziert Variablen → identifiziert Ursache → behebt Code → testet erneut |
| **Automatisiertes Boss-Kampf-Testing** | Uhr einfrieren → Boss spawnen → Zeit schrittweise vorgehen → Ausweich-Eingabe simulieren → verifizieren, dass Spieler überlebt |
| **Mehrspieler-Synchronisations-Verifikation** | Host + Client-Instanzen starten → Latenz injizieren → Synchronisations-Zustand vergleichen → Desync-Bugs erkennen |
| **Leistungsprofilerstellung** | Profiler-Snapshot erstellen → Spike identifizieren → optimieren → neu messen |
| **Regressionstest** | Test-Suite nach Code-Änderung ausführen → assertions, dass Spielzustand dem erwarteten entspricht |
| **Level-Design-Iteration** | KI erstellt Nodes → arrangiert Szene → führt Spiel aus → screenshotet Ergebnis → passt an |

---

## Kernfunktionen

### 1. Deterministisches Playtesting (löst „KI kann das Spiel nicht laufen sehen")

Die KI schreibt nicht nur Code — sie kann **das Spiel selbst spielen, um Fehlerbehebungen zu verifizieren**:

```
godot_game play frozen=true                    # Spiel starten (eingefrorene Uhr)
godot_exec eval code="GameState.wave = 3"      # Test-Szenario einrichten
godot_game_time step_until "boss.size() >= 1"  # Warten, bis Boss erscheint
godot_runtime_state digest                     # Zustand beobachten (JSON, keine Vision-Tokens)
godot_game_time step ms=500 + dodge input      # Den kritischen Moment spielen
godot_screenshot game                          # Screenshot nur, wenn es sich lohnt
```

### 2. Mehrspielertest (einzigartige Funktion — kein anderes Godot-MCP hat dies)

Eine Fähigkeit, die kein bestehendes Godot-MCP hat:

```
godot_network launch_instance role="host"      # Server starten
godot_network launch_instance role="client"    # Client starten
godot_network network_condition latency=200    # 200ms Latenz injizieren
godot_network sync_state                       # Multi-Instanz-Synchronisation verifizieren
godot_network simulate_peer count=50           # Stresstest mit 50 Peers
```

### 3. Token-Effizienz

Jedes Tool hat ein Token-sparendes Design:

- **Günstige Beobachtung**: JSON-Zustands-Digest ersetzt Screenshots (spart 90 % Tokens)
- **Diff-Rückgaben**: Nur veränderte Teile zurückgeben
- **Screenshot-Komprimierung**: JPEG/WebP + auf Festplatte speichern (nicht im Kontext)
- **Lese-/Schreibtrennung**: Lesen automatisch erlaubt, Schreiben kontrolliert
- **Stapelverarbeitung**: Mehrere Operationen in einem Round-Trip abschließen

### 4. Verbindungsstabilität

Löst das „Verbindung nicht möglich"-Problem bestehender MCPs:

- Konfigurierbarer Port (Umgebung > EditorSettings > automatische Vermeidung)
- Windows-Port-Reservierungserkennung (Hyper-V/WSL2/Docker reservierte Ports vermeiden)
- Heartbeat-Mechanismus (proaktive Erkennung toter Verbindungen)
- Intelligente Wiederverbindung (exponentielles Backoff + maximale Versuche + UI-Benachrichtigung)

### 5. Vollständiges Debugging

- **DAP (Debugger Adapter Protocol)**: Haltepunkte, schrittweise Ausführung, Variableninspektion (stack_trace, variables, evaluate)
- **LSP (Language Server Protocol)**: statische Diagnostik, Autovervollständigung, Gehe-zu-Definition
- **Profiler**: Leistungs-Snapshots, Timeline-Analyse, Spike-Erkennung

---

## Schnellstart

### 1. MCP-Server installieren

```bash
uv tool install open-godot-mcp
# oder
pip install open-godot-mcp
```

### 2. KI-Client konfigurieren

```json
{
  "mcpServers": {
    "open-godot-mcp": {
      "command": "open-godot-mcp"
    }
  }
}
```

### 3. Godot-Projekt öffnen

Das Addon wird automatisch injiziert. Öffnen Sie Ihren KI-Client und beginnen Sie mit der Nutzung.

Vollständige Installationsanleitung: [Docs/06-Installation/Guide.md](Docs/06-Installation/Guide.md).

---

## Werkzeugliste

~30 Werkzeuge, ~130 Aktionen. Lese-/Schreibtrennung-Design.

| Bereich | Werkzeug | Beschreibung |
|---------|----------|--------------|
| Editor | `godot_editor_read/edit` | Zustand, Szene, Auswahl |
| Szene | `godot_scene` | Erstellen, lesen, speichern |
| Node | `godot_node_read/edit` | CRUD, Eigenschaften, Gruppen, Signale |
| Skript | `godot_script` | Diff-Bearbeitung, Validierung |
| Projekt | `godot_project` | Einstellungen, Autoloads |
| Input Map | `godot_input_map` | InputMap-Verwaltung |
| Ressource | `godot_resource` | Typbewusste Inspektion |
| Animation | `godot_animation` | Erstellen, Tracks, Presets |
| TileMap | `godot_tilemap` | Zellen lesen/schreiben |
| **Spielsteuerung** | `godot_game` | play/stop/freeze |
| **Uhr** | `godot_game_time` | freeze/step/step_until |
| **Eingabe** | `godot_input` | Tastatur/Maus/Gamepad/Text |
| **Zustand** | `godot_runtime_state` | digest/watch/signals |
| **Injektion** | `godot_exec` | eval/call/assert |
| Screenshot | `godot_screenshot` | Komprimierung, in Datei speichern |
| Debugger | `godot_debugger` | DAP-Haltepunkte, stack_trace, variables, evaluate |
| Code | `godot_lsp` | Diagnostik, Vervollständigung |
| Profiler | `godot_profiler` | Snapshots, Timeline |
| Test | `godot_test` | Framework, Ausführung |
| **Netzwerk** | `godot_network` | Multi-Instanz, Synchronisation, Netzwerkbedingungen |
| Instanz | `godot_instance` | Multi-Godot-Verwaltung |
| Dateisystem | `godot_filesystem` | Lesen/schreiben, suchen |
| Dokumentation | `godot_docs` | Versionsangepasst |
| Log | `godot_log` | Inkrementelle Abfrage |
| Batch | `godot_batch` | Mehrere Operationen gleichzeitig |
| Asset | `godot_asset` | Generierung, Verwaltung |
| Export | `godot_export` | Presets, Export |
| Health | `godot_health` | Verbindungsprüfung |

Vollständige API: [Docs/02-Tools/Index.md](Docs/02-Tools/Index.md).

---

## Vergleich mit bestehenden Godot-MCP-Servern

| Funktion | godot-ai | godot-mcp | Coding-Solo | satelliteoflove | thediymaker | **Open Godot MCP** |
|----------|----------|-----------|-------------|-----------------|-------------|---------------------|
| Editor-Operationen | ✅ | ✅ | ✅ | ✅ | ✅ 149 Tools | ✅ |
| Echte Spielsteuerung | ⚠️ | ⚠️ | ❌ | ✅ deterministisch | ⚠️ | ✅ **deterministisch+Echtzeit** |
| Mehrspieler-Test | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **einzigartig** |
| DAP-Debugging | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| LSP-Integration | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Token-Effizienz | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ✅ **umfassend** |
| Verbindungsstabilität | ⚠️ | ❌ | — | ✅ | — | ✅ **am stabilsten** |
| Lizenz | offen | offen | MIT | MIT | MIT | **MIT** |

---

## FAQ

### Was ist das Model Context Protocol (MCP)?

Das [Model Context Protocol](https://modelcontextprotocol.io) ist ein offener Standard, der es KI-Assistenten ermöglicht, sich mit externen Tools und Datenquellen zu verbinden. Open Godot MCP ist ein MCP-Server, der die KI mit dem Godot-Engine-Editor verbindet.

### Welche Godot-Versionen werden unterstützt?

Godot 4.5 und neuer. Das Addon nutzt Godot 4.x-APIs einschließlich `EditorDebuggerPlugin`, `EditorInspector` und dem Debugger-Nachrichtenkanal.

### Welche KI-Clients sind kompatibel?

Jeder MCP-kompatible Client: Claude Desktop, Cursor, Windsurf, VS Code (mit MCP-Erweiterung), Continue, Zed und jeder Client, der den Model-Context-Protocol-Standard unterstützt.

### Wird C# unterstützt (Godots .NET-Version)?

Ja. C#-Syntaxprüfung und Kompilierungsverifikation werden unterstützt. Siehe [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/).

### Wie unterscheidet sich das von anderen Godot-MCP-Servern?

Open Godot MCP ist das **einzige** Godot-MCP, das Mehrspielertest, DAP-Debugger-Integration (Haltepunkte, Stack-Traces, Variableninspektion) und LSP-Code-Intelligenz unterstützt. Es hat außerdem das umfassendste Token-Effizienz-Design.

### Ist es wirklich kostenlos?

Ja. 100% MIT-lizenziert, kein Freemium-Modell, keine Paywall, keine Funktionseinschränkungen. Alle Funktionen sind für jeden kostenlos.

### Kann die KI das Spiel tatsächlich spielen?

Ja. Durch deterministisches Playtesting kann die KI die Spiel-Uhr einfrieren, die Zeit in präzisen Schritten vorwärts bewegen, Test-Szenarien injizieren, Spielereingaben simulieren, den Spielzustand als JSON beobachten und Screenshots erstellen — alles, um zu verifizieren, dass Code-Änderungen korrekt funktionieren.

### Wie funktioniert der Mehrspielertest?

Open Godot MCP kann mehrere Godot-Instanzen starten (Host + Clients), Peers simulieren, Netzwerkbedingungen injizieren (Latenz, Paketverlust) und verifizieren, dass der Spielzustand über Instanzen hinweg synchronisiert ist.

---

## Dokumentation

Vollständiger Dokumentationsindex: [Docs/README.md](Docs/README.md). Nach Ordner entkoppelt.

| Ordner | Inhalt |
|--------|--------|
| [Docs/00-Overview/](Docs/00-Overview/) | Funktionsübersicht, Design-Philosophie |
| [Docs/01-Architecture/](Docs/01-Architecture/) | Architektur, Protokoll, Verbindungsstabilität, Multi-Instanz, Laufzeit |
| [Docs/02-Tools/](Docs/02-Tools/) | Vollständige Werkzeugliste (pro Bereich separate Dateien) |
| [Docs/03-Realtime-Testing/](Docs/03-Realtime-Testing/) | Deterministisches Playtesting (Anleitung + Beispiele) |
| [Docs/04-Token-Efficiency/](Docs/04-Token-Efficiency/) | Token-sparendes Design (Anleitung + Strategien) |
| [Docs/05-Network-Testing/](Docs/05-Network-Testing/) | Mehrspielertest (Anleitung + Beispiele) |
| [Docs/06-Installation/](Docs/06-Installation/) | Installation (Anleitung + Fehlerbehebung) |
| [Docs/07-Roadmap/](Docs/07-Roadmap/) | Entwicklungs-Roadmap |
| [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/) | C#-Godot-Kompatibilität & Syntaxprüfung |
| [Docs/09-Research/](Docs/09-Research/) | Bestehende MCP-Forschung, C#-MCP-Forschung |

---

## Danksagung

Open Godot MCP steht auf den Schultern von Riesen und übernimmt das Beste von:

- [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp) (4.8k Sterne) — grundlegende Architektur
- [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp) — deterministisches Playtesting, günstige Beobachtung, Lese-/Schreibtrennung
- [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) — Debugger-Kanal-Laufzeit, Undo/Redo, Windows-Port-Reservierung, 20+ Client-Konfigurationen, McpTestSuite
- [tomyud1/godot-mcp](https://github.com/tomyud1/godot-mcp) — Dual-Kanal-Architektur, Variant-Serialisierung, Löschschutz
- [rosskarchner/godot-mcp](https://github.com/rosskarchner/godot-mcp) — DAP + LSP-Integration, Multi-Instanz, Port-Isolation
- [Erodenn/godot-mcp-runtime](https://github.com/Erodenn/godot-mcp-runtime) — ohne Fußabdruck, Playwright-für-Godot-Konzept
- [thediymaker/godot-mcp](https://github.com/thediymaker/godot-mcp) — 149-Tools-Breite-Referenz

---

## Lizenz

[MIT](LICENSE) — 100 % Open Source, alle Funktionen kostenlos, kein Freemium, keine Paywall.
