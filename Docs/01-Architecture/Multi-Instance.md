# Multi-Instance — 多實例管理

> 多 Godot 實例的啟動、port 隔離、切換。用於連線遊戲測試（見 [../05-Network-Testing/](../05-Network-Testing/)）。本檔獨立於連線穩定（見 [Connection-Stability.md](Connection-Stability.md)）——多實例是擴展層。

---

## 場景

測試 multiplayer 遊戲時，需要同時啟動多個 Godot 實例（host + client）。

---

## 設計

```
MCP Server 管理多個 Godot 實例：

Instance 1 (host)  → Editor Bridge :6970, DAP :6006, LSP :6005, Game :7070
Instance 2 (client)→ Editor Bridge :6980, DAP :6016, LSP :6015, Game :7080
Instance 3 (client)→ Editor Bridge :6990, DAP :6026, LSP :6025, Game :7090
```

- 每個實例獨立 port 範圍（base + 10n）
- `godot_instance launch_editor` 工具啟動新實例
- `godot_instance list` 查看所有實例
- `godot_instance switch` 切換作用中實例
- 工具呼叫可指定 `instance_id`，不指定則用作用中實例

> **Game port vs Bridge port**：Bridge port（6970+）是 MCP Server ↔ Editor Bridge 的 WebSocket；Game port（7070+）是遊戲本身的 multiplayer port（ENet/WebSocket peer 連線用）。兩者是完全不同的服務，不應共用 port 號。

---

## Port 隔離

```
每個實例分配：
  - Editor Bridge port（6970 + 10n）— MCP 通訊
  - DAP port（6006 + 10n）— 除錯
  - LSP port（6005 + 10n）— 語言伺服器
  - Game multiplayer port（7070 + 10n）— 遊戲連線（僅 network 測試時）
```

> Runtime 透過 debugger channel 溝通，不需額外 port（見 [Transport.md](Transport.md) §通道 3）。

自動偵測 port 衝突，衝突時往後遞增直到找到可用 port。

---

## 相關文件

- [Connection-Stability.md](Connection-Stability.md) — 單實例連線穩定
- [../05-Network-Testing/Guide.md](../05-Network-Testing/Guide.md) — 連線遊戲測試工作流
- [../02-Tools/Instance.md](../02-Tools/Instance.md) — 實例管理工具 API
