<!--
SEO/AEO/GEO/LLMO Meta Block
=============================
@title: Open Godot MCP — Tworzenie, testowanie i debugowanie gier Godot wspierane przez AI
@description: Serwer MCP o otwartym kodzie do autonomicznego tworzenia gier Godot przez AI. Deterministyczne testy rozgrywki, testowanie multiplayer, debugowanie DAP, integracja LSP, efektywność tokenowa. 100% MIT.
@keywords: godot mcp, model context protocol, tworzenie gier ai, godot ai, testowanie gier, testy rozgrywki, testowanie deterministyczne, testowanie multiplayer, debugowanie gier, debugger dap, integracja lsp, gdscript, godot 4, mcp open source, asystent kodowania ai, claude mcp, ai silnik gry, zautomatyzowane testowanie gier, wtyczka godot, efektywność tokenowa
@author: MasterYee Labs
@language: pl
@og:type: software
@og:title: Open Godot MCP
@og:description: Serwer MCP o otwartym kodzie do tworzenia gier Godot wspieranego przez AI — deterministyczne testy rozgrywki, testowanie multiplayer, debugowanie DAP, LSP, efektywność tokenowa.
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
  "description": "Serwer Model Context Protocol o otwartym kodzie do autonomicznego tworzenia, testowania i debugowania gier Godot przez AI. Obejmuje deterministyczne testy rozgrywki, testowanie multiplayer, debugowanie DAP, integrację LSP oraz projekt oszczędzający tokeny.",
  "url": "https://github.com/masteryee-labs/Open-Godot-MCP",
  "programmingLanguage": ["GDScript", "Python"],
  "framework": "Godot Engine 4.5+",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  },
  "featureList": [
    "Deterministyczne testy rozgrywki (freeze/step/step_until)",
    "Testowanie gier multiplayer (wiele instancji, symulacja peerów)",
    "Debugowanie DAP (punkty przerwania, stack_trace, variables, evaluate)",
    "Integracja LSP (diagnostyka, autouzupełnianie, przejście do definicji)",
    "Projekt oszczędzający tokeny (skrót JSON, diff, kompresja zrzutów ekranu)",
    "30+ narzędzi MCP, 130+ akcji",
    "Stabilność połączenia (heartbeat, inteligentne ponowne połączenie, automatyczne omijanie portów)"
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

> Serwer Model Context Protocol o otwartym kodzie, darmowy i w pełni funkcjonalny, który pozwala sztucznej inteligencji autonomicznie tworzyć, testować i debugować gry w Godot — w tym rzeczywistą kontrolę gry, deterministyczne testy rozgrywki, testowanie trybu multiplayer, debugowanie DAP, integrację LSP oraz projekt oszczędzający tokeny. 100% licencji MIT, bez freemium, bez paywalla.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Godot 4.5+](https://img.shields.io/badge/Godot-4.5+-blue.svg)](https://godotengine.org)
[![Python 3.11+](https://img.shields.io/badge/Python-3.11+-green.svg)](https://python.org)
[![MCP](https://badge.mcpx.dev?type=server)](https://modelcontextprotocol.io)

**Languages:** [繁體中文](README.md) | English (this file) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [Português-BR](README.pt-BR.md) | [Polski](README.pl.md) | [Italiano](README.it.md) | [Türkçe](README.tr.md) | [ภาษาไทย](README.th.md) | [Tiếng Việt](README.vi.md) | [Bahasa Indonesia](README.id.md) | [Українська](README.uk.md) | [Nederlands](README.nl.md) | [العربية](README.ar.md) | [हिन्दी](README.hi.md)

---

## Co to jest Open Godot MCP?

**Open Godot MCP** to serwer [Model Context Protocol](https://modelcontextprotocol.io) o otwartym kodzie, który łączy asystenty kodowania AI (Claude, GPT, Cursor, Windsurf itp.) z edytorem [Godot Engine](https://godotengine.org). Pozwala AI **pisać kod, uruchamiać grę, testować rozgrywkę, debugować w punktach przerwania, inspekcjonować zmienne i weryfikować poprawki** — wszystko autonomicznie, bez interwencji człowieka.

W przeciwieństwie do istniejących serwerów Godot MCP, które tylko edytują sceny, Open Godot MCP pozwala AI **faktycznie grać w grę** poprzez deterministyczne testy rozgrywki (zamrożenie zegara → krok czasowy → obserwacja stanu → weryfikacja wyniku). Jest to **jedyne** Godot MCP, które obsługuje **testowanie gier multiplayer**, **integrację debuggera DAP** oraz **inteligencję kodu LSP**.

| Atrybut | Wartość |
|---------|---------|
| **Typ projektu** | Serwer MCP (Model Context Protocol) dla Godot Engine |
| **Docelowy silnik** | Godot 4.5+ (obsługa GDScript + C#) |
| **Runtime** | Python 3.11+ (serwer) + GDScript (addon) |
| **Licencja** | MIT (100% open source, bez freemium) |
| **Narzędzia** | ~30 narzędzi MCP, ~130 akcji |
| **Kluczowe funkcje** | Deterministyczne testy rozgrywki, testowanie multiplayer, debugowanie DAP, LSP, efektywność tokenowa |
| **Klienci AI** | Claude Desktop, Cursor, Windsurf, VS Code (MCP), Continue, Zed, dowolny klient kompatybilny z MCP |
| **Platformy** | Windows, macOS, Linux |
| **Unikalne możliwości** | Testowanie multiplayer (żadne inne Godot MCP tego nie ma), integracja DAP + LSP |

---

## Dlaczego to istnieje

Każdy Godot MCP na rynku ma wady:

| Problem | Istniejące MCP | Open Godot MCP |
|---------|----------------|-----------------|
| AI nie widzi, jak gra faktycznie działa | Tylko edycja, nie można uruchomić gry, aby naprawić błędy | **Deterministyczne testy rozgrywki** — zamrożenie zegara, precyzyjne kroki czasowe, step_until do warunku |
| Niestabilne połączenie | Hardcoded port, brak heartbeatu, konflikty WSL2 | Konfigurowalny port + heartbeat + inteligentne ponowne połączenie + automatyczne omijanie portów |
| Brak testów multiplayer | Wszystkie MCP nie mają testów multiplayer | **Unikalne** — wiele instancji, symulacja peerów, weryfikacja synchronizacji, wstrzykiwanie warunków sieciowych |
| Marnowanie tokenów | Pełne zwroty, nieskompresowane PNG, brak diff | Tania obserwacja, kompresja zrzutów ekranu, diff, podsumowania, zapytania przyrostowe |
| Okaleczenie freemium | Darmowa wersja ograniczona, płatne funkcje | **100% MIT open source**, wszystkie funkcje darmowe |

---

## Dla kogo to jest?

- **Twórcy gier używający Godot 4**, którzy chcą, aby AI pomogło pisać, testować i debugować ich gry
- **Koderzy wspierani przez AI** (użytkownicy Claude, Cursor, Windsurf, VS Code MCP) pracujący nad projektami Godot
- **Niezależne studia gier**, które potrzebują zautomatyzowanych testów rozgrywki bez pisania frameworków testowych
- **Twórcy gier multiplayer**, którzy muszą testować synchronizację sieciową, opóźnienia i zachowanie peerów
- **Zwolennicy open source**, którzy chcą w pełni darmowego serwera MCP bez paywalla

---

## Przypadki użycia

| Przypadek użycia | Jak Open Godot MCP pomaga |
|------------------|---------------------------|
| **AI naprawia błąd ruchu** | AI ustawia punkt przerwania → uruchamia grę → inspekcjonuje zmienne → identyfikuje przyczynę → naprawia kod → ponownie testuje |
| **Zautomatyzowane testy walki z bossem** | Zamrożenie zegara → spawn bossa → krok czasowy → symulacja uniku → weryfikacja przetrwania gracza |
| **Weryfikacja synchronizacji multiplayer** | Uruchomienie instancji host + klient → wstrzyknięcie opóźnienia → porównanie stanu synchronizacji → wykrycie błędów desync |
| **Profilowanie wydajności** | Migawka profilera → identyfikacja skoku → optymalizacja → ponowny pomiar |
| **Testy regresyjne** | Uruchomienie zestawu testów po zmianie kodu → asercja, że stan gry zgodny z oczekiwanym |
| **Iteracja projektowania poziomów** | AI tworzy węzły → aranżuje scenę → uruchamia grę → zrzut ekranu wyniku → koryguje |

---

## Podstawowe możliwości

### 1. Deterministyczne testy rozgrywki (rozwiązuje "AI nie widzi działania gry")

AI nie tylko pisze kod — może **samodzielnie grać w grę, aby zweryfikować poprawki**:

```
godot_game play frozen=true                    # Uruchom grę (zamrożony zegar)
godot_exec eval code="GameState.wave = 3"      # Ustaw scenariusz testowy
godot_game_time step_until "boss.size() >= 1"  # Poczekaj na pojawienie się bossa
godot_runtime_state digest                     # Obserwuj stan (JSON, bez tokenów wizyjnych)
godot_game_time step ms=500 + dodge input      # Zagraj kluczowy moment
godot_screenshot game                          # Zrzut ekranu tylko gdy warto
```

### 2. Testowanie multiplayer (funkcja unikalna — żadne inne Godot MCP tego nie ma)

Możliwość, której nie ma żadne istniejące Godot MCP:

```
godot_network launch_instance role="host"      # Uruchom serwer
godot_network launch_instance role="client"    # Uruchom klienta
godot_network network_condition latency=200    # Wstrzyknij 200ms opóźnienia
godot_network sync_state                       # Zweryfikuj synchronizację wielu instancji
godot_network simulate_peer count=50           # Test obciążeniowy 50 peerów
```

### 3. Efektywność tokenowa

Każde narzędzie ma projekt oszczędzający tokeny:

- **Tania obserwacja**: skrót stanu JSON zastępuje zrzuty ekranu (oszczędność 90% tokenów)
- **Zwroty diff**: zwracanie tylko zmienionych części
- **Kompresja zrzutów ekranu**: JPEG/WebP + zapis na dysk (nie w kontekście)
- **Rozdzielenie odczytu/zapisu**: odczyt automatycznie dozwolony, zapis blokowany
- **Operacje wsadowe**: wykonanie wielu operacji w jednym przejściu

### 4. Stabilność połączenia

Rozwiązuje problem "nie można połączyć" w istniejących MCP:

- Konfigurowalny port (env > EditorSettings > automatyczne omijanie)
- Wykrywanie rezerwacji portów Windows (omijanie portów zarezerwowanych przez Hyper-V/WSL2/Docker)
- Mechanizm heartbeatu (proaktywne wykrywanie martwych połączeń)
- Inteligentne ponowne połączenie (wykładnicze wycofywanie + maks. liczba prób + powiadomienie UI)

### 5. Kompleksowe debugowanie

- **DAP (Debugger Adapter Protocol)**: punkty przerwania, stepping, inspekcja zmiennych (stack_trace, variables, evaluate)
- **LSP (Language Server Protocol)**: diagnostyka statyczna, autouzupełnianie, przejście do definicji
- **Profiler**: migawki wydajności, analiza osi czasu, wykrywanie skoków

---

## Szybki start

### 1. Zainstaluj serwer MCP

```bash
uv tool install open-godot-mcp
# lub
pip install open-godot-mcp
```

### 2. Skonfiguruj klienta AI

```json
{
  "mcpServers": {
    "open-godot-mcp": {
      "command": "open-godot-mcp"
    }
  }
}
```

### 3. Otwórz projekt Godot

Addon wstrzykuje się automatycznie. Otwórz klienta AI i zacznij korzystać.

Pełny przewodnik instalacji: [Docs/06-Installation/Guide.md](Docs/06-Installation/Guide.md).

---

## Lista narzędzi

~30 narzędzi, ~130 akcji. Projekt z rozdzieleniem odczytu/zapisu.

| Domena | Narzędzie | Opis |
|--------|-----------|------|
| Editor | `godot_editor_read/edit` | Stan, scena, zaznaczenie |
| Scene | `godot_scene` | Tworzenie, odczyt, zapis |
| Node | `godot_node_read/edit` | CRUD, właściwości, grupy, sygnały |
| Script | `godot_script` | Edycja diff, walidacja |
| Project | `godot_project` | Ustawienia, autoloady |
| Input Map | `godot_input_map` | Zarządzanie InputMap |
| Resource | `godot_resource` | Inspekcja z uwzględnieniem typu |
| Animation | `godot_animation` | Tworzenie, ścieżki, presety |
| TileMap | `godot_tilemap` | Odczyt/zapis komórek |
| **Kontrola gry** | `godot_game` | play/stop/freeze |
| **Zegar** | `godot_game_time` | freeze/step/step_until |
| **Input** | `godot_input` | Klawiatura/mysz/pad/tekst |
| **Stan** | `godot_runtime_state` | digest/watch/signals |
| **Wstrzykiwanie** | `godot_exec` | eval/call/assert |
| Screenshot | `godot_screenshot` | Kompresja, zapis do pliku |
| Debugger | `godot_debugger` | Punkty przerwania DAP, stack_trace, variables, evaluate |
| Code | `godot_lsp` | Diagnostyka, uzupełnianie |
| Profiler | `godot_profiler` | Migawki, oś czasu |
| Test | `godot_test` | Framework, wykonywanie |
| **Sieć** | `godot_network` | Wiele instancji, synchronizacja, warunki sieciowe |
| Instance | `godot_instance` | Zarządzanie wieloma Godot |
| Filesystem | `godot_filesystem` | Odczyt/zapis, wyszukiwanie |
| Docs | `godot_docs` | Dopasowane do wersji |
| Log | `godot_log` | Zapytania przyrostowe |
| Batch | `godot_batch` | Wiele operacji naraz |
| Asset | `godot_asset` | Generowanie, zarządzanie |
| Export | `godot_export` | Presety, eksport |
| Health | `godot_health` | Sprawdzenie połączenia |

Pełne API: [Docs/02-Tools/Index.md](Docs/02-Tools/Index.md).

---

## Porównanie z istniejącymi serwerami Godot MCP

| Funkcja | godot-ai | godot-mcp | Coding-Solo | satelliteoflove | thediymaker | **Open Godot MCP** |
|---------|----------|-----------|-------------|-----------------|-------------|---------------------|
| Operacje edytora | ✅ | ✅ | ✅ | ✅ | ✅ 149 narzędzi | ✅ |
| Rzeczywista kontrola gry | ⚠️ | ⚠️ | ❌ | ✅ deterministyczne | ⚠️ | ✅ **deterministyczne+realtime** |
| Testowanie multiplayer | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **unikalne** |
| Debugowanie DAP | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Integracja LSP | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Efektywność tokenowa | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ✅ **kompleksowa** |
| Stabilność połączenia | ⚠️ | ❌ | — | ✅ | — | ✅ **najbardziej stabilne** |
| Licencja | open | open | MIT | MIT | MIT | **MIT** |

---

## FAQ

### Czym jest Model Context Protocol (MCP)?

[Model Context Protocol](https://modelcontextprotocol.io) to otwarty standard, który pozwala asystentom AI łączyć się z zewnętrznymi narzędziami i źródłami danych. Open Godot MCP to serwer MCP, który łączy AI z edytorem Godot Engine.

### Które wersje Godot są obsługiwane?

Godot 4.5 i nowsze. Addon korzysta z API Godot 4.x, w tym `EditorDebuggerPlugin`, `EditorInspector` oraz kanału komunikatów debuggera.

### Które klienci AI są kompatybilni?

Dowolny klient kompatybilny z MCP: Claude Desktop, Cursor, Windsurf, VS Code (z rozszerzeniem MCP), Continue, Zed oraz dowolny klient obsługujący standard Model Context Protocol.

### Czy obsługuje C# (wersja .NET Godot)?

Tak. Obsługiwane jest sprawdzanie składni C# oraz weryfikacja kompilacji. Zobacz [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/).

### Czym to się różni od innych serwerów Godot MCP?

Open Godot MCP to **jedyny** Godot MCP, który obsługuje testowanie gier multiplayer, integrację debuggera DAP (punkty przerwania, ślady stosu, inspekcja zmiennych) oraz inteligencję kodu LSP. Posiada również najbardziej kompleksowy projekt efektywności tokenowej.

### Czy to naprawdę darmowe?

Tak. 100% licencji MIT, bez modelu freemium, bez paywalla, bez blokowania funkcji. Wszystkie funkcje są darmowe dla każdego.

### Czy AI faktycznie potrafi grać w grę?

Tak. Dzięki deterministycznym testom rozgrywki AI może zamrozić zegar gry, przesuwać czas o precyzyjne kroki, wstrzykiwać scenariusze testowe, symulować input gracza, obserwować stan gry jako JSON oraz robić zrzuty ekranu — wszystko po to, aby zweryfikować, że zmiany kodu działają poprawnie.

### Jak działa testowanie multiplayer?

Open Godot MCP może uruchomić wiele instancji Godot (host + klienci), symulować peerów, wstrzykiwać warunki sieciowe (opóźnienie, utrata pakietów) oraz weryfikować, czy stan gry jest synchronizowany między instancjami.

---

## Dokumentacja

Pełny indeks dokumentacji: [Docs/README.md](Docs/README.md). Rozdzielony według folderów.

| Folder | Zawartość |
|--------|-----------|
| [Docs/00-Overview/](Docs/00-Overview/) | Przegląd funkcji, filozofia projektowania |
| [Docs/01-Architecture/](Docs/01-Architecture/) | Architektura, protokół, stabilność połączenia, wiele instancji, runtime |
| [Docs/02-Tools/](Docs/02-Tools/) | Pełna lista narzędzi (pliki per domena) |
| [Docs/03-Realtime-Testing/](Docs/03-Realtime-Testing/) | Deterministyczne testy rozgrywki (Przewodnik + Przykłady) |
| [Docs/04-Token-Efficiency/](Docs/04-Token-Efficiency/) | Projekt oszczędzający tokeny (Przewodnik + Strategie) |
| [Docs/05-Network-Testing/](Docs/05-Network-Testing/) | Testowanie multiplayer (Przewodnik + Przykłady) |
| [Docs/06-Installation/](Docs/06-Installation/) | Instalacja (Przewodnik + Rozwiązywanie problemów) |
| [Docs/07-Roadmap/](Docs/07-Roadmap/) | Plan rozwoju |
| [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/) | Kompatybilność C# Godot i sprawdzanie składni |
| [Docs/09-Research/](Docs/09-Research/) | Badania istniejących MCP, badania C# MCP |

---

## Podziękowania

Open Godot MCP stoi na ramionach gigantów, czerpiąc najlepsze z:

- [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp) (4.8k gwiazdek) — podstawowa architektura
- [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp) — deterministyczne testy rozgrywki, tania obserwacja, rozdzielenie odczytu/zapisu
- [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) — runtime kanału debuggera, Undo/Redo, rezerwacja portów Windows, 20+ konfiguracji klientów, McpTestSuite
- [tomyud1/godot-mcp](https://github.com/tomyud1/godot-mcp) — architektura dwukanałowa, serializacja Variant, ochrona przed usunięciem
- [rosskarchner/godot-mcp](https://github.com/rosskarchner/godot-mcp) — integracja DAP + LSP, wiele instancji, izolacja portów
- [Erodenn/godot-mcp-runtime](https://github.com/Erodenn/godot-mcp-runtime) — zerowy ślad, koncept Playwright dla Godot
- [thediymaker/godot-mcp](https://github.com/thediymaker/godot-mcp) — referencja szerokości 149 narzędzi

---

## Licencja

[MIT](LICENSE) — 100% open source, wszystkie funkcje darmowe, bez freemium, bez paywalla.
