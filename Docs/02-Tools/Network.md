# Network Tools

> `godot_network` — 連線遊戲測試。**Open Godot MCP 獨有**。

> 詳細工作流見 [../05-Network-Testing/Guide.md](../05-Network-Testing/Guide.md)。

> **與 `godot_instance` 的區別**：`godot_instance` 管理**編輯器實例**（Godot Editor 進程），`godot_network` 管理**遊戲實例**（Play-in-Editor 的遊戲進程，用於連線測試）。兩者都有 `switch`/`list`/`terminate`，但操作的對象不同：`godot_instance` 的 `instance_id` 指向編輯器，`godot_network` 的 `instance_id` 指向遊戲 runtime。多實例架構見 [../01-Architecture/Multi-Instance.md](../01-Architecture/Multi-Instance.md)。

---

## `godot_network`（混合）

| Action | 類型 | 參數 | 回傳 | 說明 |
|--------|------|------|------|------|
| `launch_instance` | write | `role (host/client), scene?, args?` | `{instance_id, game_port}` | 啟動遊戲實例。`instance_id` 是實例 ID 字串（如 `"inst_1"`，用於其他 action 的 `instance_id` 參數）；`game_port` 是遊戲 multiplayer port（整數，非 bridge port） |
| `list_instances` | read | — | `{instances: [{instance_id, role, connected, game_port, player_count?}]}` | 列出實例。每個元素為 `{instance_id, role, connected, game_port, player_count?}`——`instance_id` 是實例 ID（用於其他 action 的 `instance_id` 參數）；`role` 是 `"host"` 或 `"client"`；`connected` 是布林值（是否已連線到 host/有 client 連入）；`game_port` 是遊戲 multiplayer port；`player_count`（僅 host）是已連線玩家數 |
| `switch` | write | `instance_id` | `{ok}` | 切換作用中實例 |
| `terminate` | write | `instance_id` | `{ok}` | 終止實例 |
| `simulate_peer` | write | `instance_id, peer_config` | `{ok}` | 模擬網路 peer |
| `network_condition` | write | `instance_id, latency_ms?, loss_pct?, jitter_ms?` | `{ok}` | 注入網路條件。`latency_ms`/`jitter_ms` 為整數（毫秒）；`loss_pct` 為浮點數（0-100，如 `10.0` = 10% 丟包率） |
| `sync_state` | read | `instances?` | `{all_in_sync, sync: [{instance_id, node_path, properties, in_sync}]}` | 比較多實例同步狀態。`sync` 每個元素為 `{instance_id, node_path, properties, in_sync}`——`instance_id` 是實例 ID；`node_path` 是觀察節點的節點路徑；`properties` 是該節點的狀態字典（來自 `_mcp_state()` 或節點屬性，同 `godot_runtime_state digest` 的 value 結構）；`in_sync` 是布林值（該節點在所有實例間狀態是否一致）。不指定 `instances` 時比較所有已連線的遊戲實例 |
| `rpc_call` | write | `instance_id, node_path, method, args?` | `{result}` | 跨實例 RPC 測試（在指定節點上呼叫 `@rpc` 方法）。`result` 是 RPC 方法的回傳值，用 [Index.md](Index.md) §Godot 型別的 JSON 編碼 格式（無回傳值時為 `null`）。`args` 是 JSON 陣列，元素用 [Index.md](Index.md) §Godot 型別的 JSON 編碼 格式；不指定 `args` 時呼叫無參數方法 |

> **`launch_instance` 的 `args` 參數**（client 角色）：
> - `connect_to`（必填）：host 的 `ip:game_port`，如 `"127.0.0.1:7070"`
> - `reconnect`（可選）：`true` 時啟用重連模式，用於斷線重連測試
>
> **`scene` 參數的行為依角色不同**：
> - **host**：`scene` 指定 host 要載入的場景（如 `"res://arena.tscn"`），host 啟動後會載入該場景並開始接受 client 連線
> - **client**：`scene` 可選——不指定時，client 連線到 host 後由 host 決定要載入的場景（透過遊戲的 multiplayer 同步機制，如 RPC `change_scene`）；指定時，client 啟動後先載入該場景再連線。多數 multiplayer 遊戲的 client 不需指定 `scene`（由 host 主導場景切換），但若遊戲的 client 需要獨立的 UI 場景（如大廳/角色選擇畫面），可指定 `scene`

> **`simulate_peer` 的 `peer_config` 參數**：
> - `peer_id`（必填）：模擬 peer 的 ID（整數）
> - `player_name`（可選）：玩家顯示名稱
> - 其他遊戲自訂欄位（如 `character`、`team` 等）按遊戲需求傳入
>
> `simulate_peer` 在 host 進程內模擬網路 peer，不需啟動完整 Godot 進程。模擬的 peer 會在 host 實例 `terminate` 時自動清除；若需在遊戲執行中移除單一模擬 peer，用 `godot_exec eval` 在 host 上呼叫遊戲的斷線邏輯（如 `get_tree().get_multiplayer().disconnect_peer(peer_id)`）。

> **`sync_state` 的比較邏輯**：比較各實例中 `mcp_watch` 群組節點（或有 `_mcp_state()` 方法的節點）的狀態——與 `godot_runtime_state digest` 使用相同的觀察機制（見 [Runtime-State.md](Runtime-State.md)）。每個 `sync` 項目的 `node_path` + `properties` 來自 `_mcp_state()` 回傳值或節點屬性，`in_sync` 表示該節點在所有實例間的狀態是否一致。
