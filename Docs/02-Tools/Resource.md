# Resource Tools

> `godot_resource` / `godot_animation` / `godot_tilemap` — 資源、動畫、TileMap。

---

## `godot_resource`（唯讀，可 auto-allow）

| Action | 參數 | 回傳 | 說明 |
|--------|------|------|------|
| `inspect` | `path` | `{type, properties: {}}` | 資源詳情（型別感知）。`type` 是 Godot 資源類別名稱（如 `"SpriteFrames"`、`"TileSet"`）；`properties` 是字典，結構依 `type` 不同——SpriteFrames 回傳 `{animations: [...], frame_counts: {...}}`，TileSet 回傳 `{tiles: [...]}`，其他資源回傳通用屬性字典（key 為屬性名稱，value 用 [Index.md](Index.md) §Godot 型別的 JSON 編碼 格式） |
| `list` | `dir, type_filter?` | `{resources: [{path, type, name}]}` | 列出資源。`dir` 是 `res://` 目錄路徑；每個元素為 `{path, type, name}`（`path` 是 `res://` 資源路徑，`type` 是資源類別名稱，`name` 是檔名）。`type_filter` 是 Godot 資源類別名稱字串，如 `"SpriteFrames"`、`"TileSet"`、`"Material"`、`"Texture2D"` |
| `find` | `type, glob?` | `{resources: [{path, type, name}]}` | 搜尋資源。`type` 同 `type_filter`；`glob` 是檔名 glob 模式，如 `"*.png"` 或 `"enemy_*"`。回傳結構同 `list` |
| `info` | `path` | `{type, size, imported, path}` | 資源元資訊。`type` 是 Godot 資源類別名稱；`size` 是檔案大小（整數，位元組）；`imported` 是布林值（是否已由 Godot import 系統處理——`true` 表示 `.import` 檔已存在且資源可用）；`path` 是 `res://` 資源路徑 |

> **型別感知輸出**：SpriteFrames 顯示幀清單、TileSet 顯示 tile 清單、Material 顯示參數——而非通用 property dump。

---

## `godot_animation`（混合）

AnimationPlayer 操作。`player_path` 是 AnimationPlayer 節點的**節點路徑**（如 `"/root/Player/AnimationPlayer"`），不是 `res://` 資源路徑。

| Action | 類型 | 參數 | 回傳 | 說明 |
|--------|------|------|------|------|
| `list` | read | `player_path` | `{animations: [str]}` | 列出動畫。`animations` 是動畫名稱字串陣列（如 `["idle", "run", "jump"]`） |
| `get` | read | `player_path, name` | `{tracks, length, loop}` | 動畫詳情。`tracks` 是軌道陣列，每個元素為 `{type, path, keyframes: [...]}`（`type` 同 `add_track` 的 `track_type`，`path` 是屬性路徑，`keyframes` 結構同 `add_track` 的 `keyframes`）；`length` 是動畫總長度（秒，浮點數）；`loop` 是布林值（是否循環播放） |
| `create` | write | `player_path, name, length, loop?` | `{ok}` | 建立動畫。`name` 是動畫名稱（字串）；`length` 是動畫總長度（浮點數，秒）；`loop` 是布林值（是否循環播放，預設 `false`） |
| `add_track` | write | `player_path, anim, track_type, path, keyframes` | `{ok}` | 新增軌道。`anim` 是目標動畫名稱（字串）；`track_type`/`path`/`keyframes` 見下方說明 |
| `delete` | write | `player_path, name` | `{ok}` | 刪除動畫。`name` 是動畫名稱（字串） |
| `play` | write | `player_path, name` | `{ok}` | 播放動畫（**僅編輯器預覽**，不影響執行中遊戲）。`name` 是動畫名稱（字串）。若需在執行中遊戲播放動畫，改用 `godot_exec call` 呼叫 `AnimationPlayer.play("name")` |
| `stop` | write | `player_path` | `{ok}` | 停止播放 |
| `preset` | write | `player_path, anim, preset, target` | `{ok}` | 預設動畫（fade/slide/shake/pulse）。`anim` 是目標動畫名稱（字串）；`preset` 是預設名稱（字串，可選 `"fade"`/`"slide"`/`"shake"`/`"pulse"`）；`target` 是要動畫化的節點路徑，**相對於 AnimationPlayer 的父節點**（如 `"Player/Sprite2D"`，不是 `/root/...` 絕對路徑），preset 會自動建立對應軌道 |

> **各 preset 的動畫行為**：
> - `"fade"` — 動畫 `modulate:a`（alpha 透明度），從 `1.0` → `0.0` → `1.0`（淡出再淡入）。適合場景轉場、物件出現/消失
> - `"slide"` — 動畫 `position`，從當前位置 → 位移 `50px` → 回原位。適合 UI 提示、輕微位移效果
> - `"shake"` — 動畫 `position`，在原位置周圍隨機抖動（振幅 `5px`，持續 `0.3s`）。適合受擊反饋、爆炸衝擊
> - `"pulse"` — 動畫 `scale`，從 `1.0` → `1.2` → `1.0`（放大再縮回）。適合強調效果、按鈕點擊反饋

> **`add_track` 的 `track_type` 與 `keyframes`**：
> - `track_type`：`"value"` / `"transform"` / `"bezier"` / `"method"` / `"audio"` / `"animation"`（對應 Godot Animation.TrackType）
> - `path`：目標節點屬性路徑，**相對於 AnimationPlayer 的父節點**（即 AnimationPlayer 的 `root_node`，預設為 `..`）。格式為 `"NodePath:property_name"`（如 `"Player:position"` 或 `"Sprite2D:modulate"`）。**transform 軌道例外**——`path` 只填節點路徑**不含 `:property`**（如 `"Player"` 或 `"Sprite2D"`），因 transform 軌道動畫整個節點的 position/rotation/scale，不是單一屬性
> - `keyframes` 結構依 `track_type` 不同（**所有 `time` 值均為秒，浮點數，與 `create` 的 `length` 單位一致**）：
>   - **value**：`[{time: 0.0, value: <屬性值>}, {time: 1.0, value: <屬性值>}]`，`value` 用 [Index.md](Index.md) §Godot 型別的 JSON 編碼 格式（如 Vector2 為 `{"x":100,"y":200}`）
>   - **transform**：`[{time: 0.0, position: {x,y}, rotation_deg: 0.0, scale: {x,y}}]`
>   - **bezier**：`[{time: 0.0, value: 0.0, in_handle: {x,y}, out_handle: {x,y}}]`（`in_handle`/`out_handle` 為 Vector2 控制點）
>   - **method**：`[{time: 0.0, method: "method_name", args: [arg1, arg2]}]`（`args` 是參數陣列，元素用 JSON 編碼格式）
>   - **audio**：`[{time: 0.0, stream_path: "res://sound.wav", start_offset: 0.0, end_offset: 0.0}]`
>   - **animation**：`[{time: 0.0, animation: "anim_name"}]`（引用同一 AnimationPlayer 內的其他動畫）

---

## `godot_tilemap`（混合）

TileMapLayer / GridMap 操作（.tscn 內 base64 編碼，只能透過 bridge）。`node_path` 是 TileMapLayer/GridMap 節點的**節點路徑**（如 `"/root/Level/TileMapLayer"`）。

| Action | 類型 | 參數 | 回傳 | 說明 |
|--------|------|------|------|------|
| `read_cells` | read | `node_path, region?` | `{cells: [{coords, source_id, atlas_coords}]}` | 讀取 cells。每個元素為 `{coords: {x, y}, source_id, atlas_coords: {x, y}}`（結構同 `set_cell` 的參數）。`region` 不指定時回傳整個 TileMap 的所有 cells；指定時只回傳 `{x, y, width, height}` 範圍內的 cells（grid 座標） |
| `set_cell` | write | `node_path, coords, source_id, atlas_coords` | `{ok}` | 設定單一 cell。參數結構見下方座標參數說明 |
| `set_cells` | write | `node_path, cells: []` | `{ok}` | 批次設定。`cells` 是陣列，每個元素為 `{coords: {x, y}, source_id, atlas_coords: {x, y}}`（結構同 `set_cell` 的對應參數） |
| `clear` | write | `node_path, region?` | `{ok}` | 清除區域。`region` 不指定時清除整個 TileMap；指定時只清除 `{x, y, width, height}` 範圍內的 cells |

> **座標參數結構**：
> - `coords`：TileMap 格子座標 `{x, y}`（非像素座標，是 grid 座標）
> - `source_id`：TileSet 中 TileSource 的 ID（整數）
> - `atlas_coords`：Atlas 內的 tile 座標 `{x, y}`（格子座標）
> - `region`：`{x, y, width, height}`（grid 座標範圍）
> - `cells`（set_cells）：`[{coords: {x, y}, source_id, atlas_coords: {x, y}}, ...]`
