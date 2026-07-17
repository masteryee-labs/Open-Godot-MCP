# 00 — Overview

> Open Godot MCP 是一套開源、免費、全功能的 Model Context Protocol server，讓 AI 自主開發、測試、除錯 Godot 遊戲——包含真實遊戲操作、確定性 playtesting、連線遊戲測試，並內建 Token 效率設計。

---

## 為什麼要做這個

市面上已有不少 Godot MCP，但都有缺陷：

| 問題 | 現有 MCP 的表現 | Open Godot MCP 的對策 |
|------|----------------|----------------------|
| **AI 看不到遊戲實際運行** | 多數只能編輯場景，不能讓 AI 真的「玩」遊戲看角色行走、碰撞、動畫 | 確定性 playtesting：freeze 遊戲時鐘、step 精確時間切片、step_until 條件達成 |
| **連線不穩** | 硬編碼 port、無心跳、重連退避過長、WSL2/Hyper-V port 衝突 | 可配置 port + 心跳 + 智慧重連 + Windows port reservation 自動避讓 |
| **無法測連線遊戲** | 所有現有 MCP 都缺 multiplayer/network 測試 | 內建網路測試工具：啟動多實例、模擬 peer、驗證同步狀態 |
| **Token 浪費** | 每次回傳完整場景樹、PNG 截圖無壓縮、無 diff | cheap observation（JSON state digest）、截圖壓縮、diff 回傳、節點樹摘要 |
| **免費版功能閹割** | 網路上很多 MCP 免費版只開放少數功能，其他要付費 | 100% 開源 MIT，所有功能免費 |

---

## 設計理念

### 1. AI 能自主閉環驗證

> AI 不只是寫程式，還要能**檢查自己的工作**。

這是借鏡 [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp) 的核心理念，也是解決「AI 看不到遊戲實際運行」的關鍵。Open Godot MCP 讓 AI 可以：

- 啟動遊戲（frozen 或即時模式）
- 設定測試場景（runtime GDScript 注入）
- 模擬玩家輸入（鍵盤/滑鼠/手把/Action）
- 觀察遊戲狀態（JSON digest，不燒 vision token）
- step 遊戲時鐘到關鍵時刻
- 在值得時才截圖
- 證明改動達成預期

### 2. 確定性優先

遊戲是非確定系統——每幀的物理、輸入、時序都不同。直接跑遊戲觀察會「觀察與遊戲賽跑」。Open Godot MCP 採用 **freeze / step / step_until** 模型：

```
1. freeze 遊戲時鐘（遊戲停在 frame 0）
2. 注入測試場景（grant weapon, skip to wave 3, spawn test bot）
3. step_until 條件達成（boss 出現、玩家落地、血量歸零）
4. digest 觀察狀態（精確位置、速度、動畫——無需像素）
5. step + input 播放關鍵時刻
6. 截圖（只在值得花 token 時）
```

### 3. Token 效率是第一公民

AI 的 context window 是有限資源。Open Godot MCP 的每個工具都設計了省 token 模式：

- **cheap observation**：多數「畫面上發生什麼」的問題用 JSON state 回答，不花 vision token 截圖
- **read/write 分離**：read 工具可 auto-allow，write 工具 gate，AI context 不被用不到的 write 定義淹沒
- **diff 回傳**：場景樹變更只回傳差異
- **截圖壓縮**：JPEG/WebP 可選，解析度可降
- **節點樹摘要**：大型場景只回傳結構骨架，細節按需查詢
- **增量查詢**：`since_ms` 只回傳變更後的日誌/狀態

### 4. 連線穩定是底線

參考 [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) 的通訊設計並改進其弱點：

- **可配置 port**：環境變數 / EditorSettings / 自動避讓
- **Windows port reservation 偵測**：自動跳過 Hyper-V/WSL2/Docker 保留的 port
- **心跳機制**：主動偵測死連線，不靠被動 ping/pong
- **智慧重連**：指數退避 + 最大次數限制 + 連線狀態通知 UI
- **雙通道**：WebSocket（editor bridge）+ debugger channel（runtime），責任分離

### 5. 完整功能，免費開源

所有功能都在 MIT 授權下完全開放。沒有 freemium、沒有付費牆、沒有「pro 版」。

---

## 功能摘要

Open Godot MCP 提供六大能力領域：

| 領域 | 能力 | 詳見 |
|------|------|------|
| **編輯器控制** | 場景/節點/腳本/資源/專案設定/輸入映射 | [../02-Tools/Index.md](../02-Tools/Index.md) |
| **真實遊戲操作** | 啟動/停止/暫停/freeze/step/step_until | [../03-Realtime-Testing/Guide.md](../03-Realtime-Testing/Guide.md) |
| **輸入模擬** | 鍵盤/滑鼠/手把/Action/文字輸入，精確時序 | [../03-Realtime-Testing/Guide.md](../03-Realtime-Testing/Guide.md) |
| **遊戲狀態觀察** | JSON digest / watch window / signal timeline | [../03-Realtime-Testing/Guide.md](../03-Realtime-Testing/Guide.md) |
| **連線遊戲測試** | 多實例啟動 / peer 模擬 / 同步驗證 | [../05-Network-Testing/Guide.md](../05-Network-Testing/Guide.md) |
| **除錯與診斷** | DAP breakpoint / LSP / profiler / 效能監控 | [../02-Tools/Diagnostics.md](../02-Tools/Diagnostics.md) |

### 工具數量設計原則

> 不追求最多工具，追求最對的工具。

參考 [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp) 的 21 tools / 86 actions 設計，而非 [thediymaker/godot-mcp](https://github.com/thediymaker/godot-mcp) 的 149 tools。原因：

- **工具定義會佔 AI context**：149 個工具的 schema 定義會吃掉大量 token，AI 還沒開工就先花一堆 token 讀定義
- **相關操作收進同一工具的 actions**：`godot_node_read` 一個工具涵蓋 inspect / find / tree 等多個 action
- **read/write 分離**：read 工具可 auto-allow，write 工具 gate，安全且省 token

Open Godot MCP 目標：**~30 tools，~145 actions**，涵蓋完整工作流。

---

## 與現有 MCP 的比較

| 特性 | godot-ai | godot-mcp (tomyud1) | Coding-Solo | satelliteoflove | thediymaker | **Open Godot MCP** |
|------|----------|---------------------|-------------|-----------------|-------------|---------------------|
| Stars | — | — | 4.8k | 124 | — | 新專案 |
| 語言 | Python + GDScript | TS + GDScript | TS + GDScript | TS + GDScript | TS + GDScript | **Python + GDScript** |
| 編輯器操作 | ✅ 完整 | ✅ 完整 | ✅ 基本 | ✅ 完整 | ✅ 149 tools | ✅ 完整 |
| 真實遊戲操作 | ⚠️ 有限 | ⚠️ 有限 | ❌ | ✅ 確定性 | ⚠️ 即時 | ✅ **確定性 + 即時** |
| 輸入模擬 | ✅ | ✅ | ❌ | ✅ 完整 | ✅ | ✅ **完整** |
| 遊戲狀態觀察 | ⚠️ | ⚠️ | ❌ | ✅ JSON digest | ⚠️ | ✅ **JSON digest + watch** |
| 連線遊戲測試 | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **獨有** |
| DAP 除錯 | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| LSP 整合 | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Token 效率 | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ✅ **全面** |
| 連線穩定設計 | ⚠️ port 衝突 | ❌ 硬編碼 | — | ✅ | — | ✅ **最穩** |
| 測試框架 | ✅ McpTestSuite | ❌ | ❌ | ❌ | ❌ | ✅ |
| 授權 | 開源 | 開源 | MIT | MIT | MIT | **MIT** |

---

## 目標使用者

- **AI 遊戲開發者**：用 Claude Code / Cursor / Codex 等 AI 工具開發 Godot 遊戲，希望 AI 能自主驗證改動
- **Godot 遊戲團隊**：想要 AI 協助測試 gameplay、連線功能、效能
- **不想付費的開發者**：拒絕 freemium MCP，要完整開源方案

> **C# Godot 用戶請注意**：本專案以 GDScript 為主要測試對象。如果你用的是 Godot .NET (mono) build（C# 專案），大部分功能正常但有少數斷層——詳見 [../08-CSharp-Support/Compatibility.md](../08-CSharp-Support/Compatibility.md)。**如果你用的是標準 Godot build（純 GDScript 專案），全部功能都正常，不需讀 C# 相容性文件**。

---

## 不做什麼

- 不做閹割版 / 付費版
- 不做需要修改遊戲原始碼才能用的 runtime hook（autoload 是可選的，不污染專案）
- 不做只能編輯不能玩的 MCP
- 不做不穩定的連線機制

---

## 下一步

- [../01-Architecture/Architecture.md](../01-Architecture/Architecture.md) — 架構與通訊協議
- [../02-Tools/Index.md](../02-Tools/Index.md) — 完整工具清單
- [../03-Realtime-Testing/Guide.md](../03-Realtime-Testing/Guide.md) — 真實遊戲操作與確定性 playtesting
- [../06-Installation/Guide.md](../06-Installation/Guide.md) — 安裝與設定
- [../README.md](../README.md) — 完整文件索引
