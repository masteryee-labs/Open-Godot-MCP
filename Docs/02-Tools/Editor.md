# Editor Tools

> `godot_editor_read` / `godot_editor_edit` — 編輯器狀態與操作。

---

## `godot_editor_read`（唯讀，可 auto-allow）

| Action | 參數 | 回傳 | 說明 |
|--------|------|------|------|
| `state` | — | `{godot_version, current_scene, is_playing, project_path}` | 編輯器狀態。`current_scene` 是 `res://` 資源路徑（如 `"res://level1.tscn"`，無開啟場景時為 `null`）；`project_path` 是檔案系統絕對路徑（如 `"/home/user/my_game"`） |
| `selection` | — | `{nodes: [{path, type, name}]}` | 當前選中節點。`path` 是節點路徑（如 `"/root/Level/Player"`），`type` 是 Godot 類別名稱 |
| `open_scenes` | — | `{scenes: [path]}` | 所有開啟的場景。`scenes` 是 `res://` 資源路徑陣列（如 `["res://level1.tscn", "res://player.tscn"]`） |
| `viewport` | `viewport` (2d/3d) | `{size: {width, height}, transform}` | 視窗資訊。`size` 是 `{width, height}`（像素）；`transform`（2D 時）是 `Transform2D` 結構（見 [Index.md](Index.md) §Godot 型別的 JSON 編碼），3D 時為 `Camera3D` 的 transform（`{position: {x,y,z}, rotation: {x,y,z}, fov}`，`rotation` 單位為**弧度**，與 Godot 的 `Camera3D.rotation` 屬性一致；`fov` 為浮點數，單位度）。`viewport` 可選 `"2d"` 或 `"3d"` |
| `performance` | — | `{fps, memory, draw_calls, object_count}` | 效能監控（輕量快照）。`fps` 是浮點數（每秒幀數）；`memory` 是整數（位元組）；`draw_calls`/`object_count` 是整數 |

> **`godot_editor_read performance` vs `godot_profiler snapshot`**：兩者都回傳效能數據，但 `editor_read performance` 是輕量快照（4 個指標，編輯器隨時可用），`profiler snapshot` 是完整快照（含 `process_time`/`physics_time`，需遊戲執行中）。快速檢查用 `editor_read performance`，深入分析用 `profiler`。

---

## `godot_editor_edit`（寫入，gated）

所有操作支援 Undo/Redo。

| Action | 參數 | 回傳 | 說明 |
|--------|------|------|------|
| `open_scene` | `path` | `{ok}` | 開啟場景。`path` 是 `res://` 資源路徑（如 `"res://levels/level1.tscn"`） |
| `save_scene` | `path?` | `{ok}` | 儲存當前/指定場景。`path` 是 `res://` 資源路徑；不指定時儲存當前編輯中的場景 |
| `save_all` | — | `{ok, saved: [path]}` | 儲存所有場景。回傳的 `saved` 是 `res://` 路徑陣列 |
| `set_selection` | `node_paths: [str]` | `{ok}` | 設定選取。`node_paths` 是節點路徑陣列（如 `["/root/Level/Player", "/root/Level/Camera2D"]`） |
| `focus_node` | `node_path` | `{ok}` | 在視窗中聚焦節點。`node_path` 是節點路徑（如 `"/root/Level/Player"`） |
| `quit` | `save: bool` | `{ok}` | 退出編輯器。`save: true` 時先儲存所有未存場景 |

> **路徑格式混合**：`open_scene`/`save_scene` 用 `res://` 資源路徑（操作場景檔案），`set_selection`/`focus_node` 用節點路徑 `/root/...`（操作場景樹中的節點）。詳見 [Index.md](Index.md) §路徑參數的三種格式。
