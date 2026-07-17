# Scene & Node Tools

> `godot_scene` / `godot_node_read` / `godot_node_edit` — 場景檔案與節點操作。

---

## `godot_scene`（混合）

場景檔案操作（.tscn）。

| Action | 類型 | 參數 | 回傳 | 說明 |
|--------|------|------|------|------|
| `create` | write | `path, root_type, root_name` | `{ok}` | 建立新場景。`path` 是 `res://` 資源路徑（如 `"res://levels/level1.tscn"`，需含 `.tscn` 副檔名）；`root_type` 是根節點的 Godot 類別名稱（同 `godot_node_edit create` 的 `type`，如 `"Node2D"`、`"CharacterBody2D"`，見下方 §`type`/`root_type` 參數）；`root_name` 是根節點的名稱（字串，如 `"Level1"`、`"Player"`） |
| `read` | read | `path, include_properties?` | `{root, nodes, signals}` | 讀取場景結構（支援摘要模式）。`root` 是根節點資訊 `{name, type, path}`；`nodes` 是節點陣列，每個元素為 `{name, type, path, properties?}`（`path` 是節點路徑如 `"/root/Level/Player"`）；`signals` 是場景內的信號連接清單，每個元素為 `{signal, source_path, target_path, method}`——`signal` 是信號名稱（字串，如 `"pressed"`），`source_path`/`target_path` 是節點路徑，`method` 是目標節點上的回呼方法名稱（字串）。不指定 `include_properties` 時，`nodes` 只回傳結構資訊（name、type、path），不回傳屬性；指定 `include_properties: true` 時回傳所有節點的完整屬性 |
| `save` | write | `path?` | `{ok}` | 儲存。`path` 是 `res://` 資源路徑（如 `"res://levels/level1.tscn"`）；不指定時儲存當前編輯器中已載入的場景到其原始路徑 |
| `save_as` | write | `path` | `{ok}` | 另存。`path` 是 `res://` 資源路徑（如 `"res://levels/level2.tscn"`，需含 `.tscn` 副檔名），場景會以新路徑儲存，後續 `save` 預設使用此新路徑 |
| `hierarchy` | read | `path, depth?` | `{tree}` | 場景階層（可限深度）。`tree` 是巢狀結構，根節點為 `{name, type, children: [...]}`，每個子節點同樣為 `{name, type, children: [...]}`，`children` 遞迴嵌套到 `depth` 指定的層級。`depth` 是**從根節點開始的展開層數**：`depth=0` 只回傳根節點（無 children）；`depth=1` 回傳根 + 其直接子節點（children 為空陣列）；`depth=2` 回傳根 + 子節點 + 孫節點；不指定 `depth` 時回傳全部層級。注意：`hierarchy` 的元素結構比 `godot_node_read tree` 精簡——不含 `path`/`children_count` 欄位 |
| `instantiate` | write | `child_scene_path, parent_path, name` | `{ok}` | 實例化子場景。`child_scene_path` 是 `res://` 資源路徑（如 `"res://enemy.tscn"`）；`parent_path` 是節點路徑（如 `"/root/Level/Enemies"`，目標父節點需在當前編輯器中已載入的場景內）；`name` 是實例化後的節點名稱 |

> **`godot_scene hierarchy` vs `godot_node_read tree`**：兩者都回傳場景階層，但 `godot_scene hierarchy` 讀取**場景檔案**（.tscn，不需場景已載入編輯器），`godot_node_read tree` 讀取**編輯器中已載入的場景節點樹**（需場景已開啟）。檢查未開啟的場景結構用 `godot_scene`，檢查當前編輯中的場景用 `godot_node_read`。

> **`godot_scene read` vs `godot_scene hierarchy`**：`read` 回傳完整結構（root + nodes + signals），`hierarchy` 只回傳階層樹（更輕量）。只需看結構用 `hierarchy`，需要 signals 或節點詳情用 `read`。

---

## `godot_node_read`（唯讀，可 auto-allow）

| Action | 參數 | 回傳 | 說明 |
|--------|------|------|------|
| `inspect` | `node_path, properties?` | `{type, name, properties: {}}` | 節點詳情。`properties` 是字典——key 是屬性名稱，value 用 [Index.md](Index.md) §Godot 型別的 JSON 編碼 格式（如 `{"position": {"x": 100, "y": 200}, "modulate": {"r": 1, "g": 0, "b": 0, "a": 1}}`）。`properties` 參數是屬性名稱陣列（如 `["position", "modulate"]`），只回傳指定屬性；不指定時回傳常用屬性集（Node2D/Node3D 回傳 `position`/`rotation`/`scale`/`visible`/`name`，Control 回傳 `position`/`size`/`visible`/`theme`，CanvasItem 回傳 `visible`/`modulate`/`z_index` 等——具體集依節點類別而定，需完整屬性時用 `properties` action） |
| `tree` | `root_path?, depth?, offset?, limit?` | `{root, children: [...], total, has_more}` | 場景樹（分頁，可限深度）。`root_path` 是要遍歷的根節點路徑（節點路徑如 `"/root/Level"`），不指定時使用當前場景的 root（即 `"/root"`）。`root` 是根節點資訊 `{name, type, path}`（同 `children` 元素但無 `children` 欄位）；`children` 是**巢狀陣列**——每個元素為 `{name, type, path, children_count, children: [...]}`，`children` 遞迴嵌套到 `depth` 指定的層級。`depth` 語意同 `godot_scene hierarchy`（`depth=0` 只回傳 root，`depth=1` root + 直接子節點，不指定時全部層級）。`children_count` 是該節點的子節點總數（含未展開的深層），`children` 是實際展開的子節點陣列。`total` 是本次回傳的節點總數（整數，含所有展開層級）。`limit` 預設 500 節點（背壓控制，見 [../01-Architecture/Connection-Stability.md](../01-Architecture/Connection-Stability.md) §封包與背壓控制），超過時 `has_more: true`（布林值，表示還有更多節點可用 `offset` 翻頁） |
| `find` | `name?/type?/group?/path_glob?` | `{nodes: [{path, type, name}]}` | 搜尋節點（多參數為 AND——所有指定條件都需匹配）。`name` 是精確節點名稱；`type` 是 Godot 類別名稱；`group` 是群組名稱；`path_glob` 是節點路徑 glob 模式（如 `"/root/Level/*"` 或 `"/root/**/Enemy*"`，`*` 匹配單層、`**` 匹配多層）。全部參數都不指定時回傳當前場景的所有節點（可能受 `limit` 限制） |
| `children` | `node_path, recursive?` | `{children: [{name, type, path}]}` | 子節點。每個元素為 `{name, type, path}`（`path` 是節點路徑）。`recursive` 預設 `false`（只回傳直接子節點，即 `children` 為一層平面陣列），`true` 時回傳所有後代（仍為平面陣列，非巢狀——需巢狀結構用 `tree` action） |
| `properties` | `node_path` | `{properties: {}}` | 完整屬性清單。`properties` 是字典——key 是屬性名稱，value 用 [Index.md](Index.md) §Godot 型別的 JSON 編碼 格式（同 `inspect` 的 `properties` 結構，但回傳所有屬性而非子集） |

---

## `godot_node_edit`（寫入，gated）

全部支援 Undo/Redo。

| Action | 類型 | 參數 | 回傳 | 說明 |
|--------|------|------|------|------|
| `create` | write | `type, name, parent_path, properties?` | `{ok, node_path}` | 建立節點。回傳的 `node_path` 是新節點的完整節點路徑（如 `"/root/Level/Player"`），可用於後續操作 |
| `delete` | write | `node_path` | `{ok}` | 刪除節點 |
| `reparent` | write | `node_path, new_parent, index?` | `{ok}` | 重新父節點。`index` 是在新父節點下的插入位置（整數，0-based），不指定時加到末尾 |
| `rename` | write | `node_path, new_name` | `{ok}` | 重新命名 |
| `duplicate` | write | `node_path, new_name?` | `{ok, node_path}` | 複製。回傳的 `node_path` 是複製後新節點的完整節點路徑 |
| `set_property` | write | `node_path, property, value` | `{ok}` | 設定屬性 |
| `set_properties` | write | `node_path, properties: {}` | `{ok}` | 批次設定屬性 |
| `set_groups` | write | `node_path, groups: [str]` | `{ok}` | 設定群組 |

> **`type`/`root_type` 參數**：Godot 節點類別名稱（字串），如 `"Node"`、`"Node2D"`、`"CharacterBody2D"`、`"Sprite2D"`、`"Camera2D"`、`"CanvasLayer"`、`"AnimationPlayer"`。對應 Godot 的 `ClassDB.get_class_list()`。不要加 `.gd` 副檔名或路徑。

> **`properties` 參數**：屬性字典，key 是屬性名稱（如 `"position"`、`"modulate"`），value 用 [Index.md](Index.md) §Godot 型別的 JSON 編碼 格式。如 `{"position": {"x": 100, "y": 200}, "modulate": {"r": 1, "g": 0, "b": 0, "a": 1}}`。

> **`value` 參數**（`set_property`）：單一屬性值，同樣用 [Index.md](Index.md) §Godot 型別的 JSON 編碼 格式。
