# Transport — 通訊協議

> 4 條通訊通道的協議細節。本檔獨立於連線穩定設計（見 [Connection-Stability.md](Connection-Stability.md)）——協議本身不變，穩定機制是疊加層。

---

## 通道總覽

| # | 通道 | 協議 | 方向 |
|---|------|------|------|
| 1 | AI Client ↔ MCP Server | stdio JSON-RPC | 雙向 |
| 2 | MCP Server ↔ Editor Bridge | WebSocket JSON-RPC | 雙向 |
| 3 | Editor Bridge ↔ Running Game | Godot debugger IPC | 雙向 |
| 4 | MCP Server ↔ Godot DAP / LSP | TCP | 雙向 |

---

## 通道 1：AI Client ↔ MCP Server（stdio）

標準 MCP 協議 over stdio。MCP Server 作為 AI client 的子進程啟動。

```
AI Client 啟動 → spawn `python -m open_godot_mcp` → stdio JSON-RPC
```

- **協議**：MCP標準（[modelcontextprotocol.io](https://modelcontextprotocol.io)）
- **生命週期**：AI Client 關閉時 MCP Server 也終止

---

## 通道 2：MCP Server ↔ Editor Bridge（WebSocket）

```
MCP Server ──WebSocket──► Editor Bridge (ws://127.0.0.1:6970)
```

- **協議**：JSON over WebSocket，JSON-RPC 2.0 風格，帶 `request_id` 關聯
- **方向**：雙向
  - Server → Bridge：`tool_invoke`（要求執行工具）
  - Bridge → Server：`tool_result`（回傳結果）、`event`（如遊戲啟動/停止/崩潰）
- **Handshake**：Bridge 連線時發送 `handshake`（session_id, Godot 版本, project path, plugin 版本, auth_token），Server 回 `handshake_ack`（server_version）
  - `auth_token`：可選的共享金鑰，用於防止未授權的 Bridge 連線。透過 EditorSettings `security/auth_token` 配置（預設空字串=不驗證，僅 localhost 連線時安全）。MCP Server 與 Bridge 需設定相同值才會通過驗證
- **Port**：預設 6970，可配置（見 [Connection-Stability.md](Connection-Stability.md) §可配置 port）

### 訊息格式

```json
// Server → Bridge
{
  "jsonrpc": "2.0",
  "id": "req_123",
  "method": "tool_invoke",
  "params": {"tool": "godot_node_read", "action": "inspect", "node_path": "/root/Player"}
}

// Bridge → Server
{
  "jsonrpc": "2.0",
  "id": "req_123",
  "result": {"type": "CharacterBody2D", "properties": {"position": {"x": 100, "y": 200}}}
}

// Bridge → Server（事件）
{
  "jsonrpc": "2.0",
  "method": "event",
  "params": {"type": "game_started", "runtime_ready": true}
}
```

---

## 通道 3：Editor Bridge ↔ Running Game（debugger channel）

```
Editor Bridge ──debugger wire──► Running Game (autoload)
```

- **協議**：Godot 內建 debugger IPC（EngineDebugger 協議）
- **為什麼不用額外 TCP**：借鏡 [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp) 的設計——遊戲進程不需要額外開 port，透過 Godot 自己的 debugger protocol 溝通，更穩定且不會被防火牆擋
- **能力**：輸入模擬、狀態查詢、GDScript 注入、截圖、時鐘控制（freeze/step）
- **限制**：只在 Play-in-Editor 模式下可用；無法操作 exported game

> **C# Godot 注意**：debugger channel 在 C# Godot 上仍可用，但 `godot_exec eval`（GDScript 注入）不適用於 C# 專案。詳見 [../08-CSharp-Support/Compatibility.md](../08-CSharp-Support/Compatibility.md)。

---

## 通道 4：MCP Server ↔ Godot DAP / LSP（TCP）

```
MCP Server ──TCP──► Godot DAP (port 6006+)
MCP Server ──TCP──► Godot LSP (port 6005+)
```

- **DAP**：Debug Adapter Protocol，用於 breakpoint、step、變數檢查
- **LSP**：Language Server Protocol，用於 autocomplete、go-to-definition、diagnostics
- **Port 管理**：每個 Godot 實例分配獨立 port 範圍，避免衝突（見 [Multi-Instance.md](Multi-Instance.md)）

> **C# Godot 注意**：Godot 內建 LSP 只認 GDScript。C# 專案需用 Roslyn/OmniSharp 做語法診斷。詳見 [../08-CSharp-Support/Syntax-Check.md](../08-CSharp-Support/Syntax-Check.md)。

---

## 相關文件

- [Architecture.md](Architecture.md) — 整體架構
- [Connection-Stability.md](Connection-Stability.md) — 連線穩定設計（疊加在通道 2 上）
- [Multi-Instance.md](Multi-Instance.md) — 多實例 port 隔離
