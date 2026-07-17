# C# Godot MCP 調研

> 對 5 個現有 C# Godot MCP 專案的調研。用於決定 Open Godot MCP 的 C# 支援策略。

> 結論見 [../08-CSharp-Support/Compatibility.md](../08-CSharp-Support/Compatibility.md)。

---

## 調研的專案

### 1. LuoxuanLove/godot-dotnet-mcp（33 stars）

- **語言**：GDScript 93.7% + C# 4.3%
- **Godot 版本**：4.6+ .NET
- **.NET**：8.0
- **架構**：Editor-native MCP（HTTP server 跑在 Godot 內，不需外部 process）
- **C# 分析**：**Roslyn `CSharpSyntaxTree` syntax-first 模式**——在 plugin 內執行，不需載入完整 SemanticModel 或 project workspace
- **關鍵引文**：
  > "C# analysis stays self-contained through a plugin-internal Roslyn syntax layer, with no external host process required."
  > "The C# layer uses Roslyn's official syntax tree APIs in a syntax-first mode: it extracts useful structure from `CSharpSyntaxTree` without loading a full SemanticModel or project workspace. That keeps the plugin portable, lightweight, and aligned with the Godot editor runtime."
- **參考價值**：**最關鍵**——證明 Roslyn syntax-first 可在 plugin 內輕量執行。Open Godot MCP 的 [C# 語法檢查](../08-CSharp-Support/Syntax-Check.md)方案基於此。

### 2. Ozymandros/Godot-MCP-Server

- **語言**：C# 99.2%
- **.NET**：10 SDK
- **架構**：.NET global tool，stdio JSON-RPC，headless CLI
- **特色**：適合 build server / container / CI
- **分層**：Clean architecture（Server / Application / Core / Infrastructure / Tests）
- **參考價值**：CI/CD 整合參考

### 3. jongalloway/godot-csharp-dev-mcp

- **語言**：C#
- **.NET**：10（server），Godot 支援的 .NET（addon）
- **架構**：獨立 MCP server（stdio）
- **特色**：scaffolding、Roslyn 模板生成、MSBuild、Godot exports、Roslyn 分析
- **關鍵引文**：
  > "The MCP server can target newer .NET because Godot does not load the server assembly."
  > "Tools that scaffold a Godot C# project should default to a Godot-supported target framework."
- **參考價值**：工作流參考（scaffolding + build automation）

### 4. LeanderM99/GodotMCP

- **語言**：TS server + C# EditorPlugin
- **Godot 版本**：4.6+ .NET
- **架構**：TS MCP server（stdio）+ C# EditorPlugin（WebSocket 6550）
- **參考價值**：架構參考（TS + C# 混合）

### 5. IvanMurzak/Godot-MCP

- **語言**：C#
- **Godot 版本**：4.3+ mono
- **.NET**：8.0
- **架構**：C# addon，雲端 backend（ai-game.dev）或 self-hosted
- **特色**：與 Unity-MCP 共享 MCP/reflection stack
- **參考價值**：商業模式參考（**不採用**——Open Godot MCP 是開源本地）

---

## 關鍵發現

### 1. Roslyn Syntax-First 是最佳 C# 語法檢查方案

LuoxuanLove 證明：
- 不需 OmniSharp 外部 process
- 不需完整 SemanticModel
- 在 plugin 內輕量執行
- 可攜、與 Godot editor runtime 對齊

### 2. Godot 4.3+ 已內建 Roslyn Analyzers

[PR #87253](https://github.com/godotengine/godot/pull/87253) 加入 GD0001/GD0002 等 Godot 專屬 C# 規則。這些在 `dotnet build` 時自動執行。

### 3. C# MCP 的兩種架構

| 架構 | 代表 | 優點 | 缺點 |
|------|------|------|------|
| Editor-native | LuoxuanLove | 不需外部 process、即時 | 綁定 Godot editor |
| 獨立 server | Ozymandros、jongalloway | CI/CD 友善、headless | 需額外連線 |

Open Godot MCP 採用**獨立 server**（Python），C# 語法檢查透過 bridge 呼叫 plugin 內的 Roslyn 或 `dotnet` CLI。

### 4. .NET 版本相容性

- MCP server 可用較新 .NET（Godot 不載入 server assembly）
- Godot addon 必須用 Godot 支援的 .NET 版本
- Scaffolding 工具應預設 Godot 支援的 target framework

---

## 對 Open Godot MCP 的啟示

1. **C# 語法檢查**：採用 Roslyn syntax-first（見 [../08-CSharp-Support/Syntax-Check.md](../08-CSharp-Support/Syntax-Check.md)）
2. **C# 相容性**：GDScript addon 能載入在 C# Godot，但有斷層（見 [../08-CSharp-Support/Compatibility.md](../08-CSharp-Support/Compatibility.md)）
3. **不採用雲端 backend**：IvanMurzak 的雲端模式不符合 Open Godot MCP 的開源本地理念
4. **.NET 版本**：MCP server（Python）不涉及 .NET；C# addon 需用 Godot 支援的 .NET
