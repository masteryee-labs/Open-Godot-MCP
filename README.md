# Open Godot MCP

> 開源、免費、全功能的 Model Context Protocol server，讓 AI 自主開發、測試、除錯 Godot 遊戲——包含真實遊戲操作、確定性 playtesting、連線遊戲測試，並內建 Token 效率設計。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Godot 4.5+](https://img.shields.io/badge/Godot-4.5+-blue.svg)](https://godotengine.org)
[![Python 3.11+](https://img.shields.io/badge/Python-3.11+-green.svg)](https://python.org)
[![MCP](https://badge.mcpx.dev?type=server)](https://modelcontextprotocol.io)

**Languages:** 繁體中文（本檔）| [English](README_EN.md) | [简体中文](README_zh-CN.md)

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

### 2. 連線遊戲測試（獨有功能）

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
- **read/write 分離**：read auto-allow，write gate
- **批次操作**：一次 round-trip 完成多個操作

### 4. 連線穩定

解決現有 MCP「時常連線不到」的問題：

- 可配置 port（env > EditorSettings > 自動避讓）
- Windows Port Reservation 偵測（避開 Hyper-V/WSL2/Docker 保留 port）
- 心跳機制（主動偵測死連線）
- 智慧重連（指數退避 + 最大次數 + UI 通知）

### 5. 完整除錯

- **DAP**：breakpoint、step、變數 inspect
- **LSP**：靜態診斷、自動完成、go-to-definition
- **Profiler**：效能快照、時序分析、spike 偵測

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

~30 tools，~130 actions。read/write 分離設計。

| 領域 | 工具 | 說明 |
|------|------|------|
| 編輯器 | `godot_editor_read/edit` | 狀態、場景、選取 |
| 場景 | `godot_scene` | 建立、讀取、儲存 |
| 節點 | `godot_node_read/edit` | CRUD、屬性、群組 |
| 腳本 | `godot_script` | diff 編輯、驗證 |
| 專案 | `godot_project` | 設定、autoload |
| 輸入映射 | `godot_input_map` | InputMap 管理 |
| 資源 | `godot_resource` | 型別感知檢視 |
| 動畫 | `godot_animation` | 建立、軌道、預設 |
| TileMap | `godot_tilemap` | cell 讀寫 |
| **遊戲控制** | `godot_game` | play/stop/freeze |
| **時鐘** | `godot_game_time` | freeze/step/step_until |
| **輸入** | `godot_input` | 鍵盤/滑鼠/手把/文字 |
| **狀態** | `godot_runtime_state` | digest/watch/signals |
| **注入** | `godot_exec` | eval/call |
| 截圖 | `godot_screenshot` | 壓縮、存檔 |
| 除錯 | `godot_debugger` | DAP breakpoint |
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

完整 API 見 [Docs/02-Tools/Index.md](Docs/02-Tools/Index.md)。

---

## 與現有 MCP 比較

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
