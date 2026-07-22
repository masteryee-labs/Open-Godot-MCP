<!--
SEO/AEO/GEO/LLMO Meta Block
=============================
@title: Open Godot MCP — Sviluppo, Test e Debug di Giochi Godot guidato dall'IA
@description: Server MCP open source per lo sviluppo autonomo di giochi Godot con IA. Playtesting deterministico, test multiplayer, debug DAP, integrazione LSP, efficienza dei token. 100% MIT.
@keywords: godot mcp, model context protocol, sviluppo giochi ia, godot ia, test giochi, playtesting, test deterministico, test multiplayer, debug giochi, dap debugger, integrazione lsp, gdscript, godot 4, mcp open source, assistente coding ia, claude mcp, ia game engine, test automatizzati giochi, plugin godot, efficienza token
@author: MasterYee Labs
@language: it
@og:type: software
@og:title: Open Godot MCP
@og:description: Server MCP open source per lo sviluppo di giochi Godot guidato dall'IA — playtesting deterministico, test multiplayer, debug DAP, LSP, efficienza dei token.
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
  "description": "Server Model Context Protocol open source per lo sviluppo, il test e il debug autonomo di giochi Godot con IA. Include playtesting deterministico, test multiplayer, debug DAP, integrazione LSP e design efficiente per i token.",
  "url": "https://github.com/masteryee-labs/Open-Godot-MCP",
  "programmingLanguage": ["GDScript", "Python"],
  "framework": "Godot Engine 4.5+",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  },
  "featureList": [
    "Playtesting deterministico (freeze/step/step_until)",
    "Test di giochi multiplayer (multi-istanza, simulazione peer)",
    "Debug DAP (breakpoint, stack_trace, variables, evaluate)",
    "Integrazione LSP (diagnostica, autocompletamento, vai alla definizione)",
    "Design efficiente per i token (digest JSON, diff, compressione screenshot)",
    "30+ strumenti MCP, 130+ azioni",
    "Stabilità della connessione (heartbeat, riconnessione intelligente, evitamento automatico delle porte)"
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

> Server Model Context Protocol (MCP) open source, gratuito e completo che permette all'IA di sviluppare, testare e debuggare giochi Godot in modo autonomo — inclusi controllo del gioco in tempo reale, playtesting deterministico, test multiplayer, debug DAP, integrazione LSP e design efficiente per i token. 100% MIT, nessun freemium, nessun paywall.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Godot 4.5+](https://img.shields.io/badge/Godot-4.5+-blue.svg)](https://godotengine.org)
[![Python 3.11+](https://img.shields.io/badge/Python-3.11+-green.svg)](https://python.org)
[![MCP](https://badge.mcpx.dev?type=server)](https://modelcontextprotocol.io)

**Languages:** [繁體中文](../../README.md) | [English](README_EN.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [Português-BR](README.pt-BR.md) | [Polski](README.pl.md) | Italiano（本檔） | [Türkçe](README.tr.md) | [ภาษาไทย](README.th.md) | [Tiếng Việt](README.vi.md) | [Bahasa Indonesia](README.id.md) | [Українська](README.uk.md) | [Nederlands](README.nl.md) | [العربية](README.ar.md) | [हिन्दी](README.hi.md)

---

## Cos'è Open Godot MCP?

**Open Godot MCP** è un server [Model Context Protocol](https://modelcontextprotocol.io) open source che connette gli assistenti di coding IA (Claude, GPT, Cursor, Windsurf, ecc.) all'editor [Godot Engine](https://godotengine.org). Permette all'IA di **scrivere codice, avviare il gioco, testare il gameplay, fare debug ai breakpoint, ispezionare le variabili e verificare le correzioni** — tutto in modo autonomo, senza intervento umano.

A differenza dei server Godot MCP esistenti che si limitano a modificare le scene, Open Godot MCP permette all'IA di **giocare realmente al gioco** tramite playtesting deterministico (blocca orologio → avanzamento tempo → osserva stato → verifica risultato). È l'**unico** Godot MCP che supporta **test di giochi multiplayer**, **integrazione del debugger DAP** e **intelligenza del codice LSP**.

| Attributo | Valore |
|-----------|--------|
| **Tipo di progetto** | Server MCP (Model Context Protocol) per Godot Engine |
| **Engine di destinazione** | Godot 4.5+ (supporto GDScript + C#) |
| **Runtime** | Python 3.11+ (server) + GDScript (addon) |
| **Licenza** | MIT (100% open source, nessun freemium) |
| **Strumenti** | ~30 strumenti MCP, ~130 azioni |
| **Funzionalità chiave** | Playtesting deterministico, test multiplayer, debug DAP, LSP, efficienza dei token |
| **Client IA** | Claude Desktop, Cursor, Windsurf, VS Code (MCP), Continue, Zed, qualsiasi client compatibile con MCP |
| **Piattaforme** | Windows, macOS, Linux |
| **Capacità uniche** | Test multiplayer (nessun altro Godot MCP lo ha), integrazione DAP + LSP |

---

## Perché esiste

Ogni Godot MCP sul mercato presenta delle lacune:

| Problema | MCP esistenti | Open Godot MCP |
|---------|--------------|-----------------|
| L'IA non può vedere il gioco in esecuzione | Solo modifica, non può avviare il gioco per correggere i bug | **Playtesting deterministico** — blocca l'orologio, avanzamento preciso del tempo, step_until con condizione |
| Connessione instabile | Porta hardcoded, nessun heartbeat, conflitti WSL2 | Porta configurabile + heartbeat + riconnessione intelligente + evitamento automatico delle porte |
| Impossibile testare il multiplayer | Tutti i MCP mancano di test multiplayer | **Unico** — multi-istanza, simulazione peer, verifica sincronia, iniezione di condizioni di rete |
| Spreco di token | Restituzioni complete, PNG non compressi, nessun diff | Osservazione economica, compressione screenshot, diff, riepiloghi, query incrementali |
| Crippleware freemium | Versione gratuita limitata, paga per le funzionalità | **100% MIT open source**, tutte le funzionalità gratuite |

---

## Per chi è?

- **Sviluppatori di giochi che usano Godot 4** che vogliono che l'IA aiuti a scrivere, testare e debuggare i loro giochi
- **Coder con assistenza IA** (utenti Claude, Cursor, Windsurf, VS Code MCP) che lavorano su progetti Godot
- **Studi indie di giochi** che hanno bisogno di playtesting automatizzato senza scrivere framework di test
- **Sviluppatori di giochi multiplayer** che devono testare sincronia di rete, latenza e comportamento dei peer
- **Sostenitori dell'open source** che vogliono un server MCP completamente gratuito senza paywall

---

## Casi d'uso

| Caso d'uso | Come aiuta Open Godot MCP |
|------------|---------------------------|
| **L'IA corregge un bug di movimento** | L'IA imposta un breakpoint → avvia il gioco → ispeziona le variabili → identifica la causa principale → corregge il codice → ri-testa |
| **Test automatizzato di boss fight** | Blocca l'orologio → genera il boss → avanzamento tempo → simula input di schivata → verifica che il giocatore sopravviva |
| **Verifica sincronia multiplayer** | Avvia istanze host + client → inietta latenza → confronta stato di sincronia → rileva bug di desync |
| **Profiling delle prestazioni** | Cattura snapshot del profiler → identifica il picco → ottimizza → ri-misura |
| **Test di regressione** | Esegue la suite di test dopo una modifica al codice → verifica che lo stato del gioco corrisponda a quello atteso |
| **Iterazione sul level design** | L'IA crea nodi → dispone la scena → avvia il gioco → screenshot del risultato → regola |

---

## Funzionalità principali

### 1. Playtesting deterministico (risolve "l'IA non può vedere il gioco in esecuzione")

L'IA non si limita a scrivere codice — può **giocare al gioco stesso per verificare le correzioni**:

```
godot_game play frozen=true                    # Avvia il gioco (orologio bloccato)
godot_exec eval code="GameState.wave = 3"      # Prepara lo scenario di test
godot_game_time step_until "boss.size() >= 1"  # Attende la comparsa del boss
godot_runtime_state digest                     # Osserva lo stato (JSON, nessun token visivo)
godot_game_time step ms=500 + dodge input      # Gioca il momento cruciale
godot_screenshot game                          # Screenshot solo quando vale la pena
```

### 2. Test multiplayer (funzionalità unica — nessun altro Godot MCP lo ha)

Una capacità che nessun Godot MCP esistente possiede:

```
godot_network launch_instance role="host"      # Avvia il server
godot_network launch_instance role="client"    # Avvia il client
godot_network network_condition latency=200    # Inietta 200ms di latenza
godot_network sync_state                       # Verifica la sincronia multi-istanza
godot_network simulate_peer count=50           # Stress test con 50 peer
```

### 3. Efficienza dei token

Ogni strumento è progettato per risparmiare token:

- **Osservazione economica**: il digest dello stato JSON sostituisce gli screenshot (risparmio del 90% dei token)
- **Restituzione con diff**: restituisce solo le parti modificate
- **Compressione screenshot**: JPEG/WebP + salvataggio su disco (non nel contesto)
- **Separazione lettura/scrittura**: lettura auto-autorizzata, scrittura controllata
- **Operazioni batch**: completa più operazioni in un solo round-trip

### 4. Stabilità della connessione

Risolve il problema "impossibile connettersi" dei MCP esistenti:

- Porta configurabile (env > EditorSettings > evitamento automatico)
- Rilevamento delle porte riservate su Windows (evita porte riservate da Hyper-V/WSL2/Docker)
- Meccanismo di heartbeat (rilevamento proattivo delle connessioni morte)
- Riconnessione intelligente (backoff esponenziale + tentativi massimi + notifica UI)

### 5. Debugging completo

- **DAP (Debugger Adapter Protocol)**: breakpoint, stepping, ispezione variabili (stack_trace, variables, evaluate)
- **LSP (Language Server Protocol)**: diagnostica statica, autocompletamento, vai alla definizione
- **Profiler**: snapshot delle prestazioni, analisi della timeline, rilevamento dei picchi

---

## Avvio rapido

### 1. Installa il server MCP

```bash
uv tool install open-godot-mcp
# oppure
pip install open-godot-mcp
```

### 2. Configura il client IA

```json
{
  "mcpServers": {
    "open-godot-mcp": {
      "command": "open-godot-mcp"
    }
  }
}
```

### 3. Apri il progetto Godot

L'addon si inietta automaticamente. Apri il tuo client IA e inizia a usarlo.

Guida all'installazione completa: [Docs/06-Installation/Guide.md](Docs/06-Installation/Guide.md).

---

## Elenco strumenti

~30 strumenti, ~130 azioni. Design con separazione lettura/scrittura.

| Dominio | Strumento | Descrizione |
|--------|------|-------------|
| Editor | `godot_editor_read/edit` | Stato, scena, selezione |
| Scena | `godot_scene` | Creazione, lettura, salvataggio |
| Nodo | `godot_node_read/edit` | CRUD, proprietà, gruppi, segnali |
| Script | `godot_script` | Modifica con diff, validazione |
| Progetto | `godot_project` | Impostazioni, autoload |
| Mappa input | `godot_input_map` | Gestione InputMap |
| Risorsa | `godot_resource` | Ispezione con tipo |
| Animazione | `godot_animation` | Creazione, tracce, preset |
| TileMapLayer | `godot_tilemap` | Lettura/scrittura celle |
| **Controllo gioco** | `godot_game` | play/stop/freeze |
| **Orologio** | `godot_game_time` | freeze/step/step_until |
| **Input** | `godot_input` | Tastiera/mouse/gamepad/testo |
| **Stato** | `godot_runtime_state` | digest/watch/segnali |
| **Iniezione** | `godot_exec` | eval/call/assert |
| Screenshot | `godot_screenshot` | Compressione, salvataggio su file |
| Debugger | `godot_debugger` | Breakpoint DAP, stack_trace, variables, evaluate |
| Codice | `godot_lsp` | Diagnostica, completamento |
| Profiler | `godot_profiler` | Snapshot, timeline |
| Test | `godot_test` | Framework, esecuzione |
| **Rete** | `godot_network` | Multi-istanza, sincronia, condizioni di rete |
| Istanza | `godot_instance` | Gestione multi-Godot |
| Filesystem | `godot_filesystem` | Lettura/scrittura, ricerca |
| Docs | `godot_docs` | Corrispondenza versione |
| Log | `godot_log` | Query incrementale |
| Batch | `godot_batch` | Operazioni multiple in una volta |
| Asset | `godot_asset` | Generazione, gestione |
| Export | `godot_export` | Preset, esportazione |
| Health | `godot_health` | Verifica connessione |

API completa: [Docs/02-Tools/Index.md](Docs/02-Tools/Index.md).

---

## Confronto con i server Godot MCP esistenti

| Funzionalità | godot-ai | godot-mcp | Coding-Solo | satelliteoflove | thediymaker | **Open Godot MCP** |
|---------|----------|-----------|-------------|-----------------|-------------|---------------------|
| Operazioni editor | ✅ | ✅ | ✅ | ✅ | ✅ 149 strumenti | ✅ |
| Controllo reale del gioco | ⚠️ | ⚠️ | ❌ | ✅ deterministico | ⚠️ | ✅ **deterministico+tempo reale** |
| Test multiplayer | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **unico** |
| Debug DAP | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Integrazione LSP | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Efficienza dei token | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ✅ **completa** |
| Stabilità della connessione | ⚠️ | ❌ | — | ✅ | — | ✅ **più stabile** |
| Licenza | open | open | MIT | MIT | MIT | **MIT** |

---

## FAQ

### Cos'è il Model Context Protocol (MCP)?

Il [Model Context Protocol](https://modelcontextprotocol.io) è uno standard aperto che permette agli assistenti IA di connettersi a strumenti e fonti di dati esterni. Open Godot MCP è un server MCP che connette l'IA all'editor di Godot Engine.

### Quali versioni di Godot sono supportate?

Godot 4.5 e versioni successive. L'addon utilizza le API di Godot 4.x inclusi `EditorDebuggerPlugin`, `EditorInspector` e il canale dei messaggi del debugger.

### Quali client IA sono compatibili?

Qualsiasi client compatibile con MCP: Claude Desktop, Cursor, Windsurf, VS Code (con estensione MCP), Continue, Zed e qualsiasi client che supporta lo standard Model Context Protocol.

### Supporta C# (la versione .NET di Godot)?

Sì. Sono supportati il controllo della sintassi C# e la verifica della compilazione. Vedi [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/).

### In cosa differisce dagli altri server Godot MCP?

Open Godot MCP è l'**unico** Godot MCP che supporta test di giochi multiplayer, integrazione del debugger DAP (breakpoint, stack trace, ispezione variabili) e intelligenza del codice LSP. Ha anche il design più completo per l'efficienza dei token.

### È davvero gratuito?

Sì. Licenza 100% MIT, nessun modello freemium, nessun paywall, nessuna funzionalità a pagamento. Tutte le funzionalità sono gratuite per tutti.

### L'IA può davvero giocare al gioco?

Sì. Tramite il playtesting deterministico, l'IA può bloccare l'orologio di gioco, avanzare il tempo in incrementi precisi, iniettare scenari di test, simulare l'input del giocatore, osservare lo stato del gioco come JSON e catturare screenshot — tutto per verificare che le modifiche al codice funzionino correttamente.

### Come funziona il test multiplayer?

Open Godot MCP può avviare multiple istanze di Godot (host + client), simulare peer, iniettare condizioni di rete (latenza, perdita di pacchetti) e verificare che lo stato del gioco sia sincronizzato tra le istanze.

---

## Documentazione

Indice completo della documentazione: [Docs/README.md](Docs/README.md). Disaccoppiata per cartella.

| Cartella | Contenuto |
|--------|---------|
| [Docs/00-Overview/](Docs/00-Overview/) | Panoramica delle funzionalità, filosofia di design |
| [Docs/01-Architecture/](Docs/01-Architecture/) | Architettura, protocollo, stabilità della connessione, multi-istanza, runtime |
| [Docs/02-Tools/](Docs/02-Tools/) | Elenco completo degli strumenti (file per dominio) |
| [Docs/03-Realtime-Testing/](Docs/03-Realtime-Testing/) | Playtesting deterministico (Guida + Esempi) |
| [Docs/04-Token-Efficiency/](Docs/04-Token-Efficiency/) | Design per il risparmio di token (Guida + Strategie) |
| [Docs/05-Network-Testing/](Docs/05-Network-Testing/) | Test multiplayer (Guida + Esempi) |
| [Docs/06-Installation/](Docs/06-Installation/) | Installazione (Guida + Risoluzione problemi) |
| [Docs/07-Roadmap/](Docs/07-Roadmap/) | Roadmap di sviluppo |
| [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/) | Compatibilità C# Godot e controllo sintassi |
| [Docs/09-Research/](Docs/09-Research/) | Ricerca su MCP esistenti, ricerca MCP C# |

---

## Ringraziamenti

Open Godot MCP poggia sulle spalle dei giganti, prendendo il meglio da:

- [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp) (4.8k stelle) — architettura di base
- [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp) — playtesting deterministico, osservazione economica, separazione lettura/scrittura
- [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) — runtime del canale debugger, Undo/Redo, porte riservate Windows, 20+ configurazioni client, McpTestSuite
- [tomyud1/godot-mcp](https://github.com/tomyud1/godot-mcp) — architettura a doppio canale, serializzazione Variant, protezione dall'eliminazione
- [rosskarchner/godot-mcp](https://github.com/rosskarchner/godot-mcp) — integrazione DAP + LSP, multi-istanza, isolamento delle porte
- [Erodenn/godot-mcp-runtime](https://github.com/Erodenn/godot-mcp-runtime) — zero-footprint, concetto Playwright per Godot
- [thediymaker/godot-mcp](https://github.com/thediymaker/godot-mcp) — riferimento di ampiezza con 149 strumenti

---

## Licenza

[MIT](LICENSE) — 100% open source, tutte le funzionalità gratuite, nessun freemium, nessun paywall.
