# C# 語法檢查

> 讓 AI 在送出 C# 程式碼前先本地語法檢查，省下把錯誤碼丟回 AI 重試的 token。

> C# 整體相容性見 [Compatibility.md](Compatibility.md)。

---

## 為什麼要補上

用戶提出：

> 「MCP 有的會直接做簡單的檢查語法錯誤，這樣就可以讓 AI 省 Token，不用丟回去 AI 檢查，但一般好像也只有 GDScript 版本。」

### 研究結論：要補上

1. **Godot 4.3+ 已內建 Roslyn analyzers**（GD0001/GD0002 等 Godot 專屬 C# 規則）
2. **[LuoxuanLove/godot-dotnet-mcp](https://github.com/LuoxuanLove/godot-dotnet-mcp) 證明 Roslyn syntax-first 模式可在 plugin 內輕量執行**，不需啟動 OmniSharp 外部 process
3. 讓 AI 在送出 C# 程式碼前先本地語法檢查，**省下把錯誤碼丟回 AI 重試的 token**
4. `dotnet build` 也能抓編譯錯誤，但較重；Roslyn syntax-first 更快

---

## 方案：Roslyn Syntax-First 診斷

### 什麼是 Syntax-First

Roslyn 的 `CSharpSyntaxTree` 可以在不載入完整 SemanticModel 或 project workspace 的情況下，從語法樹提取有用結構。這稱為 **syntax-first 模式**。

### 為什麼選 Syntax-First

| 方案 | 優點 | 缺點 |
|------|------|------|
| `dotnet build` | 完整編譯檢查 | 重、慢、需完整 workspace |
| OmniSharp LSP | 完整 IDE 功能 | 需外部 process、重 |
| **Roslyn syntax-first** | 輕量、plugin 內、不需外部 process | 只抓語法錯誤，不抓語意錯誤 |

> **取捨**：AI 送出程式碼前的快速檢查，syntax-first 足夠且最快。完整編譯檢查用 `dotnet build`（AI 可呼叫）。

### 實作方式

在 C# addon 內（或 Python MCP Server 透過 `dotnet` 呼叫）：

```csharp
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;

public List<Diagnostic> CheckSyntax(string source)
{
    var tree = CSharpSyntaxTree.ParseText(source);
    var root = tree.GetRoot();
    
    var diagnostics = new List<Diagnostic>();
    
    // 1. 語法錯誤（Roslyn 內建）
    foreach (var diag in tree.GetDiagnostics())
    {
        if (diag.Severity == DiagnosticSeverity.Error)
            diagnostics.Add(diag);
    }
    
    // 2. Godot 專屬規則（GD0001/GD0002 等）
    // 透過 Godot NuGet 套件的 analyzers
    var compilation = CSharpCompilation.Create("check",
        new[] { tree },
        new[] { MetadataReference.CreateFromFile(typeof(GodotObject).Assembly.Location) });
    
    var analyzerDiagnostics = compilation.GetDiagnostics()
        .Where(d => d.Severity == DiagnosticSeverity.Error);
    
    diagnostics.AddRange(analyzerDiagnostics);
    
    return diagnostics;
}
```

### Python MCP Server 端

若 MCP Server 是 Python，透過 `dotnet` CLI 呼叫一個小的 C# 工具：

```bash
dotnet run --project tools/csharp_check -- source.cs
# → {errors: [{line: 10, col: 5, message: "CS1002: ; expected"}]}
```

或用 [LuoxuanLove](https://github.com/LuoxuanLove/godot-dotnet-mcp) 的方式——在 Godot plugin 內（C#）直接執行，結果透過 bridge 回傳。

---

## 工具設計

### `godot_csharp_check`（新工具，Phase 6）

| Action | 類型 | 參數 | 回傳 | 說明 |
|--------|------|------|------|------|
| `syntax` | read | `path` 或 `source` | `{errors: [{line, col, code, message}], ok: bool}` | Roslyn syntax-first 語法檢查 |
| `build` | read | `project?` | `{errors: [], ok: bool}` | `dotnet build` 完整編譯檢查 |
| `analyze` | read | `path` | `{diagnostics: []}` | Godot Roslyn analyzers（GD0001 等） |

### 與 `godot_lsp` 的關係

| 工具 | 語言 | 方式 |
|------|------|------|
| `godot_lsp diagnostics` | GDScript | Godot 內建 LSP |
| `godot_csharp_check syntax` | C# | Roslyn syntax-first |
| `godot_csharp_check build` | C# | `dotnet build` |

---

## Godot 專屬 C# 診斷規則

Godot 4.3+ 內建的 Roslyn analyzers（[PR #87253](https://github.com/godotengine/godot/pull/87253)）：

| 規則 | 說明 |
|------|------|
| GD0001 | 衍生自 GodotObject 的類別必須加 `partial` 修飾詞 |
| GD0002 | Godot 類別的 `Export` 屬性必須使用支援的型別 |

> 完整規則清單見 Godot 原始碼的 `modules/mono/glue/GodotSharp/SourceGenerators/`。

這些規則在 `dotnet build` 時自動執行，也可在 `godot_csharp_check analyze` 時單獨執行。

---

## 省 Token 效益

```
❌ 沒有語法檢查：
   AI 寫 C# → dotnet build → 編譯錯誤 → 錯誤訊息回傳 AI → AI 重寫 → 重試
   Token 成本：每次錯誤 ~500 tokens（錯誤訊息 + AI 重新思考）

✅ 有 Roslyn syntax-first：
   AI 寫 C# → godot_csharp_check syntax → 語法錯誤本地抓 → AI 修正 → 再檢查
   Token 成本：語法錯誤不進 AI context（本地處理）
   只有語意/邏輯錯誤才需 dotnet build + AI 處理
```

> **預估**：C# 專案開發 token 消耗減少 30-50%（多數錯誤是語法錯誤，本地抓掉）。

---

## 實作優先級

- **Phase 6**（未來擴展）：完整 `godot_csharp_check` 工具
- **Phase 0-5**（短期）：AI 可用 `dotnet build` 手動檢查（透過 `godot_filesystem` 或 shell）

> 短期內 C# 專案的語法檢查靠 AI 呼叫 `dotnet build`，長期才有專用工具。
