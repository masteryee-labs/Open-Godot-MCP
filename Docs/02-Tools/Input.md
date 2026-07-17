# Input Tools

> `godot_input` — 向執行中的遊戲注入輸入。

> 詳細工作流見 [../03-Realtime-Testing/Guide.md](../03-Realtime-Testing/Guide.md)。

---

## `godot_input`（寫入，gated）

| Action | 參數 | 回傳 | 說明 |
|--------|------|------|------|
| `action` | `action, pressed, strength?` | `{ok}` | InputMap action（`strength` 0.0-1.0，類比按壓程度） |
| `key` | `key, pressed, modifiers?` | `{ok}` | 鍵盤按鍵 |
| `mouse_button` | `button, position, pressed` | `{ok}` | 滑鼠按鈕 |
| `mouse_motion` | `delta, button_mask?` | `{ok}` | 滑鼠移動（相對）。`button_mask?` 是移動時按住的滑鼠按鈕清單（字串陣列，同 `button` 格式，如 `["MOUSE_BUTTON_LEFT"]` 表示拖曳），不指定時為無按鈕 |
| `joypad` | `device, control, index, value?` | `{ok}` | 手把按鈕/搖桿 |
| `text` | `text` | `{ok}` | 文字輸入（unicode） |

> **參數格式**：
> - `key`：Godot Key 常數字串，如 `"KEY_SPACE"`、`"KEY_A"`、`"KEY_ESCAPE"`、`"KEY_F1"`
> - `modifiers`：字串陣列，如 `["ctrl", "shift", "alt", "meta"]`
> - `button`（mouse_button）：Godot MouseButton 常數字串，如 `"MOUSE_BUTTON_LEFT"`、`"MOUSE_BUTTON_RIGHT"`、`"MOUSE_BUTTON_WHEEL_UP"`
> - `button_mask`（mouse_motion）：字串陣列，同 `button` 格式
> - `position`（mouse_button）：`{x, y}`，實際視窗像素座標（見下方 §座標系統）
> - `delta`（mouse_motion）：`{x, y}`，相對移動量（像素）

> **精確時序**：輸入可包在 `godot_game_time step` 的 `inputs` 參數內，在特定時間切片注入。

> **`joypad` 參數**：
> - `device`：手把裝置 ID（整數，0 = 第一個手把）
> - `control`：`"button"` 或 `"axis"`
> - `index`：按鈕索引（如 `"JOY_BUTTON_A"`）或軸索引（如 `"JOY_AXIS_LEFT_X"`）
> - `value`（僅 axis）：軸值，`-1.0` 到 `1.0`

## 座標系統

> **滑鼠座標 = 實際視窗像素座標，不是設計解析度座標**。

`mouse_button` 的 `position` 和 `mouse_motion` 的 `delta` 都是**實際遊戲視窗的像素座標**（透過 `Input.parse_input_event()` 注入，使用 viewport 實際尺寸）。這與 Godot 專案設定的「設計解析度」（`display/window/size/viewport_width/height`）可能不同。

**常見陷阱**：
- 專案設計解析度 1920×1080，但遊戲視窗以 1280×720 開啟
- AI 假設 1920×1080 座標系，發送 `position={x: 960, y: 540}`（以為是畫面中心）
- 實際視窗只有 1280×720，座標 (960, 540) 偏右下，不是中心

**正確做法**：
1. 先呼叫 `godot_game status` 取得 `viewport_size`（實際視窗像素尺寸）
2. 以 `viewport_size` 為座標系基準計算滑鼠位置
3. 若需以設計解析度座標發送，用 `godot_exec eval` 轉換：
   ```gdscript
   # 設計解析度座標 → 實際視窗座標
   var design_pos = Vector2(960, 540)
   var actual_pos = get_viewport().get_screen_transform() * design_pos
   ```

> **stretch mode 影響**：若遊戲使用 `canvas_items` 或 `viewport` stretch mode，2D 畫面會縮放以填滿視窗。節點的 `position` 屬性是**遊戲世界座標**（設計解析度空間），但滑鼠輸入是**實際視窗像素座標**——兩者座標系不同。用 `godot_runtime_state inspect` 讀到的 `position` 不能直接當滑鼠座標用，需透過 viewport transform 轉換。
