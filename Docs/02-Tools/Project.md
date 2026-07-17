# Project Tools

> `godot_project` / `godot_input_map` — 專案設定與輸入映射。

---

## `godot_project`（混合）

| Action | 類型 | 參數 | 回傳 | 說明 |
|--------|------|------|------|------|
| `info` | read | — | `{name, version, godot_version, main_scene}` | 專案資訊。`name` 是專案名稱（字串）；`version` 是專案版本（字串，如 `"1.0.0"`）；`godot_version` 是 Godot 引擎版本（字串，如 `"4.5.0"`）；`main_scene` 是主場景的 `res://` 資源路徑（如 `"res://main.tscn"`，未設定時為 `null`） |
| `get_setting` | read | `key` | `{value}` | 取得設定。`value` 用 [Index.md](Index.md) §Godot 型別的 JSON 編碼 格式（如整數設定回傳 `1920`，Vector2 設定回傳 `{"x": 100, "y": 200}`）。設定不存在時 `value` 為 `null` |
| `set_setting` | write | `key, value` | `{ok}` | 設定設定 |
| `list_settings` | read | `category?` | `{settings: {}}` | 列出設定。`settings` 是字典——key 是設定路徑（如 `"display/window/size/viewport_width"`），value 用 [Index.md](Index.md) §Godot 型別的 JSON 編碼 格式 |
| `autoload_list` | read | — | `{autoloads: [{name, path, enabled}]}` | 列出 autoload。每個元素為 `{name, path, enabled}`——`name` 是 autoload 名稱（如 `"GameState"`）；`path` 是 `res://` 腳本資源路徑；`enabled` 是布林值（是否啟用） |
| `autoload_add` | write | `name, path` | `{ok}` | 新增 autoload。`name` 是 autoload 名稱（如 `"GameState"`），`path` 是 `res://` 腳本資源路徑（如 `"res://game_state.gd"`） |
| `autoload_remove` | write | `name` | `{ok}` | 移除 autoload |
| `rescan` | write | — | `{ok}` | 重新掃描檔案系統 |

> **`key` 參數**（`get_setting`/`set_setting`）：Godot 設定路徑，用 `/` 分隔的 section/key，如 `"display/window/size/viewport_width"`、`"application/run/main_scene"`、`"input/controls/jump"`。對應 `project.godot` 內的 section 結構。`value` 用 [Index.md](Index.md) §Godot 型別的 JSON 編碼 格式。

> **`category` 參數**（`list_settings`）：設定分類前綴，如 `"display"`、`"input"`、`"application"`。不指定時回傳全部設定。

---

## `godot_input_map`（混合）

| Action | 類型 | 參數 | 回傳 | 說明 |
|--------|------|------|------|------|
| `list` | read | `include_builtin?` | `{actions: [{name, deadzone, events: [{event_type, params}]}]}` | 列出輸入動作。每個元素為 `{name, deadzone, events}`——`name` 是動作名稱（如 `"jump"`、`"ui_accept"`）；`deadzone` 是死區數值（0.0-1.0）；`events` 是綁定的事件陣列，每個 event 為 `{event_type, params}`（結構同 `bind` 的參數）。`include_builtin` 預設 `false`（只回傳自訂動作），`true` 時包含 Godot 內建動作（如 `"ui_left"`、`"ui_accept"`） |
| `add` | write | `action, deadzone?` | `{ok}` | 新增動作 |
| `remove` | write | `action` | `{ok}` | 移除動作 |
| `bind` | write | `action, event_type, params` | `{ok}` | 綁定事件 |
| `ensure` | write | `action, event_type, params` | `{ok}` | 確保綁定存在（冪等） |
| `get` | read | `action` | `{events: [{event_type, params}]}` | 取得動作的事件。`events` 每個元素為 `{event_type, params}`（結構同 `bind` 的參數）。動作不存在時回傳 `{events: []}` |

> **`bind`/`ensure` 的 `event_type` 與 `params`**：
> - `event_type`：`"key"` / `"mouse_button"` / `"joypad_button"` / `"joypad_axis"`
> - `params`（依 `event_type` 不同）：
>   - key：`{key: "KEY_SPACE", modifiers?: ["ctrl", "shift", ...]}`
>   - mouse_button：`{button: "MOUSE_BUTTON_LEFT"}`
>   - joypad_button：`{device: 0, button: "JOY_BUTTON_A"}`
>   - joypad_axis：`{device: 0, axis: "JOY_AXIS_LEFT_X", axis_range: 1}`（`axis_range` 是 `-1`/`0`/`1`：`1` = 正方向軸，`-1` = 負方向軸，`0` = 雙向軸全範圍）
