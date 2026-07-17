# Runtime State Tools

> `godot_runtime_state` / `godot_exec` — 遊戲狀態觀察與 GDScript 注入。

> 詳細說明見 [../03-Realtime-Testing/Guide.md](../03-Realtime-Testing/Guide.md)。

---

## `godot_runtime_state`（唯讀，可 auto-allow）

| Action | 參數 | 回傳 | 說明 |
|--------|------|------|------|
| `digest` | `groups? (mcp_watch), include_properties?` | `{nodes: {}, frame}` | 一次取得所有 watch 節點狀態。`nodes` 是字典——**key 是節點路徑**（如 `"/root/Player"`），**value 是該節點的狀態字典**（來自 `_mcp_state()` 或預設屬性集，如 `{"position": {"x": 100, "y": 200}, "health": 80}`）。`frame` 是當前遊戲幀編號（整數，從 0 開始，與 `godot_game_time` 的 `frame` 同源）。`groups` 是群組名稱陣列（如 `["mcp_watch"]` 或 `["mcp_watch", "enemies"]`），不指定時預設 `["mcp_watch"]`。不指定 `include_properties` 時，優先回傳 `_mcp_state()` 的內容；若節點沒有 `_mcp_state()`，回傳預設屬性集（position、visible 等常用屬性）。指定 `include_properties: ["health", "velocity"]` 時，只回傳指定屬性 |
| `inspect` | `node_path, properties?` | `{properties: {}}` | 單一節點詳情（**執行中遊戲的 live 狀態**）。`properties` 是字典——key 是屬性名稱（如 `"position"`、`"health"`），value 用 [Index.md](Index.md) §Godot 型別的 JSON 編碼 格式（如 `{"position": {"x": 100, "y": 200}, "health": 80}`）。`properties` 參數是屬性名稱陣列（如 `["position", "health"]`），只回傳指定屬性；不指定時回傳常用屬性集（同 `godot_node_read inspect` 的預設集，依節點類別而定——見 [Scene-Node.md](Scene-Node.md) §`godot_node_read inspect`） |
| `watch` | `node_path, property, duration_ms?` | `{samples: [{t_ms, value}]}` | 監看屬性時序。`samples` 每個元素為 `{t_ms, value}`——`t_ms` 是相對於監看開始的毫秒數（整數）；`value` 是該時間點的屬性值，用 [Index.md](Index.md) §Godot 型別的 JSON 編碼 格式（如 Vector2 為 `{"x": 100, "y": 200}`）。`duration_ms` 預設 `1000`（1 秒）。**取樣頻率為每幀一次**（即 60fps 時 `duration_ms=1000` 約產生 60 個 sample），`t_ms` 反映每幀的實際時間戳。範例中 `{t_ms: 0, ...}, {t_ms: 500, ...}, ...` 的 `...` 表示省略中間幀，實際回傳包含所有幀的 sample |
| `signals` | `node_path?, since_ms?` | `{signals: [{time_ms, node_path, signal_name, args}]}` | 信號觸發時間線。每個 signal 為 `{time_ms, node_path, signal_name, args}`——`time_ms` 是相對於遊戲啟動的毫秒數（整數）；`node_path` 是發出信號的節點路徑；`signal_name` 是信號名稱（如 `"health_changed"`）；`args` 是信號參數陣列，元素用 [Index.md](Index.md) §Godot 型別的 JSON 編碼 格式。不指定 `node_path` 時回傳所有節點的信號；`since_ms` 是相對於當前時間的毫秒數（如 `since_ms=2000` = 最近 2 秒），不指定時回傳最近 1000ms |

> **`godot_runtime_state inspect` vs `godot_node_read inspect`**：兩者都 inspect 節點，但 `runtime_state inspect` 操作**執行中遊戲**的 live 狀態（runtime 進程內），`node_read inspect` 操作**編輯器場景**的已儲存狀態（editor 進程內）。測試 gameplay 邏輯用 `runtime_state`，編輯場景結構用 `node_read`。

> **cheap observation**：`digest` 回傳 JSON 狀態，多數「畫面上發生什麼」的問題用這個回答，不花 vision token。節點需在 `mcp_watch` 群組或有 `_mcp_state()` 方法。

> **C# Godot**：`_mcp_state()` 是 GDScript 方法，C# 節點無法定義。替代方案見 [../08-CSharp-Support/Compatibility.md](../08-CSharp-Support/Compatibility.md)。

---

## `godot_exec`（寫入，gated）

在執行中的遊戲內執行 GDScript——測試場景設定。

| Action | 參數 | 回傳 | 說明 |
|--------|------|------|------|
| `eval` | `code, await?` | `{result, error?}` | 執行 GDScript（支援 await）。`result` 是最後一個表達式的回傳值，用 [Index.md](Index.md) §Godot 型別的 JSON 編碼 格式（如數值回傳 `80`，Vector2 回傳 `{"x": 100, "y": 200}`，無回傳值時為 `null`）；`error`（僅出錯時）是 `{code, message, line?}`——`code` 是錯誤類型字串，`message` 是錯誤描述，`line`（可選）是出錯行號 |
| `call` | `node_path, method, args?` | `{result}` | 呼叫節點方法。`result` 是方法回傳值，用 [Index.md](Index.md) §Godot 型別的 JSON 編碼 格式（無回傳值時為 `null`）。`args` 是 JSON 陣列，元素用 [Index.md](Index.md) §Godot 型別的 JSON 編碼 格式，如 `[{x: 100, y: 200}, 50]`。不指定 `args` 時呼叫無參數方法 |

> **`eval` 的 `await` 參數**：布爾值，預設 `false`。當 `code` 內含 `await` 關鍵字（如 `await get_tree().create_timer(1.0).timeout`）時需設為 `true`，工具會等待 await 完成後再回傳結果。若 `code` 含 `await` 但未設 `await: true`，回傳的 `result` 可能為 `null`（因為 await 尚未完成）。

> **用途**：grant weapon、skip to wave 3、spawn test bot——不需在遊戲碼內 baked debug hooks。

> **`eval` 的求值上下文**：`code` 在遊戲進程的 SceneTree 上下文內求值，`self` 指向 SceneTree 的 root viewport（即 `get_tree().root`）。可透過 autoload 單例名稱直接存取（如 `Player`、`GameState`，前提是它們是 autoload 或 root 的子節點），也可用 `get_tree()`、`Engine` 等全域 API。範例：`Player.add_to_group('mcp_watch')`（`Player` 是 autoload）、`get_tree().get_nodes_in_group('enemy')`。

> **C# Godot**：`eval` 不適用於 C# 專案（C# 是編譯式）。見 [../08-CSharp-Support/Compatibility.md](../08-CSharp-Support/Compatibility.md)。
