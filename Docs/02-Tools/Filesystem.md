# Filesystem, Docs & Log Tools

> `godot_filesystem` / `godot_docs` / `godot_log` — 檔案操作、Godot 文件、日誌。

---

## `godot_filesystem`（混合）

| Action | 類型 | 參數 | 回傳 | 說明 |
|--------|------|------|------|------|
| `list` | read | `path, include_hidden?` | `{entries: [{name, type, size?}]}` | 列出目錄。`path` 是檔案系統路徑或 `res://` 路徑。每個元素為 `{name, type, size?}`——`name` 是檔名/目錄名；`type` 是 `"file"` 或 `"dir"`；`size`（僅 file）是檔案大小（位元組）。`include_hidden` 預設 `false`（不回傳隱藏檔案/目錄，如 `.git/`、`.godot/`），`true` 時包含 |
| `read` | read | `path, start_line?, end_line?, max_bytes?` | `{content, total_lines}` | 讀取檔案（**僅支援文字檔案**）。`content` 是檔案文字內容（字串）；`total_lines` 是檔案總行數（整數）。`start_line`/`end_line` 均為 **1-based**（從 1 開始計數），指定時只回傳該行範圍。`max_bytes` 不指定時無上限（回傳完整內容）；指定時截斷超出部分，回傳的 `content` 可能不完整。同時指定行範圍和 `max_bytes` 時，先套用行範圍再套用位元組上限。**二進位檔案**（.png/.jpg/.bin/.import/.mesh 等）不支援 `read`——工具回傳 `UNSUPPORTED_FILE_TYPE` 錯誤；二進位資源的元資訊用 `godot_resource info`，圖片尺寸用 `godot_asset info` |
| `search` | read | `query, glob?, max_results?` | `{matches: [{path, line, line_number, match_text}]}` | 全文搜尋。每個元素為 `{path, line, line_number, match_text}`——`path` 是檔案路徑；`line_number` 是 1-based 行號；`line` 是該行完整內容；`match_text` 是匹配到的文字片段。`glob` 是檔名過濾模式如 `"*.gd"` 或 `"*.tscn"`（不指定時搜尋所有檔案）；`max_results` 預設 `50`；`query` 是 **Python `re` 模組**正則表達式（語法見 [Python re docs](https://docs.python.org/3/library/re.html)），如 `"func\\s+test_"` 或 `"health\\s*<\\s*\\d+"` |
| `create` | write | `path, content` | `{ok}` | 建立檔案 |
| `delete` | write | `path, confirm?` | `{ok}` | 刪除（含安全檢查）。`confirm: true` 表示 AI 確認刪除；不指定或 `false` 時，工具對**危險路徑**回傳 `PERMISSION_DENIED` 錯誤要求確認。危險路徑定義：`res://` 根目錄、`res://addons/` 目錄、`project.godot` 檔案、任何含 `addons/` 的路徑。一般腳本/資源路徑（如 `res://scripts/old.gd`）不需 `confirm` |
| `rename` | write | `old_path, new_path` | `{ok}` | 重新命名 |

---

## `godot_docs`（唯讀，可 auto-allow）

版本對應的 Godot 官方文件。

| Action | 參數 | 回傳 | 說明 |
|--------|------|------|------|
| `fetch` | `class_name, method?` | `{markdown, url}` | 取得文件（markdown）。`markdown` 是 Godot 官方文件的 markdown 文字（字串）；`url` 是對應的線上文件 URL。`class_name` 是 Godot 類別名稱（如 `"CharacterBody2D"`、`"Input"`）；`method`（可選）是方法名稱，指定時只回傳該方法的文件 |
| `search` | `query` | `{results: [{title, url, snippet}]}` | 搜尋文件。每個元素為 `{title, url, snippet}`——`title` 是頁面標題；`url` 是線上文件 URL；`snippet` 是匹配片段的摘要文字 |

> 文件版本對應當前編輯器版本，避免 AI 引用過時 API。

---

## `godot_log`（混合）

`get` / `errors` 為唯讀（可 auto-allow），`clear` 為寫入（gated）。

| Action | 類型 | 參數 | 回傳 | 說明 |
|--------|------|------|------|------|
| `get` | read | `source? (editor/game/plugin/all), count?, offset?, since_ms?` | `{entries: [{time, level, source, message}]}` | 讀取日誌。每個 entry 為 `{time, level, source, message}`——`time` 是時間戳（ISO 8601 字串，如 `"2025-01-15T10:30:45.123Z"`）；`level` 是 `"error"`/`"warning"`/`"info"`/`"debug"`；`source` 是 `"editor"`/`"game"`/`"plugin"`；`message` 是日誌內容。`source` 不指定時預設 `"all"`。`count` 不指定時回傳最近 100 條。`offset` 是跳過前 N 條（用於翻頁，整數）。`since_ms` 是只回傳最近 N 毫秒的條目（相對於當前時間）。同時指定 `since_ms` 和 `offset`/`count` 時，先依時間過濾再套用 offset/count |
| `errors` | read | `max?, include_warnings?` | `{errors: [{time, level, source, message}]}` | 錯誤。結構同 `get` 的 `entries`，但只包含 `level` 為 `"error"`（或 `include_warnings: true` 時含 `"warning"`）的條目。`max` 不指定時回傳最近 50 條；`include_warnings` 預設 `false`，`true` 時包含警告 |
| `clear` | write | — | `{ok}` | 清除 |
