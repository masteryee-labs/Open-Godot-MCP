# Game Control Tools

> `godot_game` / `godot_game_time` — 遊戲啟動/停止與確定性時鐘控制。

> 詳細工作流見 [../03-Realtime-Testing/Guide.md](../03-Realtime-Testing/Guide.md)。

---

## `godot_game`（混合）

| Action | 類型 | 參數 | 回傳 | 說明 |
|--------|------|------|------|------|
| `play` | write | `scene?, frozen?` | `{ok, runtime_ready}` | 啟動遊戲（可 frozen）。`runtime_ready` 是布林值（runtime autoload 是否已連線——`true` 時可開始輸入模擬/狀態觀察，`false` 時需稍候再呼叫 `godot_game status` 確認）。`frozen` 預設 `false`（即時模式）；`true` 時以 `Engine.time_scale=0` 啟動（確定性模式） |
| `stop` | write | — | `{ok}` | 停止遊戲 |
| `pause` | write | — | `{ok}` | 暫停（`get_tree().paused = true`） |
| `resume` | write | — | `{ok}` | 恢復（`get_tree().paused = false`） |
| `status` | read | — | `{is_playing, runtime_connected, fps, viewport_size?}` | 執行狀態（`viewport_size` = 實際遊戲視窗像素尺寸 `{width, height}`，僅遊戲執行時回傳） |

> **`scene` 參數**：
> - 不指定 = 用當前編輯器中開啟的場景
> - `"main"` = 用 `project.godot` 設定的主場景
> - `"res://path/to/scene.tscn"` = 用指定路徑的場景

> **`pause` vs `freeze` 的差異**：
> - `godot_game pause` → `get_tree().paused = true`：Godot 的 pause 系統，停止 `_process`/`_physics_process`，但 pause-aware 節點（`process_mode != INHERIT`）仍可運作。適合：暫停選單、切換到編輯器操作。
> - `godot_game_time freeze` → `Engine.time_scale = 0`：完全停止時間推進，所有節點的 `_process`/`_physics_process` 都不執行。適合：確定性 playtesting，AI 精確控制時間。
> - 兩者機制不同，不能互換。`resume` 不會解除 `freeze`，需用 `unfreeze`。

---

## `godot_game_time`（寫入，gated）

確定性時鐘控制——Open Godot MCP 的核心創新。

| Action | 參數 | 回傳 | 說明 |
|--------|------|------|------|
| `freeze` | — | `{ok, frame}` | 凍結遊戲時鐘（`Engine.time_scale = 0`）。`frame` 是當前幀編號（整數，從 0 開始） |
| `unfreeze` | `time_scale?` | `{ok, frame}` | 解除凍結（`Engine.time_scale = 1.0` 或指定值）。`frame` 是當前幀編號 |
| `step` | `ms, inputs?` | `{ok, frame, elapsed}` | 推進遊戲時間（可附輸入）。`frame` 是推進後的幀編號（整數）；`elapsed` 是推進的總時間（浮點數，單位為秒）。`ms` 無硬性上限，但大於 1000 時建議改用 `step_until`（避免單次 step 時間過長導致物理引擎不穩定） |
| `step_until` | `condition, timeout_ms?, interval_ms?` | `{ok, frame, elapsed, condition_met}` | 推進直到條件達成。`frame` 是推進後的幀編號（整數）；`elapsed` 是推進的總時間（浮點數，單位為秒）；`condition_met` 是布林值（條件是否在 timeout 前達成） |

> `condition` 是 GDScript 表達式，在遊戲進程內求值（求值上下文同 `godot_exec eval`，見 [Runtime-State.md](Runtime-State.md) §eval 的求值上下文）。例如 `"tree.get_nodes_in_group('boss').size() >= 1"`

> **預設值**：`timeout_ms` 預設 `10000`（10 秒），`interval_ms` 預設 `16`（約一幀）。`timeout_ms` 到達時返回 `condition_met: false`，不會無限等待。

> **`step` 的 `inputs`**：輸入可包在時間切片內，`at_ms` 指定注入時間（0=切片開始，最大值=`ms` 參數值=切片結束）。如 `step ms=500` 時 `at_ms` 範圍 0-500；`step ms=2000` 時 `at_ms` 範圍 0-2000。

> **`inputs` 結構**：每個元素是 `{type, ...對應參數, at_ms}`，`type` 對應 `godot_input` 的 action 名稱：
> - `{type: "action", action, pressed, strength?, at_ms}` — InputMap action
> - `{type: "key", key, pressed, modifiers?, at_ms}` — 鍵盤按鍵
> - `{type: "mouse_button", button, position, pressed, at_ms}` — 滑鼠按鈕
> - `{type: "mouse_motion", delta, button_mask?, at_ms}` — 滑鼠移動
> - `{type: "joypad", device, control, index, value?, at_ms}` — 手把
> - `{type: "text", text, at_ms}` — 文字輸入

> **多實例**：所有工具可選 `instance_id` 參數指定目標實例，不指定則用作用中實例。詳見 [../01-Architecture/Multi-Instance.md](../01-Architecture/Multi-Instance.md)。

> **解析度不匹配問題**：Godot 的「設計解析度」（`display/window/size/viewport_width/height`）與遊戲啟動時的「實際視窗尺寸」可能不同——視窗模式、stretch mode、HiDPI 縮放都會造成差異。`godot_game status` 回傳的 `viewport_size` 是**實際視窗像素尺寸**，滑鼠座標以此為準（見 [Input.md](Input.md) §座標系統）。AI 發送滑鼠輸入前應先查 `viewport_size`，不要假設與設計解析度相同。詳見 [../03-Realtime-Testing/Guide.md](../03-Realtime-Testing/Guide.md) §解析度與座標系統。
