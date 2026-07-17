# Runtime Autoload — 遊戲進程內設計

> Runtime autoload 的注入機制、能力、`_mcp_state()` 協議、啟動流程。本檔獨立於架構（見 [Architecture.md](Architecture.md)）——runtime 是最內層。

---

## 可選，不污染專案

借鏡 [Erodenn/godot-mcp-runtime](https://github.com/Erodenn/godot-mcp-runtime) 的 zero-footprint 理念：

- **預設**：runtime autoload 由 MCP Server 在啟動遊戲時自動注入到 `project.godot`，遊戲停止時自動移除
- **進階**：使用者可選擇永久安裝 autoload（用於自訂 `_mcp_state()` 方法暴露遊戲狀態）
- **匯出**：匯出遊戲時自動 strip runtime autoload（借鏡 godot-ai 的 `mcp_export_plugin.gd`）

---

## Runtime 能力

| 能力 | 實作方式 |
|------|----------|
| 輸入模擬 | `Input.parse_input_event()` + `Input.action_press/release()` |
| 狀態查詢 | `SceneTree` 遍歷 + 節點屬性序列化 |
| GDScript 注入 | `eval()` 透過 debugger channel |
| 截圖 | `Viewport.get_texture().get_image()` |
| 時鐘控制 | `Engine.time_scale = 0`（freeze）+ 手動 step |

> **C# Godot 注意**：GDScript 注入（`eval`）不適用於 C# 專案——C# 是編譯式，不能 runtime eval。詳見 [../08-CSharp-Support/Compatibility.md](../08-CSharp-Support/Compatibility.md)。

---

## `_mcp_state()` 協議

借鏡 [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp) 的設計——讓遊戲節點自願暴露狀態：

```gdscript
# 在任何節點上
func _mcp_state() -> Dictionary:
    return {
        "health": health,
        "velocity": velocity,
        "anim_state": $AnimationPlayer.current_animation,
    }
```

- 在 `mcp_watch` 群組的節點會被自動觀察
- 有 `_mcp_state()` 方法的節點會回傳自訂狀態
- AI 用 `godot_runtime_state digest` 一次取得所有 watch 節點狀態，無需截圖

> **C# Godot 對等**：C# 節點無法定義 `_mcp_state()` GDScript 方法。替代方案見 [../08-CSharp-Support/Compatibility.md](../08-CSharp-Support/Compatibility.md) §`_mcp_state()` 協議。

---

## 啟動流程

### MCP Server 啟動

```
1. AI Client spawn `python -m open_godot_mcp`
2. Server 初始化 MCP protocol（stdio）
3. Server 註冊所有 tools / resources / prompts
4. Server 等待 AI client 的工具呼叫
```

### Editor Bridge 啟動

```
1. Godot 開啟專案，Plugin._enter_tree()
2. 讀取 port 設定（env > EditorSettings > 預設）
3. 偵測 Windows port reservation，必要時避讓
4. 啟動 WebSocket server
5. 等待 MCP Server 連線
6. 連線後執行 handshake
7. 開始處理 tool_invoke
```

### 遊戲啟動（含 runtime）

```
1. AI 呼叫 godot_game_play
2. Editor Bridge 注入 runtime autoload 到 project.godot（若未永久安裝）
3. Editor 啟動遊戲（F5）
4. Runtime autoload 在遊戲進程內 _ready()
5. Runtime 透過 debugger channel 連回 Editor Bridge
6. Editor Bridge 通知 MCP Server：runtime_ready
7. AI 可開始輸入模擬、狀態觀察、GDScript 注入
```

### 遊戲停止

```
1. AI 呼叫 godot_game_stop（或遊戲自然結束）
2. Editor Bridge 移除臨時注入的 runtime autoload
3. Editor Bridge 通知 MCP Server：runtime_disconnected
```

---

## 相關文件

- [Architecture.md](Architecture.md) — 整體架構
- [Transport.md](Transport.md) — debugger channel 協議
- [../03-Realtime-Testing/Guide.md](../03-Realtime-Testing/Guide.md) — 確定性 playtesting 使用 runtime
