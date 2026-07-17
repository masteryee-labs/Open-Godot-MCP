# Realtime Testing — Guide

> 確定性 playtesting：讓 AI 真的「玩」遊戲、看角色行走、修 BUG。這是 Open Godot MCP 解決「AI 看不到遊戲實際運行」的核心。

> 工具 API 見 [../02-Tools/Game-Control.md](../02-Tools/Game-Control.md)、[../02-Tools/Input.md](../02-Tools/Input.md)、[../02-Tools/Runtime-State.md](../02-Tools/Runtime-State.md)。
> 完整範例見 [Examples.md](Examples.md)。

---

## 問題

用戶反映的痛點：

> 「godot-ai 沒辦法真實操作遊戲來看真的遊戲行走等真實狀況修 BUG」

現有 MCP 的 runtime 能力：

| MCP | 能「玩」遊戲？ | 問題 |
|-----|---------------|------|
| godot-ai | ⚠️ 部分 | 有輸入模擬，但無時鐘控制——觀察與遊戲賽跑 |
| godot-mcp (tomyud1) | ⚠️ 部分 | runtime 只能查詢不能改，無時鐘控制 |
| Coding-Solo | ❌ | 只能啟動/停止/讀 log |
| satelliteoflove | ✅ | 確定性 playtesting——但需 TS + Node.js |
| **Open Godot MCP** | ✅ | 確定性 + 即時雙模式，Python + GDScript |

---

## 解法：確定性 Playtesting

借鏡 [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp) 的核心創新。

### 核心概念

遊戲是非確定系統。直接跑遊戲觀察，每幀的物理、輸入、時序都不同——「觀察與遊戲賽跑」。確定性 playtesting 凍結遊戲時鐘，AI 完全控制時間推進：

```
1. freeze 遊戲時鐘 → 遊戲停在 frame 0
2. 注入測試場景 → grant weapon, skip to wave 3, spawn test bot
3. step_until 條件 → boss 出現、玩家落地、血量歸零
4. digest 觀察 → 精確位置、速度、動畫（JSON，無需像素）
5. step + input → 播放關鍵時刻
6. 截圖 → 只在值得花 token 時
```

### 為什麼這能修 BUG

傳統 AI 修遊戲 BUG 的流程：

```
AI 改程式 → 使用者手動玩遊戲 → 截圖回報 → AI 再改 → 重複
```

確定性 playtesting 的流程：

```
AI 改程式 → AI 自己玩遊戲 → AI 自己觀察狀態 → AI 自己驗證修復 → 完成
```

AI 不需人類 ferry 截圖和錯誤 log，自己閉環驗證。

---

## 時鐘控制詳解

### `freeze` — 凍結時鐘

```python
godot_game_time freeze
# → {ok: true, frame: 0}
# Engine.time_scale = 0，遊戲完全停止
```

### `step` — 推進時間

```python
# 推進 500ms
godot_game_time step ms=500
# → {ok: true, frame: 30, elapsed: 0.5}

# 推進 500ms 並附帶輸入
godot_game_time step ms=500 inputs=[
  {type: "action", action: "move_right", pressed: true, at_ms: 0},
  {type: "action", action: "jump", pressed: true, at_ms: 200},
  {type: "action", action: "move_right", pressed: false, at_ms: 450}
]
```

> **`at_ms`**：輸入在時間切片內的注入時間。0 = 切片開始，500 = 切片結束。

### `step_until` — 推進直到條件

```python
# 推進直到 boss 出現
godot_game_time step_until condition="get_tree().get_nodes_in_group('boss').size() >= 1" timeout_ms=10000
# → {ok: true, frame: 450, elapsed: 7.5, condition_met: true}

# 條件未達成（timeout）
godot_game_time step_until condition="health <= 0" timeout_ms=3000
# → {ok: true, frame: 180, elapsed: 3.0, condition_met: false}
```

> **`condition`** 是 GDScript 表達式，在遊戲進程內透過 debugger channel 求值。每 `interval_ms`（預設 16ms）檢查一次。

---

## `_mcp_state()` 協議

讓遊戲節點自願暴露狀態給 AI。

### 使用方式

```gdscript
# player.gd
extends CharacterBody2D

func _mcp_state() -> Dictionary:
    return {
        "health": health,
        "velocity": velocity,
        "anim_state": $AnimationPlayer.current_animation,
        "stamina": stamina,
        "equipped": equipped_weapon.name,
    }
```

### mcp_watch 群組

```gdscript
# 在 _ready() 內
add_to_group("mcp_watch")
```

`godot_runtime_state digest` 會自動收集所有 `mcp_watch` 群組節點的狀態。

### 為什麼這比截圖好

| 方式 | Token 成本 | 精確度 | 適用場景 |
|------|-----------|--------|----------|
| 截圖 | 高（vision token） | 視覺近似 | UI layout、視覺 BUG |
| `_mcp_state()` digest | 低（JSON） | 精確數值 | 邏輯 BUG、移動驗證、狀態機驗證 |

> **原則**：能用 digest 回答的問題就不截圖。截圖只在需要看視覺呈現時用。

> **C# Godot**：`_mcp_state()` 是 GDScript 方法。C# 替代方案見 [../08-CSharp-Support/Compatibility.md](../08-CSharp-Support/Compatibility.md)。

---

## 即時模式 vs 確定性模式

| 模式 | time_scale | 用途 |
|------|-----------|------|
| **即時** | 1.0 | 正常玩遊戲、看整體感受、長時間觀察 |
| **確定性** | 0 → step | 精確重現、條件等待、時序控制 |

### 混合使用

```
1. godot_game play frozen=true       # 確定性模式開始（Engine.time_scale=0）
2. 設定場景、step_until 條件
3. godot_game_time unfreeze          # 切換到即時模式（Engine.time_scale=1.0）
4. godot_input action ...            # 即時輸入
5. godot_screenshot game             # 截圖看整體
6. godot_game_time freeze            # 切回確定性
7. godot_runtime_state digest        # 精確觀察
```

> **注意**：`godot_game resume` 是解除 `get_tree().paused`（pause 系統），不會解除 `freeze`（`Engine.time_scale`）。切換確定性↔即時模式用 `freeze`/`unfreeze`，不用 `pause`/`resume`。詳見 [../02-Tools/Game-Control.md](../02-Tools/Game-Control.md) §pause vs freeze。

---

## 與 DAP 除錯整合

確定性 playtesting 可與 DAP breakpoint 結合。詳見 [../02-Tools/Diagnostics.md](../02-Tools/Diagnostics.md)。

---

## 解析度與座標系統

> **這是 AI 用滑鼠輸入測試遊戲時最常踩的坑**。

### 問題

Godot 有兩個不同的「解析度」：

| 概念 | 來源 | 範例 |
|------|------|------|
| **設計解析度** | `display/window/size/viewport_width/height`（project.godot） | 1920×1080 |
| **實際視窗尺寸** | 遊戲啟動時的視窗像素尺寸 | 1280×720（視窗模式縮小） |

兩者可能不同——視窗模式、stretch mode、HiDPI 縮放、fullscreen 都會造成差異。

### 影響的工具

| 工具 | 影響 | 座標系 |
|------|------|--------|
| `godot_input mouse_button` `position` | 點擊位置錯誤 | 實際視窗像素座標 |
| `godot_input mouse_motion` `delta` | 移動距離錯誤 | 實際視窗像素座標 |
| `godot_screenshot game` `dimensions` | 截圖尺寸與預期不符 | 實際視窗像素尺寸 |
| `godot_runtime_state inspect` `position` | 不受影響 | 遊戲世界座標（設計解析度空間） |

### 正確工作流

```
1. godot_game play scene="res://test.tscn" frozen=true
2. godot_game status
   → {is_playing: true, viewport_size: {width: 1280, height: 720}}
   → 記住 viewport_size，後續滑鼠座標以此為準

3. godot_input mouse_button button="MOUSE_BUTTON_LEFT" position={x: 640, y: 360} pressed=true
   → (640, 360) = 1280×720 的中心，不是 (960, 540)
```

### stretch mode 的額外影響

若遊戲使用 `canvas_items` 或 `viewport` stretch mode：

- **2D 畫面縮放**：設計解析度的畫面被縮放填滿實際視窗
- **節點 `position`**：在設計解析度空間（如 1920×1080 座標系）
- **滑鼠座標**：在實際視窗像素空間（如 1280×720 座標系）
- **兩者不能直接互換**——用 `godot_runtime_state inspect` 讀到的 `position` 不能直接當滑鼠座標

若需從遊戲世界座標轉換到滑鼠座標：

```gdscript
# 透過 godot_exec eval
var world_pos = Vector2(960, 540)  # 設計解析度空間的座標
var screen_pos = get_viewport().get_screen_transform() * world_pos
# screen_pos 即為實際視窗像素座標，可用於 mouse_button position
```

### 設計解析度哪裡查

```
godot_project get_setting key="display/window/size/viewport_width"
godot_project get_setting key="display/window/size/viewport_height"
godot_project get_setting key="display/window/stretch/mode"
```

> **建議**：AI 測試 UI 點擊或滑鼠互動前，一律先 `godot_game status` 取得 `viewport_size`，不要假設解析度。

---

## 限制

### 能做

- ✅ Play-in-Editor 模式下的完整遊戲操作
- ✅ 精確時序的輸入模擬
- ✅ 確定性時間推進
- ✅ 條件等待
- ✅ 精確狀態觀察（JSON）
- ✅ GDScript 注入（測試場景設定）
- ✅ 與 DAP 整合

### 不能做

- ❌ 操作 exported game（release build）——只能 Play-in-Editor
- ❌ 感受「遊戲好不好玩」——這是人類判斷
- ❌ C# 專案的 `godot_exec eval`——C# 是編譯式（見 [../08-CSharp-Support/Compatibility.md](../08-CSharp-Support/Compatibility.md)）

### 注意

- 輸入模擬透過 `Input.parse_input_event()`，可能被遊戲邏輯覆蓋
- 滑鼠座標是實際視窗像素座標，不是設計解析度座標——見 §解析度與座標系統
- `step_until` 的 condition 在遊戲進程內求值，需注意副作用
- `godot_exec eval` 有安全風險——AI 可執行任意 GDScript（見 [../06-Installation/Guide.md](../06-Installation/Guide.md) 安全設定）
