# Test Tools

> `godot_test` — 內建測試框架，借鏡 godot-ai 的 McpTestSuite。

---

## `godot_test`（混合）

| Action | 類型 | 參數 | 回傳 | 說明 |
|--------|------|------|------|------|
| `list` | read | — | `{suites: [{name, file, test_count}], tests: [{suite, name}]}` | 列出測試。`suites` 每個元素為 `{name, file, test_count}`——`name` 是測試套件名稱（用於 `run` 的 `suite` 參數）；`file` 是 `res://` 腳本路徑；`test_count` 是該套件內的測試數量。`tests` 每個元素為 `{suite, name}`——`suite` 是所屬套件名稱，`name` 是測試函式的完整名稱（**含 `test_` 前綴**，如 `"test_player_takes_damage"`，即 GDScript 函式名，用於 `run` 的 `test_name` 參數和 `exclude`） |
| `run` | write | `suite?, test_name?, exclude?` | `{results: {passed, failed, skipped, details: [{suite, name, status, message?}]}}` | 執行測試。`results` 包含 `passed`/`failed`/`skipped`（整數計數）和 `details` 陣列——每個 detail 為 `{suite, name, status, message?}`，`status` 是 `"passed"`/`"failed"`/`"skipped"`，`message`（僅 failed/skipped）是失敗原因。`suite` 和 `test_name` 是名稱字串，來自 `list` action 回傳的清單（**`test_name` 含 `test_` 前綴**，如 `"test_player_takes_damage"`）。`exclude` 是要排除的測試名稱清單（格式同 `test_name`，含 `test_` 前綴，如 `["test_slow_network", "test_stress"]`）；`suite` 和 `test_name` 都不指定時執行全部 |
| `results` | read | `verbose?` | `{results: {passed, failed, skipped, details: [{suite, name, status, message?}]}}` | 取得結果。結構同 `run` 的回傳。`verbose: true` 時 `details` 包含所有測試（含 passed）；不指定或 `false` 時 `details` 只包含 failed 和 skipped |
| `create` | write | `path, test_name` | `{ok}` | 建立測試骨架。`path` 是 `res://` 資源路徑（如 `"res://tests/test_player.gd"`），測試檔需在 `res://tests/` 目錄下才會被自動發現。`test_name` 是測試函式名稱（字串，**不含 `test_` 前綴**，如 `"player_takes_damage"`），工具會自動生成 `func test_<test_name>()` 方法骨架（即 `func test_player_takes_damage()`）。**注意**：`create` 的 `test_name` 不含 `test_` 前綴，但 `run`/`list`/`exclude` 使用含 `test_` 前綴的完整函式名——這是因為 `create` 是建立時的簡寫，`run`/`list` 是執行時的完整名 |

> 測試從 `res://tests/` 自動發現，繼承 `McpTestSuite`。支援在遊戲進程內執行 runtime 測試。
