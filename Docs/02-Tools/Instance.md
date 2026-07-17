# Instance Tools

> `godot_instance` — Godot **編輯器**實例管理。

> 架構見 [../01-Architecture/Multi-Instance.md](../01-Architecture/Multi-Instance.md)。

> **與 `godot_network` 的區別**：本工具管理編輯器進程（Godot Editor），`godot_network` 管理遊戲進程（連線測試用）。詳見 [Network.md](Network.md)。

---

## `godot_instance`（混合）

| Action | 類型 | 參數 | 回傳 | 說明 |
|--------|------|------|------|------|
| `launch_editor` | write | `project_path` | `{instance_id, ports}` | 啟動編輯器實例。`instance_id` 是實例 ID 字串（如 `"inst_1"`，用於 `switch`/`terminate` 的 `instance_id` 參數）；`ports` 是 `{bridge, dap, lsp}` 字典——各通道分配的 port 號（整數）。`project_path` 是 Godot 專案目錄的檔案系統絕對路徑（如 `"/home/user/my_game"`，含 `project.godot` 的目錄） |
| `list` | read | — | `{instances: [{instance_id, project_path, ports, active}]}` | 列出實例。每個元素為 `{instance_id, project_path, ports, active}`——`instance_id` 是實例 ID（用於 `switch`/`terminate` 的 `instance_id` 參數）；`project_path` 是檔案系統專案路徑；`ports` 是 `{bridge, dap, lsp}` 各 port 號的字典；`active` 是布林值（是否為當前作用中實例） |
| `switch` | write | `instance_id` | `{ok}` | 切換作用中 |
| `terminate` | write | `instance_id` | `{ok}` | 終止 |
| `adopt` | write | `project_path` | `{ok, instance_id, ports}` | 連接外部已啟動的 Godot 編輯器（非透過 `launch_editor` 啟動的）。前提：該 Godot 實例已安裝並啟用 Open Godot MCP addon，且其 bridge WebSocket port 可達。`project_path` 同 `launch_editor`，是檔案系統絕對路徑——MCP Server 透過此路徑找到該專案的 EditorSettings 讀取 bridge port，然後連線。回傳結構同 `launch_editor`。適用場景：使用者已手動開啟 Godot，AI 不需重啟即可接管 |
