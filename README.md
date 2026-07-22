<!--
SEO/AEO/GEO/LLMO Meta Block
=============================
@title: Open Godot MCP — AI 驅動的 Godot 遊戲開發、測試與除錯
@description: 開源 MCP server，讓 AI 自主開發 Godot 遊戲。確定性 playtesting、連線遊戲測試、DAP 除錯、LSP 整合、Token 效率。100% MIT。
@keywords: godot mcp, model context protocol, ai 遊戲開發, godot ai, 遊戲測試, playtesting, 確定性測試, 連線遊戲測試, 遊戲除錯, dap debugger, lsp 整合, gdscript, godot 4, 開源 mcp, ai 程式助手, claude mcp, 遊戲引擎 ai, 自動化遊戲測試, godot 插件, token 效率
@author: MasterYee Labs
@language: zh-TW
@og:type: software
@og:title: Open Godot MCP
@og:description: 開源 MCP server，讓 AI 自主開發、測試、除錯 Godot 遊戲——確定性 playtesting、連線測試、DAP 除錯、LSP、Token 效率。
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
  "softwareVersion": "0.1.8",
  "license": "https://opensource.org/licenses/MIT",
  "description": "開源 Model Context Protocol server，讓 AI 自主開發、測試、除錯 Godot 遊戲。具備確定性 playtesting、連線遊戲測試、DAP 除錯、LSP 整合、Token 效率設計。",
  "url": "https://github.com/masteryee-labs/Open-Godot-MCP",
  "programmingLanguage": ["GDScript", "Python"],
  "framework": "Godot Engine 4.5+",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  },
  "featureList": [
    "確定性 playtesting（freeze/step/step_until）",
    "連線遊戲測試（多實例、peer 模擬）",
    "DAP 除錯（breakpoint、stack_trace、variables、evaluate）",
    "LSP 整合（診斷、自動完成、go-to-definition）",
    "Token 效率設計（JSON digest、diff、截圖壓縮）",
    "30+ MCP tools，130+ actions",
    "Agnes / NVIDIA AI API 整合（視覺、產圖、產影片，動態註冊）",
    "行程生命週期管理（parent watchdog、--shutdown-all）",
    "Dock 面板截圖清理 UI（最大保留數 + 最大保留時數，per-project）",
    "專案級設定檔（每個專案可用不同 API key）",
    "連線穩定（心跳、智慧重連、port 自動避讓）"
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

> 開源、免費、全功能的 Model Context Protocol（MCP）server，讓 AI 自主開發、測試、除錯 Godot 遊戲——包含真實遊戲操作、確定性 playtesting、連線遊戲測試、DAP 除錯、LSP 整合、Token 效率設計。100% MIT 授權，無 freemium，無付費牆。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Godot 4.5+](https://img.shields.io/badge/Godot-4.5+-blue.svg)](https://godotengine.org)
[![Python 3.11+](https://img.shields.io/badge/Python-3.11+-green.svg)](https://python.org)
[![MCP](https://badge.mcpx.dev?type=server)](https://modelcontextprotocol.io)

**Languages:** 繁體中文（本檔）| [English](Docs/i18n/README_EN.md) | [简体中文](Docs/i18n/README.zh-CN.md) | [日本語](Docs/i18n/README.ja.md) | [한국어](Docs/i18n/README.ko.md) | [Español](Docs/i18n/README.es.md) | [Français](Docs/i18n/README.fr.md) | [Deutsch](Docs/i18n/README.de.md) | [Русский](Docs/i18n/README.ru.md) | [Português-BR](Docs/i18n/README.pt-BR.md) | [Polski](Docs/i18n/README.pl.md) | [Italiano](Docs/i18n/README.it.md) | [Türkçe](Docs/i18n/README.tr.md) | [ภาษาไทย](Docs/i18n/README.th.md) | [Tiếng Việt](Docs/i18n/README.vi.md) | [Bahasa Indonesia](Docs/i18n/README.id.md) | [Українська](Docs/i18n/README.uk.md) | [Nederlands](Docs/i18n/README.nl.md) | [العربية](Docs/i18n/README.ar.md) | [हिन्दी](Docs/i18n/README.hi.md)

---

## Open Godot MCP 是什麼？

**Open Godot MCP** 是一個開源的 [Model Context Protocol](https://modelcontextprotocol.io) server，將 AI 程式助手（Claude、GPT、Cursor、Windsurf 等）連接到 [Godot Engine](https://godotengine.org) 編輯器。它讓 AI 能夠**寫程式、運行遊戲、測試玩法、在斷點除錯、檢查變數、驗證修復**——全部自主完成，無需人工介入。

與只能編輯場景的現有 Godot MCP 不同，Open Godot MCP 讓 AI **真的玩遊戲**——透過確定性 playtesting（凍結時鐘 → step 時間 → 觀察狀態 → 驗證結果）。它是**唯一**支援**連線遊戲測試**、**DAP 除錯器整合**、**LSP 程式碼智慧**的 Godot MCP。

| 屬性 | 值 |
|------|-----|
| **專案類型** | MCP server（Model Context Protocol）for Godot Engine |
| **目標引擎** | Godot 4.5+（GDScript + C# 支援） |
| **執行環境** | Python 3.11+（server）+ GDScript（addon） |
| **授權** | MIT（100% 開源，無 freemium） |
| **工具數** | ~35 MCP tools（含 5 個動態註冊的 Agnes/NVIDIA AI 工具），~130 actions |
| **核心功能** | 確定性 playtesting、連線測試、DAP 除錯、LSP、Token 效率、Agnes/NVIDIA AI API 整合 |
| **AI 客戶端** | Claude Desktop、Cursor、Windsurf、VS Code（MCP）、Continue、Zed、任何 MCP 相容客戶端 |
| **平台** | Windows、macOS、Linux |
| **獨有能力** | 連線遊戲測試（其他 Godot MCP 都沒有）、DAP + LSP 整合 |

---

## 為什麼要做這個

市面上的 Godot MCP 都有缺陷：

| 問題 | 現有 MCP | Open Godot MCP |
|------|---------|-----------------|
| AI 看不到遊戲實際運行 | 只能編輯，不能玩遊戲修 BUG | **確定性 playtesting**——freeze 時鐘、step 精確時間、step_until 條件 |
| 連線不穩 | 硬編碼 port、無心跳、WSL2 衝突 | 可配置 port + 心跳 + 智慧重連 + port 自動避讓 |
| 無法測連線遊戲 | 所有 MCP 都缺 multiplayer 測試 | **獨有**——多實例、peer 模擬、同步驗證、網路條件注入 |
| Token 浪費 | 完整回傳、PNG 無壓縮、無 diff | cheap observation、截圖壓縮、diff、摘要、增量查詢 |
| 免費版閹割 | freemium，功能要付費 | **100% MIT 開源**，所有功能免費 |

---

## 適合誰用？

- **Godot 4 遊戲開發者**——想讓 AI 幫忙寫程式、測試、除錯
- **AI 輔助程式設計師**（Claude、Cursor、Windsurf、VS Code MCP 使用者）——在 Godot 專案上工作
- **獨立遊戲工作室**——需要自動化 playtesting，不想自己寫測試框架
- **連線遊戲開發者**——需要測試網路同步、延遲、peer 行為
- **開源倡議者**——想要完全免費、無付費牆的 MCP server

---

## 使用情境

| 情境 | Open Godot MCP 如何幫助 |
|------|--------------------------|
| **AI 修移動 bug** | AI 設斷點 → 運行遊戲 → 檢查變數 → 找到根因 → 修程式 → 重測 |
| **自動化 Boss 戰測試** | 凍結時鐘 → 生成 Boss → step 時間 → 模擬閃避輸入 → 驗證玩家存活 |
| **連線同步驗證** | 啟動 host + client 實例 → 注入延遲 → 比較同步狀態 → 偵測 desync bug |
| **效能分析** | 拍 profiler 快照 → 找 spike → 最佳化 → 重新測量 |
| **回歸測試** | 程式碼變更後跑測試套件 → 斷言遊戲狀態符合預期 |
| **關卡設計迭代** | AI 建立節點 → 排列場景 → 運行遊戲 → 截圖 → 調整 |

---

## 核心能力

### 1. 確定性 Playtesting（解決「AI 看不到遊戲運行」）

AI 不只寫程式，還能**自己玩遊戲驗證修復**：

```
godot_game play frozen=true                    # 啟動遊戲（凍結時鐘）
godot_exec eval code="GameState.wave = 3"      # 設定測試場景
godot_game_time step_until "boss.size() >= 1"  # 等待 Boss 出現
godot_runtime_state digest                     # 觀察狀態（JSON，不燒 vision token）
godot_game_time step ms=500 + dodge input      # 播放關鍵時刻
godot_screenshot game                          # 只在值得時截圖
```

### 2. 連線遊戲測試（獨有功能——其他 Godot MCP 都沒有）

所有現有 Godot MCP 都缺的能力：

```
godot_network launch_instance role="host"      # 啟動伺服器
godot_network launch_instance role="client"    # 啟動客戶端
godot_network network_condition latency=200    # 注入 200ms 延遲
godot_network sync_state                       # 驗證多實例同步
godot_network simulate_peer count=50           # 壓力測試 50 個 peer
```

### 3. Token 效率

每個工具都有省 token 設計：

- **cheap observation**：JSON state digest 取代截圖（省 90% token）
- **diff 回傳**：只回傳變更部分
- **截圖壓縮**：JPEG/WebP + 存磁碟（不進 context）
- **截圖自動清理**：自動輪轉（預設保留最近 50 張）+ 過期淘汰（預設 24 小時）+ 手動 `cleanup` action，防止垃圾檔累積。v0.1.6+ 可直接在 Dock 面板調整保留數和時數（per-project）
- **read/write 分離**：read auto-allow，write gate
- **批次操作**：一次 round-trip 完成多個操作

### 4. 連線穩定

解決現有 MCP「時常連線不到」的問題：

- 可配置 port（env > EditorSettings > 自動避讓）
- Windows Port Reservation 偵測（避開 Hyper-V/WSL2/Docker 保留 port）
- 心跳機制（主動偵測死連線）
- 智慧重連（指數退避 + 最大次數 + UI 通知）

### 5. 行程生命週期管理（Windows 孤兒行程防護）

MCP stdio 架構下，每個 AI client session 各自啟動一個 server 行程。Windows 殺 parent 時不會關閉 child 的 inherited stdin handle，導致孤兒行程永遠活著、越積越多。

- **Parent watchdog**：server 啟動後每 5 秒檢查 parent 是否存活，parent 消失即自動退出
- **`--shutdown-all`**：更新前一鍵清除所有殘留行程，解鎖 `.exe`，不需重開電腦

```bash
# 更新前清場（殺所有殘留 server 行程）
open-godot-mcp --shutdown-all
# 再跑更新
uv sync
```

### 6. 完整除錯

- **DAP（Debugger Adapter Protocol）**：breakpoint、step、變數 inspect（stack_trace、variables、evaluate）
- **LSP（Language Server Protocol）**：靜態診斷、自動完成、go-to-definition
- **Profiler**：效能快照、時序分析、spike 偵測

### 7. Agnes / NVIDIA AI API 整合（動態註冊）

5 個 AI 工具可選啟用，預設關閉。在 dock 面板填入 API key + 勾選子功能後才動態註冊，未啟用時 AI 工具清單完全看不到。支援多 key 輪換（429/402/401 自動換 key）+ 5xx 自動重試。

| 工具 | 來源 | 功能 | 費用 |
|------|------|------|------|
| `agnes_vision` | Agnes 2.0 Flash | 圖像理解（URL-only，本地檔自動上傳 uguu.se） | 免費 |
| `agnes_image_generate` | Agnes Image 2.0 Flash | 文生圖 / 圖生圖 | 免費 |
| `agnes_video_generate` | Agnes Video V2.0 | 產影片（非同步任務） | 免費 |
| `nvidia_vision` | NVIDIA NIM VLM | 圖像理解（base64 直傳，免上傳） | 免費 |
| `nvidia_image_generate` | NVIDIA FLUX.2-klein-4b | 文生圖 | 免費 |

Config 預設存於 `~/.open_godot_mcp/config.json`（user home，不在 git repo 內）。v0.1.6+ 可在 Dock 面板勾選「使用專案級設定檔」，改存於 `<專案>/.open_godot_mcp/config.json`（per-project，不同專案可用不同 API key）。詳見 [Docs/02-Tools/Agnes-NVIDIA.md](Docs/02-Tools/Agnes-NVIDIA.md)。

---

## 快速開始

### 1. 安裝 MCP Server

```bash
uv tool install open-godot-mcp
# 或
pip install open-godot-mcp
```

### 2. 設定 AI Client

```json
{
  "mcpServers": {
    "open-godot-mcp": {
      "command": "open-godot-mcp"
    }
  }
}
```

### 3. 開啟 Godot 專案

Addon 會自動注入。開啟 AI Client 開始用。

完整安裝指南見 [Docs/06-Installation/Guide.md](Docs/06-Installation/Guide.md)。

---

## 工具清單

~35 tools（含 5 個動態註冊的 Agnes/NVIDIA AI 工具），~130 actions。read/write 分離設計。

| 領域 | 工具 | 說明 |
|------|------|------|
| 編輯器 | `godot_editor_read/edit` | 狀態、場景、選取 |
| 場景 | `godot_scene` | 建立、讀取、儲存 |
| 節點 | `godot_node_read/edit` | CRUD、屬性、群組、signal |
| 腳本 | `godot_script` | diff 編輯、驗證 |
| 專案 | `godot_project` | 設定、autoload |
| 輸入映射 | `godot_input_map` | InputMap 管理 |
| 資源 | `godot_resource` | 型別感知檢視 |
| 動畫 | `godot_animation` | 建立、軌道、預設 |
| TileMapLayer | `godot_tilemap` | cell 讀寫 |
| **遊戲控制** | `godot_game` | play/stop/freeze |
| **時鐘** | `godot_game_time` | freeze/step/step_until |
| **輸入** | `godot_input` | 鍵盤/滑鼠/手把/文字 |
| **狀態** | `godot_runtime_state` | digest/watch/signals |
| **注入** | `godot_exec` | eval/call/assert |
| 截圖 | `godot_screenshot` | 壓縮、存檔、自動清理 |
| 除錯 | `godot_debugger` | DAP breakpoint、stack_trace、variables、evaluate |
| 程式碼 | `godot_lsp` | 診斷、完成 |
| 效能 | `godot_profiler` | 快照、時序 |
| 測試 | `godot_test` | 框架、執行 |
| **連線** | `godot_network` | 多實例、同步、網路條件 |
| 實例 | `godot_instance` | 多 Godot 管理 |
| 檔案 | `godot_filesystem` | 讀寫、搜尋 |
| 文件 | `godot_docs` | 版本對應 |
| 日誌 | `godot_log` | 增量查詢 |
| 批次 | `godot_batch` | 一次多操作 |
| 資產 | `godot_asset` | 生成、管理 |
| 匯出 | `godot_export` | 預設、匯出 |
| 健康 | `godot_health` | 連線檢查 |
| **Agnes 視覺** | `agnes_vision` | 圖像理解（動態註冊） |
| **Agnes 產圖** | `agnes_image_generate` | 文生圖/圖生圖（動態註冊） |
| **Agnes 產影片** | `agnes_video_generate` | 非同步影片生成（動態註冊） |
| **NVIDIA 視覺** | `nvidia_vision` | VLM 圖像理解（動態註冊） |
| **NVIDIA 產圖** | `nvidia_image_generate` | FLUX 文生圖（動態註冊） |

完整 API 見 [Docs/02-Tools/Index.md](Docs/02-Tools/Index.md)。

---

## 與現有 Godot MCP 比較

| 特性 | godot-ai | godot-mcp | Coding-Solo | satelliteoflove | thediymaker | **Open Godot MCP** |
|------|----------|-----------|-------------|-----------------|-------------|---------------------|
| 編輯器操作 | ✅ | ✅ | ✅ | ✅ | ✅ 149 tools | ✅ |
| 真實遊戲操作 | ⚠️ | ⚠️ | ❌ | ✅ 確定性 | ⚠️ | ✅ **確定性+即時** |
| 連線遊戲測試 | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **獨有** |
| DAP 除錯 | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| LSP 整合 | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Token 效率 | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ✅ **全面** |
| 連線穩定 | ⚠️ | ❌ | — | ✅ | — | ✅ **最穩** |
| 授權 | 開源 | 開源 | MIT | MIT | MIT | **MIT** |

---

## 常見問題

### 什麼是 Model Context Protocol（MCP）？

[Model Context Protocol](https://modelcontextprotocol.io) 是一個開放標準，讓 AI 助手連接外部工具和資料來源。Open Godot MCP 是一個 MCP server，將 AI 連接到 Godot Engine 編輯器。

### 支援哪些 Godot 版本？

Godot 4.5 及更新版本。Addon 使用 Godot 4.x API，包含 `EditorDebuggerPlugin`、`EditorInspector`、debugger message channel。

### 哪些 AI 客戶端相容？

任何 MCP 相容客戶端：Claude Desktop、Cursor、Windsurf、VS Code（MCP 擴充）、Continue、Zed，以及任何支援 Model Context Protocol 標準的客戶端。

### 支援 C#（Godot .NET 版）嗎？

是的。C# 語法檢查和編譯驗證已支援。見 [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/)。

### 跟其他 Godot MCP 有什麼不同？

Open Godot MCP 是**唯一**支援連線遊戲測試、DAP 除錯器整合（斷點、stack trace、變數檢查）、LSP 程式碼智慧的 Godot MCP。它也有最全面的 Token 效率設計。

### 真的免費嗎？

是的。100% MIT 授權，無 freemium 模式，無付費牆，無功能限制。所有功能對所有人免費。

### AI 真的能玩遊戲嗎？

是的。透過確定性 playtesting，AI 可以凍結遊戲時鐘、精確 step 時間、注入測試場景、模擬玩家輸入、以 JSON 觀察遊戲狀態、截圖——全部用來驗證程式碼變更是否正確。

### 連線遊戲測試怎麼運作？

Open Godot MCP 可以啟動多個 Godot 實例（host + client）、模擬 peer、注入網路條件（延遲、封包遺失）、驗證遊戲狀態跨實例同步。

### Agnes / NVIDIA AI 工具是什麼？

5 個可選啟用的 AI 工具（視覺、產圖、產影片），整合 Agnes AI API 和 NVIDIA NIM API。預設關閉，需在 dock 面板填入 API key + 勾選子功能後才動態註冊。支援多 key 輪換和 5xx 自動重試。兩家 API 都有免費額度。詳見 [Docs/02-Tools/Agnes-NVIDIA.md](Docs/02-Tools/Agnes-NVIDIA.md)。

---

## 文件

完整文件索引見 [Docs/README.md](Docs/README.md)。按資料夾分類，解耦合設計。

| 資料夾 | 內容 |
|--------|------|
| [Docs/00-Overview/](Docs/00-Overview/) | 功能概觀、設計理念 |
| [Docs/01-Architecture/](Docs/01-Architecture/) | 架構、通訊協議、連線穩定、多實例、runtime |
| [Docs/02-Tools/](Docs/02-Tools/) | 完整工具清單（按領域獨立檔案） |
| [Docs/03-Realtime-Testing/](Docs/03-Realtime-Testing/) | 確定性 playtesting（Guide + Examples） |
| [Docs/04-Token-Efficiency/](Docs/04-Token-Efficiency/) | 省 token 設計（Guide + Strategies） |
| [Docs/05-Network-Testing/](Docs/05-Network-Testing/) | 連線遊戲測試（Guide + Examples） |
| [Docs/06-Installation/](Docs/06-Installation/) | 安裝（Guide + Troubleshooting） |
| [Docs/07-Roadmap/](Docs/07-Roadmap/) | 開發路線圖 |
| [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/) | C# Godot 相容性與語法檢查 |
| [Docs/09-Research/](Docs/09-Research/) | 現有 MCP 調研、C# MCP 調研 |

---

## 致謝

Open Godot MCP 站在巨人的肩膀上，截優去短自以下專案：

- [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp)（4.8k stars）——基礎架構典範
- [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp)——確定性 playtesting、cheap observation、read/write 分離
- [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai)——debugger channel runtime、Undo/Redo、Windows port reservation、20+ client 配置、McpTestSuite
- [tomyud1/godot-mcp](https://github.com/tomyud1/godot-mcp)——雙通道架構、Variant 序列化、刪除保護
- [rosskarchner/godot-mcp](https://github.com/rosskarchner/godot-mcp)——DAP + LSP 整合、多實例、port isolation
- [Erodenn/godot-mcp-runtime](https://github.com/Erodenn/godot-mcp-runtime)——zero-footprint、Playwright for Godot 概念
- [thediymaker/godot-mcp](https://github.com/thediymaker/godot-mcp)——149 tools 的功能廣度參考

---

## 授權

[MIT](LICENSE)——100% 開源，所有功能免費，無 freemium，無付費牆。
