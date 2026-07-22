<!--
SEO/AEO/GEO/LLMO Meta Block
=============================
@title: Open Godot MCP — Pengembangan, Pengujian & Debugging Game Godot Berbasis AI
@description: Server MCP open-source untuk pengembangan game Godot secara otonom oleh AI. Playtesting deterministik, pengujian multiplayer, debugging DAP, integrasi LSP, efisien token. 100% MIT.
@keywords: godot mcp, model context protocol, pengembangan game ai, godot ai, pengujian game, playtesting, pengujian deterministik, pengujian multiplayer, debugging game, dap debugger, integrasi lsp, gdscript, godot 4, mcp open source, asisten coding ai, claude mcp, ai game engine, pengujian game otomatis, plugin godot, efisiensi token
@author: MasterYee Labs
@language: id
@og:type: software
@og:title: Open Godot MCP
@og:description: Server MCP open-source untuk pengembangan game Godot berbasis AI — playtesting deterministik, pengujian multiplayer, debugging DAP, LSP, efisien token.
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
  "description": "Server Model Context Protocol open-source untuk pengembangan, pengujian, dan debugging game Godot secara otonom oleh AI. Mendukung playtesting deterministik, pengujian multiplayer, debugging DAP, integrasi LSP, dan desain efisien token.",
  "url": "https://github.com/masteryee-labs/Open-Godot-MCP",
  "programmingLanguage": ["GDScript", "Python"],
  "framework": "Godot Engine 4.5+",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  },
  "featureList": [
    "Playtesting deterministik (freeze/step/step_until)",
    "Pengujian game multiplayer (multi-instance, simulasi peer)",
    "Debugging DAP (breakpoints, stack_trace, variables, evaluate)",
    "Integrasi LSP (diagnostik, autocompletion, go-to-definition)",
    "Desain efisien token (digest JSON, diff, kompresi screenshot)",
    "30+ MCP tools, 130+ actions",
    "Stabilitas koneksi (heartbeat, reconnect cerdas, auto-hindari port)"
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

> Server Model Context Protocol (MCP) sumber terbuka, gratis, dan lengkap yang memungkinkan AI secara otonom mengembangkan, menguji, dan men-debug game Godot — termasuk kontrol game nyata, playtesting deterministik, pengujian multiplayer, debugging DAP, integrasi LSP, dan desain efisien token. 100% lisensi MIT, tanpa freemium, tanpa paywall.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Godot 4.5+](https://img.shields.io/badge/Godot-4.5+-blue.svg)](https://godotengine.org)
[![Python 3.11+](https://img.shields.io/badge/Python-3.11+-green.svg)](https://python.org)
[![MCP](https://badge.mcpx.dev?type=server)](https://modelcontextprotocol.io)

**Languages:** [繁體中文](../../README.md) | [English](README.en.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [Português-BR](README.pt-BR.md) | [Polski](README.pl.md) | [Italiano](README.it.md) | [Türkçe](README.tr.md) | [ภาษาไทย](README.th.md) | [Tiếng Việt](README.vi.md) | Bahasa Indonesia（本檔） | [Українська](README.uk.md) | [Nederlands](README.nl.md) | [العربية](README.ar.md) | [हिन्दी](README.hi.md)

---

## Apa itu Open Godot MCP?

**Open Godot MCP** adalah server [Model Context Protocol](https://modelcontextprotocol.io) open-source yang menghubungkan asisten coding AI (Claude, GPT, Cursor, Windsurf, dll.) ke editor [Godot Engine](https://godotengine.org). Memungkinkan AI untuk **menulis kode, menjalankan game, menguji gameplay, debug di breakpoint, memeriksa variabel, dan memverifikasi perbaikan** — semuanya secara otonom, tanpa intervensi manusia.

Berbeda dengan Godot MCP server yang ada yang hanya mengedit scene, Open Godot MCP memungkinkan AI **benar-benar memainkan game** melalui playtesting deterministik (bekukan clock → langkah waktu → amati state → verifikasi hasil). Ini adalah-satuunya Godot MCP yang mendukung **pengujian game multiplayer**, **integrasi debugger DAP**, dan **kecerdasan kode LSP**.

| Atribut | Nilai |
|---------|-------|
| **Tipe proyek** | Server MCP (Model Context Protocol) untuk Godot Engine |
| **Engine target** | Godot 4.5+ (dukungan GDScript + C#) |
| **Runtime** | Python 3.11+ (server) + GDScript (addon) |
| **Lisensi** | MIT (100% open source, tanpa freemium) |
| **Tools** | ~30 MCP tools, ~130 actions |
| **Fitur utama** | Playtesting deterministik, pengujian multiplayer, debugging DAP, LSP, efisiensi token |
| **AI clients** | Claude Desktop, Cursor, Windsurf, VS Code (MCP), Continue, Zed, semua client kompatibel MCP |
| **Platform** | Windows, macOS, Linux |
| **Kemampuan unik** | Pengujian multiplayer (tidak ada Godot MCP lain yang punya), integrasi DAP + LSP |

---

## Mengapa Ini Dibuat

Setiap Godot MCP di pasaran memiliki kekurangan:

| Masalah | MCP yang Ada | Open Godot MCP |
|---------|--------------|-----------------|
| AI tidak bisa melihat game berjalan sungguhan | Hanya edit, tidak bisa memainkan game untuk memperbaiki bug | **Playtesting deterministik** — kunci clock, langkah waktu presisi, step_until kondisi |
| Koneksi tidak stabil | Port hardcoded, tanpa heartbeat, konflik WSL2 | Port dapat dikonfigurasi + heartbeat + reconnect cerdas + auto-hindari port |
| Tidak bisa menguji multiplayer | Semua MCP tidak punya pengujian multiplayer | **Unik** — multi-instance, simulasi peer, verifikasi sinkronisasi, injeksi kondisi jaringan |
| Pemborosan token | Return penuh, PNG tidak terkompresi, tanpa diff | Observasi murah, kompresi screenshot, diff, ringkasan, query inkremental |
| Kastrasi freemium | Versi gratis dibatasi, bayar untuk fitur | **100% MIT open source**, semua fitur gratis |

---

## Untuk Siapa Ini?

- **Pengembang game yang menggunakan Godot 4** yang ingin AI membantu menulis, menguji, dan men-debug game mereka
- **Coder berbantuan AI** (pengguna Claude, Cursor, Windsurf, VS Code MCP) yang bekerja pada proyek Godot
- **Studio game indie** yang membutuhkan playtesting otomatis tanpa menulis framework pengujian
- **Pengembang game multiplayer** yang perlu menguji sinkronisasi jaringan, latency, dan perilaku peer
- **Pendukung open-source** yang menginginkan server MCP yang sepenuhnya gratis tanpa paywall

---

## Kasus Penggunaan

| Kasus Penggunaan | Bagaimana Open Godot MCP Membantu |
|-------------------|----------------------------------|
| **AI memperbaiki bug pergerakan** | AI set breakpoint → jalankan game → periksa variabel → identifikasi akar masalah → perbaiki kode → uji ulang |
| **Pengujian boss fight otomatis** | Bekukan clock → spawn boss → langkah waktu → simulasi input dodge → verifikasi pemain selamat |
| **Verifikasi sinkronisasi multiplayer** | Jalankan instance host + client → injeksi latency → bandingkan state sinkron → deteksi bug desync |
| **Profiling performa** | Ambil snapshot profiler → identifikasi spike → optimalkan → ukur ulang |
| **Pengujian regresi** | Jalankan suite pengujian setelah perubahan kode → assert state game sesuai ekspektasi |
| **Iterasi desain level** | AI buat node → susun scene → jalankan game → screenshot hasil → sesuaikan |

---

## Kemampuan Inti

### 1. Playtesting Deterministik (menyelesaikan "AI tidak bisa melihat game berjalan")

AI tidak hanya menulis kode — ia bisa **memainkan game sendiri untuk memverifikasi perbaikan**:

```
godot_game play frozen=true                    # Jalankan game (clock dibekukan)
godot_exec eval code="GameState.wave = 3"      # Siapkan skenario pengujian
godot_game_time step_until "boss.size() >= 1"  # Tunggu boss muncul
godot_runtime_state digest                     # Amati state (JSON, tanpa token visual)
godot_game_time step ms=500 + dodge input      # Mainkan momen krusial
godot_screenshot game                          # Screenshot hanya saat perlu
```

### 2. Pengujian Multiplayer (fitur unik — tidak ada Godot MCP lain yang punya)

Kemampuan yang tidak dimiliki Godot MCP lainnya:

```
godot_network launch_instance role="host"      # Mulai server
godot_network launch_instance role="client"    # Mulai client
godot_network network_condition latency=200    # Injeksi latency 200ms
godot_network sync_state                       # Verifikasi sinkronisasi multi-instance
godot_network simulate_peer count=50           # Stress test 50 peer
```

### 3. Efisiensi Token

Setiap tool dirancang untuk menghemat token:

- **Observasi murah**: digest state JSON menggantikan screenshot (hemat 90% token)
- **Return diff**: Hanya kembalikan bagian yang berubah
- **Kompresi screenshot**: JPEG/WebP + simpan ke disk (tidak di context)
- **Pemisahan baca/tulis**: baca auto-izin, tulis diawasi
- **Operasi batch**: Selesaikan banyak operasi dalam satu round-trip

### 4. Stabilitas Koneksi

Menyelesaikan masalah "tidak bisa terhubung" pada MCP yang ada:

- Port dapat dikonfigurasi (env > EditorSettings > auto-hindari)
- Deteksi Reservasi Port Windows (hindari port reserved Hyper-V/WSL2/Docker)
- Mekanisme heartbeat (deteksi koneksi mati secara proaktif)
- Reconnect cerdas (exponential backoff + max retries + notifikasi UI)

### 5. Debugging Lengkap

- **DAP (Debugger Adapter Protocol)**: breakpoint, stepping, inspeksi variabel (stack_trace, variables, evaluate)
- **LSP (Language Server Protocol)**: diagnostik statis, autocompletion, go-to-definition
- **Profiler**: snapshot performa, analisis timeline, deteksi spike

---

## Mulai Cepat

### 1. Install MCP Server

```bash
uv tool install open-godot-mcp
# atau
pip install open-godot-mcp
```

### 2. Konfigurasi AI Client

```json
{
  "mcpServers": {
    "open-godot-mcp": {
      "command": "open-godot-mcp"
    }
  }
}
```

### 3. Buka Proyek Godot

Addon otomatis ter-inject. Buka AI client Anda dan mulai gunakan.

Panduan instalasi lengkap: [Docs/06-Installation/Guide.md](Docs/06-Installation/Guide.md).

---

## Daftar Tool

~30 tool, ~130 aksi. Desain pemisahan baca/tulis.

| Domain | Tool | Deskripsi |
|--------|------|-----------|
| Editor | `godot_editor_read/edit` | State, scene, seleksi |
| Scene | `godot_scene` | Buat, baca, simpan |
| Node | `godot_node_read/edit` | CRUD, properti, grup, sinyal |
| Script | `godot_script` | Edit diff, validasi |
| Project | `godot_project` | Pengaturan, autoload |
| Input Map | `godot_input_map` | Manajemen InputMap |
| Resource | `godot_resource` | Inspeksi sadar-tipe |
| Animation | `godot_animation` | Buat, track, preset |
| TileMapLayer | `godot_tilemap` | Baca/tulis cell |
| **Kontrol Game** | `godot_game` | play/stop/freeze |
| **Clock** | `godot_game_time` | freeze/step/step_until |
| **Input** | `godot_input` | Keyboard/mouse/gamepad/teks |
| **State** | `godot_runtime_state` | digest/watch/sinyal |
| **Injeksi** | `godot_exec` | eval/call/assert |
| Screenshot | `godot_screenshot` | Kompresi, simpan ke file |
| Debugger | `godot_debugger` | DAP breakpoint, stack_trace, variables, evaluate |
| Code | `godot_lsp` | Diagnostik, completion |
| Profiler | `godot_profiler` | Snapshot, timeline |
| Test | `godot_test` | Framework, eksekusi |
| **Jaringan** | `godot_network` | Multi-instance, sinkronisasi, kondisi jaringan |
| Instance | `godot_instance` | Manajemen multi-Godot |
| Filesystem | `godot_filesystem` | Baca/tulis, cari |
| Docs | `godot_docs` | Cocok versi |
| Log | `godot_log` | Query inkremental |
| Batch | `godot_batch` | Banyak operasi sekaligus |
| Asset | `godot_asset` | Generasi, manajemen |
| Export | `godot_export` | Preset, export |
| Health | `godot_health` | Cek koneksi |

API lengkap: [Docs/02-Tools/Index.md](Docs/02-Tools/Index.md).

---

## Perbandingan dengan Godot MCP Server yang Ada

| Fitur | godot-ai | godot-mcp | Coding-Solo | satelliteoflove | thediymaker | **Open Godot MCP** |
|---------|----------|-----------|-------------|-----------------|-------------|---------------------|
| Operasi editor | ✅ | ✅ | ✅ | ✅ | ✅ 149 tool | ✅ |
| Kontrol game nyata | ⚠️ | ⚠️ | ❌ | ✅ deterministik | ⚠️ | ✅ **deterministik+realtime** |
| Pengujian multiplayer | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **unik** |
| Debugging DAP | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Integrasi LSP | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Efisiensi token | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ✅ **komprehensif** |
| Stabilitas koneksi | ⚠️ | ❌ | — | ✅ | — | ✅ **paling stabil** |
| Lisensi | open | open | MIT | MIT | MIT | **MIT** |

---

## FAQ

### Apa itu Model Context Protocol (MCP)?

[Model Context Protocol](https://modelcontextprotocol.io) adalah standar terbuka yang memungkinkan asisten AI terhubung ke tool dan sumber data eksternal. Open Godot MCP adalah server MCP yang menghubungkan AI ke editor Godot Engine.

### Versi Godot mana yang didukung?

Godot 4.5 dan yang lebih baru. Addon menggunakan API Godot 4.x termasuk `EditorDebuggerPlugin`, `EditorInspector`, dan kanal pesan debugger.

### AI client mana yang kompatibel?

Semua client kompatibel MCP: Claude Desktop, Cursor, Windsurf, VS Code (dengan ekstensi MCP), Continue, Zed, dan semua client yang mendukung standar Model Context Protocol.

### Apakah mendukung C# (versi .NET Godot)?

Ya. Pemeriksaan sintaks C# dan verifikasi kompilasi didukung. Lihat [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/).

### Bagaimana ini berbeda dari Godot MCP server lain?

Open Godot MCP adalah-satuunya Godot MCP yang mendukung pengujian game multiplayer, integrasi debugger DAP (breakpoint, stack trace, inspeksi variabel), dan kecerdasan kode LSP. Juga memiliki desain efisiensi token paling komprehensif.

### Apakah benar-benar gratis?

Ya. 100% lisensi MIT, tanpa model freemium, tanpa paywall, tanpa pembatasan fitur. Semua fitur gratis untuk semua orang.

### Bisakah AI benar-benar memainkan game?

Ya. Melalui playtesting deterministik, AI bisa membekukan clock game, melangkah waktu maju dengan presisi, menginjeksi skenario pengujian, mensimulasikan input pemain, mengamati state game sebagai JSON, dan mengambil screenshot — semuanya untuk memverifikasi bahwa perubahan kode berfungsi dengan benar.

### Bagaimana pengujian multiplayer bekerja?

Open Godot MCP bisa menjalankan beberapa instance Godot (host + client), mensimulasikan peer, menginjeksi kondisi jaringan (latency, packet loss), dan memverifikasi bahwa state game tersinkronisasi antar instance.

---

## Dokumentasi

Indeks dokumentasi lengkap: [Docs/README.md](Docs/README.md). Dipisahkan per folder.

| Folder | Konten |
|--------|---------|
| [Docs/00-Overview/](Docs/00-Overview/) | Ikhtisar fitur, filosofi desain |
| [Docs/01-Architecture/](Docs/01-Architecture/) | Arsitektur, protokol, stabilitas koneksi, multi-instance, runtime |
| [Docs/02-Tools/](Docs/02-Tools/) | Daftar tool lengkap (file per-domain) |
| [Docs/03-Realtime-Testing/](Docs/03-Realtime-Testing/) | Playtesting deterministik (Panduan + Contoh) |
| [Docs/04-Token-Efficiency/](Docs/04-Token-Efficiency/) | Desain hemat token (Panduan + Strategi) |
| [Docs/05-Network-Testing/](Docs/05-Network-Testing/) | Pengujian multiplayer (Panduan + Contoh) |
| [Docs/06-Installation/](Docs/06-Installation/) | Instalasi (Panduan + Pemecahan Masalah) |
| [Docs/07-Roadmap/](Docs/07-Roadmap/) | Roadmap pengembangan |
| [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/) | Kompatibilitas & cek sintaks C# Godot |
| [Docs/09-Research/](Docs/09-Research/) | Riset MCP yang ada, riset MCP C# |

---

## Ucapan Terima Kasih

Open Godot MCP berdiri di atas bahu raksasa, mengambil yang terbaik dari:

- [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp) (4.8k stars) — arsitektur dasar
- [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp) — playtesting deterministik, observasi murah, pemisahan baca/tulis
- [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) — runtime kanal debugger, Undo/Redo, reservasi port Windows, 20+ konfigurasi client, McpTestSuite
- [tomyud1/godot-mcp](https://github.com/tomyud1/godot-mcp) — arsitektur dual-channel, serialisasi Variant, proteksi hapus
- [rosskarchner/godot-mcp](https://github.com/rosskarchner/godot-mcp) — integrasi DAP + LSP, multi-instance, isolasi port
- [Erodenn/godot-mcp-runtime](https://github.com/Erodenn/godot-mcp-runtime) — zero-footprint, konsep Playwright untuk Godot
- [thediymaker/godot-mcp](https://github.com/thediymaker/godot-mcp) — referensi keluasan 149 tool

---

## Lisensi

[MIT](LICENSE) — 100% open source, semua fitur gratis, tanpa freemium, tanpa paywall.
