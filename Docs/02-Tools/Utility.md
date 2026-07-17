# Utility Tools

> `godot_batch` / `godot_asset` / `godot_export` / `godot_health` — 批次、資產、匯出、健康檢查。

---

## `godot_batch`（寫入，gated）

批次執行多個工具呼叫——減少 round-trip。

| Action | 參數 | 回傳 | 說明 |
|--------|------|------|------|
| `execute` | `operations: [{tool, action, params}]` | `{results: [{ok, ...}]}` | 批次執行。`results` 陣列中每個元素對應一個操作（順序與 `operations` 相同），成功為 `{ok: true, ...該工具的回傳值}`，失敗為 `{ok: false, error: {code, message}}`。`params` 是該 tool+action 的參數字典，格式與直接呼叫該工具完全相同（如 `{node_path: "/root/Player", property: "position", value: {x: 100, y: 200}}`） |

> **用途**：建立 10 個節點不需 10 次 round-trip，一次批次完成。省 token、省時間。

> **確認機制**：`godot_batch` 整體視為 write（gated），AI Client 只需確認一次批次呼叫，不對每個子操作個別確認。批次內可混合 read 和 write 操作——read 操作在批次內不需額外確認。這是 `godot_batch` 的設計取捨：批次是原子單位，一次確認涵蓋全部。

> **錯誤處理**：批次內某個操作失敗時，**不停止後續操作**——所有操作都會嘗試執行。`results` 陣列中每個元素對應一個操作，成功為 `{ok: true, ...回傳值}`，失敗為 `{ok: false, error: {code, message}}`。AI 應檢查每個 result 的 `ok` 欄位。批次不是 atomic rollback——已執行的操作不會因為後續失敗而回滾。

> **不允許巢狀**：`operations` 內的 `tool` 不能是 `godot_batch`——不支援批次內批次。需要多層批次時，AI 應依序呼叫多個 `godot_batch execute`。

---

## `godot_asset`（混合）

資產生成與管理。

| Action | 類型 | 參數 | 回傳 | 說明 |
|--------|------|------|------|------|
| `generate_2d` | write | `svg, filename, save_path, width?, height?` | `{ok, path}` | SVG → PNG。`svg` 是 SVG 字串內容（不是檔案路徑），如 `"<svg>...</svg>"`。`filename` 是輸出檔名（如 `"enemy.png"`，不含目錄路徑）。`save_path` 是 `res://` 資源目錄路徑（如 `"res://assets/enemies/"`）。回傳的 `path` 是完整 `res://` 路徑（如 `"res://assets/enemies/enemy.png"`）。`width`/`height` 為輸出 PNG 尺寸（像素），不指定則用 SVG 內的 viewBox |
| `list` | read | `dir, type?` | `{assets: [{path, type, name}]}` | 列出資產。`dir` 是 `res://` 目錄路徑；每個元素為 `{path, type, name}`——`path` 是 `res://` 資源路徑，`type` 是資源類別名稱，`name` 是檔名。`type` 可選過濾特定資源類別（同 `godot_resource list` 的 `type_filter`，是 Godot 資源類別名稱字串，如 `"Texture2D"`、`"AudioStream"`、`"Font"`，不指定時回傳所有類型） |
| `info` | read | `path` | `{type, size, dimensions?}` | 資產資訊。`type` 是資源類別名稱；`size` 是檔案大小（位元組）；`dimensions`（僅圖片/紋理資源）是 `{width, height}` 像素尺寸 |
| `import` | write | `source_path, dest_path, preset?` | `{ok}` | 匯入資產。`source_path` 是來源檔案的檔案系統路徑（如 `"/home/user/textures/enemy.png"` 或 `"C:/Users/textures/enemy.png"`），`dest_path` 是匯入到專案內的 `res://` 資源路徑（如 `"res://assets/enemy.png"`）。`preset` 是匯入預設名稱（可選） |

---

## `godot_export`（混合）

遊戲匯出。

| Action | 類型 | 參數 | 回傳 | 說明 |
|--------|------|------|------|------|
| `presets` | read | — | `{presets: [{name, platform, path?}]}` | 列出匯出預設。每個元素為 `{name, platform, path?}`——`name` 是預設名稱（用於 `export` 的 `preset` 參數）；`platform` 是目標平台（如 `"windows"`、`"linux"`、`"web"`）；`path`（可選）是上次匯出的輸出路徑 |
| `export` | write | `preset, dest_path` | `{ok, path, size}` | 匯出。`preset` 是匯出預設名稱（字串，來自 `presets` action 回傳的清單），`dest_path` 是輸出檔案的檔案系統路徑。**副檔名需由 AI 依平台指定**：Windows = `.exe`，Linux = 無副檔名或 `.x86_64`，macOS = `.zip`（或不含副檔名，Godot 會建立 `.app` 目錄），Web = `.zip`。回傳的 `path` 是實際輸出檔案的檔案系統絕對路徑；`size` 是輸出檔案大小（位元組，整數） |
| `add_preset` | write | `name, platform, settings` | `{ok}` | 新增預設。`platform` 如 `"windows"`、`"linux"`、`"macos"`、`"android"`、`"web"`；`settings` 是匯出設定字典，如 `{"binary_format": true, "export_debug": false, "include_filter": "*.gd,*.tscn"}`（對應 Godot ExportPreset 的 properties） |

> 匯出時自動 strip runtime autoload（不會把 MCP runtime 包進發布版）。

---

## `godot_health`（唯讀，可 auto-allow）

連線健康檢查。

| Action | 參數 | 回傳 | 說明 |
|--------|------|------|------|
| `check` | — | `{bridge_connected, runtime_connected, server_version, addon_version, latency_ms}` | 健康檢查。`bridge_connected`/`runtime_connected` 是布林值；`server_version`/`addon_version` 是版本字串（如 `"0.1.0"`）；`latency_ms` 是 MCP Server ↔ Editor Bridge 的通訊延遲（毫秒，浮點數） |
| `diagnostics` | — | `{port, conflicts, warnings: [str]}` | 連線診斷。`port` 是當前使用的 bridge port（整數）；`conflicts` 是衝突 port 清單（陣列，每個元素為衝突的 port 號或範圍字串，如 `"6006-6015"`）；`warnings` 是警告訊息字串陣列 |
