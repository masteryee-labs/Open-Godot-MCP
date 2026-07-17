# C# Godot 相容性

> Godot .NET (mono) build 的相容性分析。基於對 5 個現有 C# Godot MCP 專案的網路調研。

> 語法檢查方案見 [Syntax-Check.md](Syntax-Check.md)。

> **如果你用的是純 GDScript 專案（標準 Godot build，非 .NET/mono）**：**本文件不適用於你，全部功能都正常運作，忽略整份文件及所有工具文件內的「C# Godot」警告**。C# 相容性說明是寫給使用 Godot .NET (mono) build 的專案——那類專案同時支援 GDScript 和 C#，但部分 GDScript 專用工具在 C# 程式碼上有斷層。純 GDScript 專案不涉及 C# 程式碼，沒有任何斷層。

---

## 核心結論

Godot .NET (mono) build **同時支援 GDScript 和 C#**。GDScript 寫的 MCP addon **能載入並執行**在 C# Godot 專案上——但有以下斷層。

---

## 相容性矩陣

| 能力 | GDScript Godot | C# Godot（GDScript MCP） | 問題 |
|------|---------------|--------------------------|------|
| 編輯器/場景/節點操作 | ✅ | ✅ | Godot API 語言無關，正常 |
| 腳本工具（create/validate） | ✅ | ❌ | GDScript 專用，C# 需另外實作 |
| LSP 診斷 | ✅（Godot 內建 LSP） | ❌ | Godot LSP 只認 GDScript |
| Runtime `eval` | ✅（GDScript 直譯） | ❌ | C# 是編譯式，不能 runtime eval |
| Runtime `_mcp_state()` | ✅ | ❌ | GDScript 方法，C# 節點無法定義 |
| 輸入模擬 / 截圖 / 時鐘控制 | ✅ | ✅ | 透過 Godot API，語言無關 |
| DAP breakpoint | ✅ | ✅ | Godot DAP 支援 C# |
| 連線遊戲測試 | ✅ | ✅ | 多實例管理語言無關 |

---

## 斷層與對策

### 1. 腳本工具

**問題**：`godot_script` 的 `create`/`validate` 針對 GDScript。`create` 需要 `extends` 參數（GDScript 專用），`validate` 做 GDScript 語法檢查。C# 是編譯式，需 `dotnet build` 驗證。

> `edit`（diff-based）和 `write`（完整覆寫）是語言無關的文字操作，技術上可用於 C# 檔案。`read`/`attach`/`detach` 也可用於 C# 專案。

**對策**：Open Godot MCP 計畫提供 `godot_csharp_script` 工具（Phase 6），支援：
- C# 檔案讀寫
- Roslyn syntax-first 語法檢查（見 [Syntax-Check.md](Syntax-Check.md)）
- `dotnet build` 編譯驗證

### 2. LSP 診斷

**問題**：Godot 內建 LSP 只認 GDScript。

**對策**：
- C# 診斷改用 Roslyn syntax-first（plugin 內，不需外部 process）
- 詳見 [Syntax-Check.md](Syntax-Check.md)

### 3. Runtime `eval`

**問題**：`godot_exec eval` 在遊戲進程內執行 GDScript。C# 是編譯式，不能 runtime eval。

**對策**：
- C# 專案改用 `godot_exec call`（呼叫已編譯的方法）——這仍可用
- 測試場景設定改用：遊戲內暴露的 C# 方法（如 `GameState.SetWave(3)`）
- 或用 `godot_node_edit set_property` 直接修改屬性

### 4. `_mcp_state()` 協議

**問題**：`_mcp_state()` 是 GDScript 方法。C# 節點無法定義。

**對策**（三選一）：

**方案 A：C# 屬性標記**
```csharp
// 在 C# 節點上
[McpWatch]
public Dictionary McpState => new()
{
    { "health", Health },
    { "velocity", Velocity },
    { "anim_state", GetNode<AnimationPlayer>("AnimationPlayer").CurrentAnimation }
};
```
Open Godot MCP 的 C# addon 透過反射掃描 `[McpWatch]` 屬性。

**方案 B：GDScript wrapper autoload**
在 C# 專案內安裝一個 GDScript autoload，透過 `Node.Call("_mcp_state")` 呼叫 C# 節點的方法（如果 C# 節點有定義 `public Variant _McpState()`）。

**方案 C：直接屬性觀察**
不用 `_mcp_state()`，直接用 `godot_runtime_state inspect` 指定屬性名稱。C# 節點的 public 屬性可被 Godot API 存取。

---

## 現有 C# Godot MCP 專案參考

網路調研發現的 5 個 C# Godot MCP：

| 專案 | 方案 | 參考價值 |
|------|------|----------|
| [LuoxuanLove/godot-dotnet-mcp](https://github.com/LuoxuanLove/godot-dotnet-mcp)（33 stars） | Editor-native，Roslyn syntax-first C# 診斷 | **最關鍵**——證明 Roslyn 可在 plugin 內輕量執行 |
| [Ozymandros/Godot-MCP-Server](https://github.com/Ozymandros/Godot-MCP-Server) | .NET global tool，stdio JSON-RPC，headless CLI | CI/CD 參考 |
| [jongalloway/godot-csharp-dev-mcp](https://github.com/jongalloway/godot-csharp-dev-mcp) | Scaffolding + Roslyn 分析 + MSBuild | 工作流參考 |
| [LeanderM99/GodotMCP](https://github.com/LeanderM99/GodotMCP) | TS server + C# EditorPlugin | 架構參考 |
| [IvanMurzak/Godot-MCP](https://github.com/IvanMurzak/Godot-MCP) | C# addon，雲端 backend | 商業模式參考（不採用） |

> 詳細調研見 [../09-Research/CSharp-MCP-Survey.md](../09-Research/CSharp-MCP-Survey.md)。

---

## Open Godot MCP 的 C# 支援策略

### 短期（Phase 0-5）

GDScript MCP addon 能載入在 C# Godot 上，以下功能正常：
- 編輯器/場景/節點操作
- 輸入模擬 / 截圖 / 時鐘控制
- DAP breakpoint
- 連線遊戲測試
- `godot_exec call`（呼叫已編譯方法）

以下功能不適用（AI 需知道）：
- `godot_script create`（`extends` 參數是 GDScript 專用，C# 需手動建立 .cs 檔）
- `godot_script validate`（用 `dotnet build` 替代）
- `godot_lsp diagnostics`（用 Roslyn 替代，見 [Syntax-Check.md](Syntax-Check.md)）
- `godot_exec eval`（用 `godot_exec call` 替代）

### 長期（Phase 6）

- `godot_csharp_script` 工具（Roslyn 整合）
- `[McpWatch]` C# 屬性標記
- C# 專案自動偵測與模式切換
