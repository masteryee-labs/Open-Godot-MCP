# Screenshot Tools

> `godot_screenshot` — 視覺回饋，只在值得花 token 時用。

> 省 token 策略見 [../04-Token-Efficiency/Guide.md](../04-Token-Efficiency/Guide.md)。

---

## `godot_screenshot`（唯讀，可 auto-allow）

| Action | 參數 | 回傳 | 說明 |
|--------|------|------|------|
| `game` | `max_width?, format? (png/jpeg/webp), quality?` | `{path, size_bytes, dimensions: {width, height}}` | 遊戲畫面截圖。`path` 是截圖存檔的檔案系統絕對路徑；`size_bytes` 是檔案大小（位元組）；`dimensions` 是 `{width, height}`（實際視窗像素尺寸） |
| `editor` | `viewport?, max_width?` | `{path, size_bytes, dimensions: {width, height}}` | 編輯器視窗截圖。回傳結構同 `game`。`viewport` 可選 `"2d"` 或 `"3d"`，不指定時截取整個編輯器視窗 |
| `region` | `rect, max_width?, source?` | `{path, size_bytes, dimensions: {width, height}}` | 指定區域截圖。`rect` = `{x, y, width, height}`，座標為實際視窗像素座標，**原點 (0,0) 在視窗左上角**（x 向右增、y 向下增，標準螢幕座標）。`dimensions` 是截取區域的尺寸 `{width, height}`。`source` 可選 `"game"` 或 `"editor"`，預設 `"game"`——指定截取遊戲視窗或編輯器視窗的區域。座標系以 `source` 對應的視窗為準（見 [Input.md](Input.md) §座標系統） |
| `burst` | `count?, duration_ms?, interval_ms?, max_width?, format?, quality?` | `{paths: [str], dimensions: {width, height}, count, duration_ms}` | 連續截圖（用於觀察動畫、連續動作）。在 `duration_ms` 時間內截取 `count` 張圖，每張存檔到磁碟，回傳路徑陣列。`paths` 是截圖檔案路徑陣列（順序 = 時間順序，`paths[0]` 是第一張）；`dimensions` 同 `game`（所有幀尺寸相同）；`count` 是實際截取張數（整數）；`duration_ms` 是實際採樣時長（整數，毫秒）。`count` 預設 `10`；`duration_ms` 預設 `1000`（1 秒內截 10 張）；`interval_ms` 是每張截圖之間的間隔（整數，毫秒），不指定時自動計算（`duration_ms / count`），指定時覆蓋自動計算（此時實際採樣時長 = `interval_ms × count`）。可與確定性模式結合：先 `freeze`，再用 `burst` + `step` 精確控制每幀間隔（見 [Game-Control.md](Game-Control.md)） |

> **`dimensions` = 實際視窗像素尺寸**：`game` action 的 `dimensions` 反映**實際遊戲視窗的像素尺寸**，不是專案的設計解析度。若專案設定 1920×1080 但視窗以 1280×720 開啟，截圖尺寸為 1280×720。AI 分析截圖時應以 `dimensions` 為準，不要假設與設計解析度相同（見 [Input.md](Input.md) §座標系統）。

> **省 token 設計**：
> - 預設存檔到磁碟，回傳路徑（不回傳 base64，避免吃 context）
> - `format=jpeg` + `quality=70` 可大幅縮小
> - `max_width=1280` 降解析度
> - AI 視覺模型讀磁碟圖檔，不需 base64 進 context

> **預設值**：`format` 預設 `png`（無壓縮），`quality` 預設 `90`，`max_width` 預設不限（原始解析度）。省 token 建議每次明確指定 `format=jpeg quality=70 max_width=1280`。

> **`burst` vs `watch` vs 手動 `screenshot` loop**——三種觀察連續變化的方式：

| 方式 | 適用 | Token 成本 | 精確度 |
|------|------|-----------|--------|
| `godot_runtime_state watch` | 只需數值變化（位置、速度、動畫名稱、blend 值） | 極低（純 JSON） | 精確數值 |
| `godot_screenshot burst` | 需視覺確認動畫/動作呈現（走路姿勢、技能特效、UI 轉場） | 低（N 個路徑，AI 按需讀圖） | 視覺近似 |
| 手動 `screenshot` + `step` loop | 需精確控制每幀時間點 + 視覺 | 高（N 次 round-trip） | 視覺 + 時序精確 |

> **`burst` 的典型場景**：
> - 「走路動畫看起來對嗎？」→ `burst count=10 duration_ms=1000` → AI 讀 10 張圖看姿勢變化
> - 「技能特效有播放嗎？」→ 先 `step_until` 條件達成（技能開始）→ `burst count=15 duration_ms=1500` → AI 看特效全過程
> - 「待機動畫有循環嗎？」→ `burst count=20 duration_ms=3000` → AI 看是否重複
>
> **與確定性模式結合**（最精確）：先 `freeze` → `burst` 內部自動 `step` 每幀 → 確定性截圖。或 AI 手動：`freeze` → `step ms=100` → `screenshot game` → `step ms=100` → `screenshot game` → ...（完全控制每幀時間點，但 round-trip 多）
>
> **`burst` 在 frozen vs 非 frozen 狀態的行為**：
> - **非 frozen（遊戲正常運行）**：`burst` 在真實時間內截圖，遊戲時間自然推進。`interval_ms` 是真實時間間隔。適合觀察即時動畫。
> - **frozen（`Engine.time_scale=0`）**：`burst` 內部自動 `step` 推進遊戲時間（每幀 `interval_ms` 毫秒），確保每張截圖的遊戲狀態不同。`interval_ms` 是遊戲時間間隔。適合確定性觀察動畫逐幀變化。
> - AI 不需在 `burst` 前後手動 `step`——`burst` 在 frozen 時自動處理時間推進。
