# Diagnostics Tools

> `godot_debugger` / `godot_lsp` / `godot_profiler` — 除錯、程式碼智慧、效能分析。

> **C# Godot**：`godot_lsp` 只認 GDScript。C# 診斷見 [../08-CSharp-Support/Syntax-Check.md](../08-CSharp-Support/Syntax-Check.md)。

---

## `godot_debugger`（混合）

DAP 整合。借鏡 [rosskarchner/godot-mcp](https://github.com/rosskarchner/godot-mcp)。

| Action | 類型 | 參數 | 回傳 | 說明 |
|--------|------|------|------|------|
| `set_breakpoint` | write | `script_path, line, condition?` | `{ok}` | 設定中斷點。`script_path` 是 `res://` 路徑如 `"res://player.gd"`；`line` 是行號（整數，從 1 開始）；`condition` 是 GDScript 布爾表達式（可選），如 `"health < 10"` 或 `"velocity.length() > 500"`，僅當表達式為 `true` 時暫停 |
| `remove_breakpoint` | write | `script_path, line` | `{ok}` | 移除中斷點 |
| `resume` | write | — | `{ok}` | 繼續執行 |
| `step_over` | write | — | `{ok}` | 單步過 |
| `step_into` | write | — | `{ok}` | 單步進 |
| `stack_trace` | read | — | `{frames: [{id, function, script_path, line, column}]}` | 堆疊追蹤。每個 frame 為 `{id, function, script_path, line, column}`——`id` 是 frame 索引（0 = 最內層，用於 `variables` 的 `frame_id` 參數）；`function` 是函式名稱；`script_path` 是 `res://` 腳本路徑；`line`/`column` 是 1-based 行列號 |
| `variables` | read | `frame_id?, scope?` | `{variables: {}}` | 變數檢查。`variables` 是字典——key 是變數名稱，value 用 [Index.md](Index.md) §Godot 型別的 JSON 編碼 格式（如 `{"health": 80, "velocity": {"x": 100, "y": 0}, "target": "/root/Enemy"}`）。`scope` 可選 `"local"`（當前函式局部變數）、`"members"`（當前物件成員）、`"global"`；不指定時回傳 `"local"`。`frame_id` 是 `stack_trace` 回傳的 frame 索引（整數，0 = 最內層），不指定時用最內層 frame（等同 `frame_id: 0`） |
| `sessions` | read | — | `{sessions: [{paused, breakpoint?}]}` | 偵錯 session 狀態（含 pause 偵測）。每個元素為 `{paused, breakpoint?}`——`paused` 是布林值（是否暫停在中斷點）；`breakpoint`（僅 `paused: true` 時出現）是觸發暫停的中斷點資訊 `{script_path, line, condition?}`——`script_path` 是 `res://` 腳本路徑，`line` 是 1-based 行號，`condition`（可選）是中斷條件表達式 |

> **`condition` 的求值上下文**：與 `godot_exec eval` 和 `godot_game_time step_until` 不同——breakpoint `condition` 在**中斷點觸發時的本地 scope** 內求值（即該行正在執行的函式內），可存取該函式的局部變數和 `self`（當前物件成員）。**不是**在 SceneTree root 上下文求值。例如在 `_physics_process(delta)` 內設 breakpoint 條件 `"velocity.length() > 500"`，`velocity` 是該函式可存取的成員/局部變數。

> **自動連線**：遊戲 pause 在中斷點或 `assert(false)` 時，`godot_debugger sessions` 報告 pause 狀態，AI 可直接 inspect 變數，無需事先設定。

---

## `godot_lsp`（唯讀，可 auto-allow）

LSP 整合。`path` 是 `res://` 資源路徑（如 `"res://player.gd"`）。

| Action | 參數 | 回傳 | 說明 |
|--------|------|------|------|
| `diagnostics` | `path?` | `{diagnostics: [{line, column, severity, code, message}]}` | 語法診斷。每個元素為 `{line, column, severity, code, message}`——`line`/`column` 是 1-based；`severity` 是 `"error"`/`"warning"`/`"info"`；`code` 是診斷規則代碼（如 `"GD1001"`）；`message` 是人類可讀描述。不指定 `path` 時診斷所有已開啟的腳本 |
| `complete` | `path, line, column` | `{completions: [{label, kind, detail?}]}` | 自動完成。每個元素為 `{label, kind, detail?}`——`label` 是候選項文字；`kind` 是 `"function"`/`"variable"`/`"class"`/`"keyword"`/`"property"` 等；`detail`（可選）是類型簽名。`line`/`column` 均為 **1-based**（從 1 開始計數） |
| `definition` | `path, line, column` | `{location: {path, line, column}}` | 跳到定義。`location` 是 `{path, line, column}`——`path` 是 `res://` 腳本路徑，`line`/`column` 是 1-based。找不到時 `location` 為 `null` |
| `hover` | `path, line, column` | `{hover: {content, kind?}}` | hover 資訊。`hover` 是 `{content, kind?}`——`content` 是 markdown 文字；`kind`（可選）是 `"markdown"`/`"plaintext"`。無 hover 資訊時 `hover` 為 `null` |
| `symbols` | `path` | `{symbols: [{name, kind, line, detail?}]}` | 文件符號清單。每個元素為 `{name, kind, line, detail?}`——`name` 是符號名稱；`kind` 是 `"function"`/`"variable"`/`"class"`/`"signal"` 等；`line` 是 1-based 行號；`detail`（可選）是類型簽名 |

> **靜態檢查優先**：能用 LSP 診斷的就不啟動遊戲，省時間。

---

## `godot_profiler`（唯讀，可 auto-allow）

效能監控與分析。

| Action | 參數 | 回傳 | 說明 |
|--------|------|------|------|
| `snapshot` | — | `{fps, process_time, physics_time, memory, draw_calls, object_count}` | 當前效能快照。`fps` 是浮點數（每秒幀數）；`process_time`/`physics_time` 是浮點數（毫秒/幀）；`memory` 是整數（位元組）；`draw_calls`/`object_count` 是整數 |
| `series` | `duration_ms, metrics?` | `{frames: [{frame, fps?, process_time?, physics_time?, memory?, draw_calls?, object_count?}]}` | 時序資料（含 spike 偵測）。`frames` 每個元素為 `{frame, ...metrics}`——`frame` 是幀編號（整數）；`metrics` 欄位依 `metrics` 參數決定，未請求的指標不出現。`duration_ms` 不指定時預設 `1000`（採樣 1 秒）。`metrics` 可選 `["fps", "process_time", "physics_time", "memory", "draw_calls", "object_count"]` 的子集；不指定時回傳全部 |
| `spikes` | `threshold_ms?` | `{spikes: [{frame, time_ms, duration_ms}]}` | 幀時間尖峰。每個 spike 為 `{frame, time_ms, duration_ms}`——`frame` 是幀編號；`time_ms` 是該幀的絕對時間戳（毫秒）；`duration_ms` 是該幀的執行耗時（毫秒）。`threshold_ms` 不指定時預設 `33`——只回傳 `duration_ms > 33` 的幀（即耗時超過 33ms 的慢幀，相當於低於 30fps） |
