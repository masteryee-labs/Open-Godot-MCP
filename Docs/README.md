# Open Godot MCP — Documentation

> 完整文件索引。按資料夾分類，解耦合設計——改 A 不會壞 B。

---

## 00-Overview — 功能概觀

- [Overview.md](00-Overview/Overview.md) — 為什麼做、設計理念、功能摘要、與現有 MCP 比較

## 01-Architecture — 架構

- [Architecture.md](01-Architecture/Architecture.md) — 三層架構、技術選型、目錄結構
- [Transport.md](01-Architecture/Transport.md) — 4 條通訊通道協議
- [Connection-Stability.md](01-Architecture/Connection-Stability.md) — 連線穩定設計（心跳/重連/port）
- [Multi-Instance.md](01-Architecture/Multi-Instance.md) — 多實例管理與 port 隔離
- [Runtime-Autoload.md](01-Architecture/Runtime-Autoload.md) — Runtime autoload 設計與啟動流程

## 02-Tools — 工具清單

- [Index.md](02-Tools/Index.md) — 工具總覽、設計原則、MCP Resources/Prompts
- [Editor.md](02-Tools/Editor.md) — `godot_editor_read/edit`
- [Scene-Node.md](02-Tools/Scene-Node.md) — `godot_scene` / `godot_node_read/edit`
- [Script.md](02-Tools/Script.md) — `godot_script`
- [Project.md](02-Tools/Project.md) — `godot_project` / `godot_input_map`
- [Resource.md](02-Tools/Resource.md) — `godot_resource` / `godot_animation` / `godot_tilemap`
- [Game-Control.md](02-Tools/Game-Control.md) — `godot_game` / `godot_game_time`
- [Input.md](02-Tools/Input.md) — `godot_input`
- [Runtime-State.md](02-Tools/Runtime-State.md) — `godot_runtime_state` / `godot_exec`
- [Screenshot.md](02-Tools/Screenshot.md) — `godot_screenshot`
- [Diagnostics.md](02-Tools/Diagnostics.md) — `godot_debugger` / `godot_lsp` / `godot_profiler`
- [Test.md](02-Tools/Test.md) — `godot_test`
- [Network.md](02-Tools/Network.md) — `godot_network`（連線遊戲測試）
- [Instance.md](02-Tools/Instance.md) — `godot_instance`
- [Filesystem.md](02-Tools/Filesystem.md) — `godot_filesystem` / `godot_docs` / `godot_log`
- [Utility.md](02-Tools/Utility.md) — `godot_batch` / `godot_asset` / `godot_export` / `godot_health`

## 03-Realtime-Testing — 確定性 Playtesting

- [Guide.md](03-Realtime-Testing/Guide.md) — 概念、時鐘控制、`_mcp_state()`、模式切換
- [Examples.md](03-Realtime-Testing/Examples.md) — 4 個完整工作流範例

## 04-Token-Efficiency — Token 效率

- [Guide.md](04-Token-Efficiency/Guide.md) — 原則、成本估算、AI Client 設定
- [Strategies.md](04-Token-Efficiency/Strategies.md) — 10 大省 token 策略

## 05-Network-Testing — 連線遊戲測試

- [Guide.md](05-Network-Testing/Guide.md) — 多實例、網路條件注入、確定性連線測試
- [Examples.md](05-Network-Testing/Examples.md) — 5 個完整工作流範例

## 06-Installation — 安裝

- [Guide.md](06-Installation/Guide.md) — 安裝步驟、AI Client 設定、進階設定
- [Troubleshooting.md](06-Installation/Troubleshooting.md) — 疑難排解

## 07-Roadmap — 開發路線圖

- [Roadmap.md](07-Roadmap/Roadmap.md) — 7 個 Phase、版本規劃、貢獻指南

## 08-CSharp-Support — C# Godot 支援

- [Compatibility.md](08-CSharp-Support/Compatibility.md) — C# Godot 相容性矩陣、斷層與對策
- [Syntax-Check.md](08-CSharp-Support/Syntax-Check.md) — Roslyn syntax-first C# 語法檢查方案

## 09-Research — 調研

- [Existing-MCP-Survey.md](09-Research/Existing-MCP-Survey.md) — 10+ 現有 Godot MCP 調研、截優去短分析
- [CSharp-MCP-Survey.md](09-Research/CSharp-MCP-Survey.md) — 5 個 C# Godot MCP 調研

---

## 解耦合設計

每個資料夾是獨立領域，檔案之間用相對連結引用。改一個檔案不會影響其他：

| 資料夾 | 耦合點 | 改動影響範圍 |
|--------|--------|-------------|
| 01-Architecture | 只被其他資料夾引用 | 改架構不影響工具 API |
| 02-Tools | 每個工具檔獨立 | 改 Editor.md 不影響 Network.md |
| 03/05-Testing | 引用 02-Tools | 改範例不影響工具定義 |
| 08-CSharp | 引用 02-Tools 的 C# 相關註記 | 改 C# 方案不影響 GDScript |
| 09-Research | 只被引用，不引用其他 | 改調研不影響設計文件 |
