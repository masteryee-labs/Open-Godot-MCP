# Script Tools

> `godot_script` — GDScript 檔案操作。

> **C# Godot**：本工具的 `validate` 僅適用於 GDScript。C# 專案的語法檢查見 [../08-CSharp-Support/Syntax-Check.md](../08-CSharp-Support/Syntax-Check.md)。

---

## `godot_script`（混合）

| Action | 類型 | 參數 | 回傳 | 說明 |
|--------|------|------|------|------|
| `read` | read | `path, start_line?, end_line?` | `{content, total_lines}` | 讀取（支援行範圍）。`content` 是純文字內容（字串，不含行號前綴）；`total_lines` 是檔案總行數（整數）。`start_line`/`end_line` 均為 **1-based**（從 1 開始計數） |
| `create` | write | `path, extends, content` | `{ok}` | 建立腳本。`extends` 是 GDScript 繼承的 Godot 類別名稱，如 `"Node2D"`、`"CharacterBody2D"`、`"Resource"`、`"RefCounted"` |
| `edit` | write | `path, edits: [{old, new, context?}]` | `{ok, changed_lines: [{start, end}]}` | 差異編輯（diff-based）。`edits` 是編輯陣列，依序套用；每個 edit 的 `old` 是檔案中要替換的精確文字片段，`new` 是替換後的文字，`context`（可選）是字串——`old` 前後的上下文程式碼片段，幫助在 `old` 出現多次時消歧（如 `context` = `old` 前一行 + 後一行的文字）。`changed_lines` 是每個 edit 套用後變更的行範圍陣列，每個元素為 `{start, end}`（1-based 行號） |
| `write` | write | `path, content` | `{ok}` | 完整覆寫 |
| `validate` | read | `path` | `{ok, errors: [{line, column, message}]}` | 語法驗證（headless）。`errors` 每個元素為 `{line, column, message}`——`line`/`column` 是 1-based；`message` 是錯誤描述。`ok: true` 且 `errors` 為空陣列時表示無語法錯誤 |
| `attach` | write | `node_path, script_path` | `{ok}` | 附加到節點。`node_path` 是節點路徑（如 `"/root/Player"`），`script_path` 是 `res://` 資源路徑（如 `"res://player.gd"`） |
| `detach` | write | `node_path` | `{ok}` | 分離腳本 |

> **`edit` 使用 diff-based**：AI 只需提供 `old`（舊程式碼片段）→ `new`（新程式碼片段），不需重寫整個檔案。省 token 且更精確。`context`（可選）提供周圍程式碼幫助定位。
>
> **多匹配行為**：若 `old` 在檔案中出現多次，工具回傳錯誤 `{"ok": false, "error": {"code": "AMBIGUOUS_MATCH", "message": "...", "matches": [行號清單]}}`。此時 AI 需擴大 `old` 片段加入更多上下文使其唯一，或提供 `context`（前後幾行）消歧。若 `old` 完全不存在，回傳 `NOT_FOUND` 錯誤。
