# 現有 Godot MCP 調研

> 對 20+ 現有 Godot MCP 專案的調研結果。Open Godot MCP 的設計基於此調研的「截優去短」。
>
> **付費競品分析**：[Paid-MCP-Analysis.md](Paid-MCP-Analysis.md)

---

## 調研的專案

### 免費開源

| 專案 | Stars | 語言 | 核心特色 |
|------|-------|------|----------|
| [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp) | 4.8k | TS + GDScript | 基礎架構典範 |
| [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp) | 124 | TS + GDScript | 確定性 playtesting、cheap observation |
| [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) | — | Python + GDScript | debugger channel、Undo/Redo、port reservation |
| [tomyud1/godot-mcp](https://github.com/tomyud1/godot-mcp) | 392 | TS + GDScript | 雙通道、Variant 序列化、視覺化工具 |
| [rosskarchner/godot-mcp](https://github.com/rosskarchner/godot-mcp) | 1 | Python + GDScript | DAP + LSP、多實例 |
| [Erodenn/godot-mcp-runtime](https://github.com/Erodenn/godot-mcp-runtime) | 47 | TS + GDScript | zero-footprint、Playwright for Godot |
| [thediymaker/godot-mcp](https://github.com/thediymaker/godot-mcp) | — | TS + GDScript | 149 tools（功能廣但 token 重） |
| [Rufaty/godot-mcp-enhanced](https://github.com/Rufaty/godot-mcp-enhanced) | — | TS + GDScript | 即時互動、輸入模擬 |
| [Sods2/godot-mcp](https://github.com/Sods2/godot-mcp) | — | TS + GDScript | IDE 整合 |
| [yurineko73/Godot-MCP-Native](https://github.com/yurineko73/Godot-MCP-Native) | 415 | GDScript | 純原生、155 tools、無需 Node.js |
| [Farraskuy/Godot-MCP](https://github.com/Farraskuy/Godot-MCP) | — | TS + GDScript | 168 tools、25 categories、UndoRedo |
| [tugcantopaloglu/godot-mcp](https://github.com/tugcantopaloglu/godot-mcp) | — | TS + GDScript | 157 tools、C# support、3D/Nav/Shader |
| [IvanMurzak/Godot-MCP](https://github.com/IvanMurzak/Godot-MCP) | — | C# + GDScript | C# editor addon、雲端後端 |
| [LuoxuanLove/godot-dotnet-mcp](https://github.com/LuoxuanLove/godot-dotnet-mcp) | — | C# + GDScript | Roslyn C# 語法診斷、.NET 專用 |
| [LeanderM99/GodotMCP](https://github.com/LeanderM99/GodotMCP) | — | TS + C# | C# EditorPlugin、.NET 專用 |
| [TransitionMatrix/godot-dap-mcp-server](https://github.com/TransitionMatrix/godot-dap-mcp-server) | — | Go | DAP debugging 專用 |
| [marcushale/godot-ai-playtest](https://github.com/marcushale/godot-ai-playtest) | — | Python + GDScript | 外部 TCP 控制、CI 整合 |
| [mrf/godot-stagehand](https://github.com/mrf/godot-stagehand) | — | Go + GDScript | Playwright for Godot、視覺回歸 |
| [koltyakov/godot-mcp](https://github.com/koltyakov/godot-mcp) | — | TS + GDScript | MCP Resources/Prompts、godot:// resources |

### 付費

| 專案 | 定價 | 工具數 | 核心賣點 |
|------|------|--------|----------|
| [Godot MCP Pro](https://y1uda.itch.io/godot-mcp-pro) | $15 | 175 | 工具廣度、23 類別 |
| [GodotIQ Pro](https://godotiq.com) | $19 | 24+14 | 靜態分析智慧工具 |
| [Beckett Full](https://beckettlabs.itch.io/beckett-godot-mcp) | $15 | 37 packs | AI playtest + assert + screenshot diff |
| [StraySpark](https://www.strayspark.studio/products/godot-mcp-server) | $32-$96 | 131 | 完整 + 商用授權 |

---

## 截優去短分析

### 採用的設計

| 採用自 | 設計 | 用於 |
|--------|------|------|
| satelliteoflove | 確定性 playtesting（freeze/step/step_until） | [../03-Realtime-Testing/Guide.md](../03-Realtime-Testing/Guide.md) |
| satelliteoflove | cheap observation（JSON digest 不燒 vision token） | [../04-Token-Efficiency/Strategies.md](../04-Token-Efficiency/Strategies.md) |
| satelliteoflove | read/write 分離 | [../02-Tools/Index.md](../02-Tools/Index.md) |
| satelliteoflove | `_mcp_state()` 協議 | [../01-Architecture/Runtime-Autoload.md](../01-Architecture/Runtime-Autoload.md) |
| godot-ai | debugger channel runtime | [../01-Architecture/Transport.md](../01-Architecture/Transport.md) |
| godot-ai | Undo/Redo 支援 | [../02-Tools/Scene-Node.md](../02-Tools/Scene-Node.md) |
| godot-ai | Windows port reservation | [../01-Architecture/Connection-Stability.md](../01-Architecture/Connection-Stability.md) |
| godot-ai | McpTestSuite | [../02-Tools/Test.md](../02-Tools/Test.md) |
| godot-ai | 20+ client 配置 | [../06-Installation/Guide.md](../06-Installation/Guide.md) |
| godot-mcp (tomyud1) | 雙通道架構 | [../01-Architecture/Architecture.md](../01-Architecture/Architecture.md) |
| godot-mcp (tomyud1) | Variant 序列化 | [../01-Architecture/Architecture.md](../01-Architecture/Architecture.md) |
| godot-mcp (tomyud1) | 刪除保護 | [../02-Tools/Filesystem.md](../02-Tools/Filesystem.md) |
| rosskarchner | DAP + LSP 整合 | [../02-Tools/Diagnostics.md](../02-Tools/Diagnostics.md) |
| rosskarchner | 多實例、port isolation | [../01-Architecture/Multi-Instance.md](../01-Architecture/Multi-Instance.md) |
| Erodenn | zero-footprint runtime | [../01-Architecture/Runtime-Autoload.md](../01-Architecture/Runtime-Autoload.md) |

### 去掉的短處

| 來自 | 短處 | Open Godot MCP 的對策 |
|------|------|----------------------|
| godot-mcp (tomyud1) | 硬編碼 port 6505 | 可配置 port（見 [../01-Architecture/Connection-Stability.md](../01-Architecture/Connection-Stability.md)） |
| godot-mcp (tomyud1) | 無心跳 | 心跳機制 |
| godot-mcp (tomyud1) | 重連退避過長 | 智慧重連 |
| godot-mcp (tomyud1) | runtime 只能查不能改 | runtime 可注入 GDScript |
| godot-mcp (tomyud1) | 無測試框架 | McpTestSuite |
| godot-mcp (tomyud1) | 無網路測試 | [../05-Network-Testing/](../05-Network-Testing/) |
| godot-ai | 無 multiplayer 測試 | [../05-Network-Testing/](../05-Network-Testing/) |
| godot-ai | 無 token 優化 | [../04-Token-Efficiency/](../04-Token-Efficiency/) |
| godot-ai | port 衝突需手動 | 自動避讓 |
| thediymaker | 149 tools token 重 | 30 tools（見 [../04-Token-Efficiency/Guide.md](../04-Token-Efficiency/Guide.md)） |
| 所有 | 無連線遊戲測試 | [../05-Network-Testing/](../05-Network-Testing/)（獨有） |

---

## 詳細分析

### godot-ai（hi-godot）

- **架構**：Python FastMCP + GDScript，WebSocket 9500 + HTTP 8000
- **工具**：120+ ops，33+ handlers
- **強項**：debugger channel runtime、Undo/Redo、Windows port reservation、20+ client 配置、McpTestSuite、backpressure 控制
- **弱項**：無 multiplayer 測試、無 token 優化、port 衝突需手動、重連無上限

### godot-mcp（tomyud1）

- **架構**：TS + GDScript，WebSocket 6505（硬編碼）
- **工具**：完整編輯器操作 + 有限 runtime
- **強項**：雙通道架構、Variant 序列化、刪除保護、專案映射
- **弱項**：硬編碼 port、無心跳、重連退避過長、runtime 只能查不能改、無測試框架、無網路測試——**這是「時常連線不到」的根因**

### satelliteoflove

- **架構**：TS + GDScript，WebSocket 6550
- **工具**：21 tools / 86 actions
- **強項**：確定性 playtesting、cheap observation、read/write 分離、`_mcp_state()`、`--read-only` flag
- **弱項**：需 Node.js、單實例、無網路測試

### rosskarchner

- **架構**：Python + GDScript
- **強項**：DAP + LSP 整合、多實例、port isolation、MCP resources/prompts、自動注入 addon
- **弱項**：無網路條件注入、無同步驗證
