# Tools Index — 工具清單總覽

> ~30 tools，~145 actions。read/write 分離設計。本檔是索引，各領域詳見獨立檔案。

---

## 設計原則

### Read/Write 分離

每個領域的工具有 `_read` 和 `_edit` 兩個版本：

- **`_read` 工具**：唯讀，可在 AI client 設定為 auto-allow（不需每次確認）
- **`_edit` 工具**：寫入，保持 gated（每次需確認）

### Action 收納

相關操作收進同一工具的 `action` 參數。

### 命名規範

```
godot_<domain>_<access>  其中 access = read | edit
godot_<domain>           當工具本身明顯是 read 或 write 時省略 access
```

### 跨領域可選參數

所有工具支援以下可選參數（不指定則用預設/作用中實例）：

| 參數 | 說明 | 詳見 |
|------|------|------|
| `instance_id` | 指定目標 Godot 實例（多實例場景） | [../01-Architecture/Multi-Instance.md](../01-Architecture/Multi-Instance.md) |

### 錯誤回傳格式

所有工具失敗時統一回傳：

```json
{"ok": false, "error": {"code": "NODE_NOT_FOUND", "message": "Node '/root/Foo' not found"}}
```

- `ok: false` 表示操作失敗
- `error.code` 是機器可讀的錯誤碼。常見錯誤碼：

| 錯誤碼 | 含義 | 可能出現於 |
|--------|------|-----------|
| `NODE_NOT_FOUND` | 節點路徑找不到 | `godot_node_read`/`godot_node_edit`/`godot_runtime_state`/`godot_exec call` |
| `SCENE_NOT_LOADED` | 場景未在編輯器中載入 | `godot_node_read`/`godot_editor_edit` |
| `RUNTIME_NOT_CONNECTED` | 遊戲未執行或 runtime 未連線 | `godot_runtime_state`/`godot_exec`/`godot_input`/`godot_game_time`/`godot_screenshot game` |
| `PORT_CONFLICT` | Port 被佔用 | `godot_instance launch_editor`/`godot_network launch_instance` |
| `AMBIGUOUS_MATCH` | `godot_script edit` 的 `old` 在檔案中出現多次 | `godot_script edit` |
| `NOT_FOUND` | `godot_script edit` 的 `old` 在檔案中找不到 | `godot_script edit` |
| `RESOURCE_NOT_FOUND` | `res://` 資源路徑找不到 | `godot_resource`/`godot_script`/`godot_scene` |
| `VALIDATION_ERROR` | 語法驗證失敗 | `godot_script validate`/`godot_lsp diagnostics` |
| `PERMISSION_DENIED` | 安全設定拒絕操作（如 `--no-eval` 時呼叫 `godot_exec eval`） | `godot_exec`/`godot_filesystem delete` |
| `UNSUPPORTED_FILE_TYPE` | 檔案類型不支援（如 `godot_filesystem read` 讀取二進位檔案） | `godot_filesystem read` |
| `BRIDGE_NOT_CONNECTED` | Editor Bridge 未連線 | 任何需要 bridge 的工具 |

> 這不是完整清單——各工具可能有特定錯誤碼。AI 應讀 `error.message` 取得人類可讀描述，不要假設錯誤碼清單是封閉的。
- `error.message` 是人類可讀的錯誤描述

> **AI 應始終檢查 `ok` 欄位**：`ok: true` 才表示成功。不要假設有回傳就代表成功——read 工具可能回傳空結果（如 `find` 找不到節點時 `{nodes: []}`，此時 `ok` 仍為 `true`）。

### Godot 型別的 JSON 編碼

所有工具的參數與回傳值都是 JSON。Godot 的型別（Vector2/3、Color、Rect2、Quaternion 等）在 JSON 中編碼為**物件**，不是字串或陣列：

| Godot 型別 | JSON 編碼 | 範例 |
|-----------|----------|------|
| `Vector2` | `{"x", "y"}` | `{"x": 100, "y": 200}` |
| `Vector3` | `{"x", "y", "z"}` | `{"x": 0, "y": 1, "z": 0}` |
| `Color` | `{"r", "g", "b", "a"}` | `{"r": 1.0, "g": 0.5, "b": 0.0, "a": 1.0}` |
| `Rect2` | `{"x", "y", "width", "height"}` | `{"x": 0, "y": 0, "width": 100, "height": 50}` |
| `Quaternion` | `{"x", "y", "z", "w"}` | `{"x": 0, "y": 0, "z": 0, "w": 1}` |
| `Transform2D` | `{"rotation", "scale", "origin"}` | `{"rotation": 0, "scale": {"x":1,"y":1}, "origin": {"x":0,"y":0}}` |
| `Basis` | `{"x", "y", "z"}`（各為 Vector3） | `{"x": {"x":1,"y":0,"z":0}, ...}` |
| `Array` | JSON 陣列 | `[1, 2, 3]` |
| `Dictionary` | JSON 物件 | `{"key": "value"}` |
| `String` | JSON 字串 | `"hello"` |
| `int`/`float`/`bool` | JSON 原生 | `42` / `3.14` / `true` |
| `NodePath` | 字串 | `"/root/Player"` |

> **AI 不要傳 GDScript 字面值**：不要傳 `"Vector2(100, 200)"`（字串）或 `[100, 200]`（陣列），工具會報錯。所有 Godot 型別都用上表的 JSON 物件格式。

### 路徑參數的三種格式

不同工具的 `path`/`node_path`/`player_path` 參數使用不同的路徑格式。AI 必須用對應的格式，否則工具報錯：

| 格式 | 長相 | 用於 | 範例工具 |
|------|------|------|----------|
| **節點路徑** | `/root/...` | 操作**編輯器中已載入的場景樹**或**執行中遊戲的 live 節點** | `godot_node_read`、`godot_node_edit`、`godot_runtime_state`、`godot_exec call`、`godot_animation`（`player_path`）、`godot_tilemap`（`node_path`）、`godot_scene instantiate`（`parent_path`）、`godot_editor_edit set_selection/focus_node`、`godot_script attach/detach`（`node_path`） |
| **資源路徑** | `res://...` | 操作**專案內的檔案**（場景、腳本、資源） | `godot_scene`（`path`）、`godot_script`（`path`）、`godot_resource`（`path`/`dir`）、`godot_lsp`（`path`）、`godot_debugger`（`script_path`）、`godot_test`（`path`）、`godot_asset`（`save_path`/`dest_path`）、`godot_editor_edit open_scene/save_scene`（`path`）、`godot_project autoload_add`（`path`）、`godot_script attach`（`script_path`） |
| **檔案系統路徑** | 絕對路徑或 `res://` | 操作**任意檔案**（不限專案資源） | `godot_filesystem`（`path`）、`godot_export`（`dest_path`）、`godot_instance launch_editor`（`project_path`）、`godot_asset import`（`source_path`） |

> **AI 最常踩的坑**：把 `res://` 路徑傳給需要節點路徑的工具（如 `godot_node_read inspect node_path="res://player.gd"` → 報錯），或把節點路徑傳給需要 `res://` 的工具（如 `godot_script read path="/root/Player"` → 報錯）。

> **判斷規則**：如果工具操作的是「場景樹中的節點」或「執行中遊戲的節點」，用節點路徑 `/root/...`。如果工具操作的是「檔案」（腳本、場景檔、資源檔），用 `res://...`。

---

## 工具清單

| 工具 | 類型 | 領域檔案 |
|------|------|----------|
| `godot_editor_read` / `godot_editor_edit` | read/write | [Editor.md](Editor.md) |
| `godot_scene` | mixed | [Scene-Node.md](Scene-Node.md) |
| `godot_node_read` / `godot_node_edit` | read/write | [Scene-Node.md](Scene-Node.md) |
| `godot_script` | mixed | [Script.md](Script.md) |
| `godot_project` / `godot_input_map` | mixed | [Project.md](Project.md) |
| `godot_resource` | read | [Resource.md](Resource.md) |
| `godot_animation` | mixed | [Resource.md](Resource.md) |
| `godot_tilemap` | mixed | [Resource.md](Resource.md) |
| `godot_game` | mixed | [Game-Control.md](Game-Control.md) |
| `godot_game_time` | write | [Game-Control.md](Game-Control.md) |
| `godot_input` | write | [Input.md](Input.md) |
| `godot_runtime_state` | read | [Runtime-State.md](Runtime-State.md) |
| `godot_exec` | write | [Runtime-State.md](Runtime-State.md) |
| `godot_screenshot` | read | [Screenshot.md](Screenshot.md) |
| `godot_debugger` | mixed | [Diagnostics.md](Diagnostics.md) |
| `godot_lsp` | read | [Diagnostics.md](Diagnostics.md) |
| `godot_profiler` | read | [Diagnostics.md](Diagnostics.md) |
| `godot_test` | mixed | [Test.md](Test.md) |
| `godot_network` | mixed | [Network.md](Network.md) |
| `godot_instance` | mixed | [Instance.md](Instance.md) |
| `godot_filesystem` | mixed | [Filesystem.md](Filesystem.md) |
| `godot_docs` | read | [Filesystem.md](Filesystem.md) |
| `godot_log` | mixed | [Filesystem.md](Filesystem.md) |
| `godot_batch` | write | [Utility.md](Utility.md) |
| `godot_asset` | mixed | [Utility.md](Utility.md) |
| `godot_export` | mixed | [Utility.md](Utility.md) |
| `godot_health` | read | [Utility.md](Utility.md) |

---

## MCP Resources（唯讀狀態，可 @-mention）

| URI | 說明 |
|-----|------|
| `godot://editor/state` | 編輯器狀態 |
| `godot://editor/scene-tree` | 當前場景樹 |
| `godot://editor/logs` | 最近日誌 |
| `godot://editor/screenshot` | 遊戲畫面截圖（存磁碟，回傳路徑；詳見 [Screenshot.md](Screenshot.md)） |
| `godot://instances` | 運行中實例清單 |
| `godot://project/info` | 專案資訊 |

---

## MCP Prompts（引導式工作流）

| Prompt | 參數 | 說明 |
|--------|------|------|
| `playtest` | `scene?, frozen?` | 完整 playtest 流程 |
| `debug_breakpoint` | `script, line, condition?` | 中斷點除錯流程 |
| `network_test` | `peer_count, scene?` | 連線遊戲測試流程 |
| `build_scene` | `description` | 從描述建構場景 |
| `fix_bug` | `description` | 除錯流程：重現、診斷、修復、驗證 |
