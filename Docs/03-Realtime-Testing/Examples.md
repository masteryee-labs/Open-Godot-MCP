# Realtime Testing — Examples

> 4 個完整工作流範例。概念見 [Guide.md](Guide.md)。

---

## 範例 1：驗證角色移動

```
AI: 我要驗證玩家按右鍵會向右移動

1. godot_game play scene="res://player_test.tscn" frozen=true
   → 遊戲啟動，停在 frame 0

2. godot_exec eval code="Player.add_to_group('mcp_watch')"
   → 設定觀察

3. godot_game_time step ms=500 inputs=[
     {type: "action", action: "move_right", pressed: true, at_ms: 0}
   ]
   → 推進 500ms，全程按右

4. godot_runtime_state digest
   → {nodes: {"/root/Player": {position: {x: 50.0, y: 0.0}, velocity: {x: 100.0, y: 0.0}}}}
   → 確認 x 增加 50，velocity.x = 100 ✓

5. godot_game stop
```

---

## 範例 2：重現穿牆 BUG

```
AI: 使用者回報玩家會穿過東牆，我要重現並診斷

1. godot_game play scene="res://levels/level1.tscn" frozen=true

2. godot_game_time step_until condition="Player.is_on_floor()" timeout_ms=2000
   → 等玩家落地

3. godot_game_time step ms=2000 inputs=[
     {type: "action", action: "move_right", pressed: true, at_ms: 0},
     {type: "action", action: "dash", pressed: true, at_ms: 500}
   ]
   → 向右跑 + 衝刺

4. godot_runtime_state inspect node_path="/root/Player" properties=["position"]
   → {position: {x: 350.0, y: 0.0}}
   → 東牆在 x=340，玩家已穿過

5. godot_runtime_state digest
   → 確認玩家在牆外

6. godot_screenshot game max_width=1280 format="jpeg" quality=70
   → 截圖存檔，AI 視覺確認

7. AI 分析：衝刺時碰撞形狀可能太小，或牆的 collision layer 設定錯誤
   → 讀取 Player 的 CollisionShape2D 和牆的 collision_layer
   → 診斷修復
```

---

## 範例 3：測試 Boss 戰

```
AI: 我要測試 Boss 戰的第三階段

1. godot_game play scene="res://boss_arena.tscn" frozen=true

2. godot_exec eval code="
     GameState.wave = 3
     GameState.spawn_boss()
     Player.health = 100
     Player.inventory.add('sword_legendary')
   "
   → 設定第三階段場景

3. godot_game_time step_until condition="get_tree().get_nodes_in_group('boss').size() >= 1"
   → 等待 Boss 生成

4. godot_runtime_state digest
   → {nodes: {"/root/Boss": {health: 1000, phase: 3, position: {x: 400, y: 200}}}}
   → 確認 Boss 第三階段

5. godot_game_time step ms=1000 inputs=[
     {type: "action", action: "attack", pressed: true, at_ms: 0},
     {type: "action", action: "attack", pressed: false, at_ms: 200},
     {type: "action", action: "dodge", pressed: true, at_ms: 500}
   ]
   → 攻擊 + 閃避

6. godot_runtime_state digest
   → {nodes: {"/root/Boss": {health: 950}, "/root/Player": {health: 100}}}
   → 確認造成 50 傷害、玩家未受傷 ✓

7. godot_game stop
```

---

## 範例 4：動畫混合驗證

```
AI: 確認走路動畫混合正確

1. godot_game play scene="res://player.tscn" frozen=true

2. godot_game_time step ms=2000 inputs=[
     {type: "joypad", control: "axis", index: "JOY_AXIS_LEFT_X", value: 0.5, at_ms: 0}
   ]
   → 左搖桿半偏 2 秒（走路而非跑步）

3. godot_runtime_state inspect node_path="/root/Player/AnimationTree" properties=["parameters/walk/blend_position", "parameters/walk/blend_amount"]
   → {parameters/walk/blend_position: {x: 0.5, y: 0}, parameters/walk/blend_amount: 0.5}

4. godot_runtime_state watch node_path="/root/Player/AnimationTree" property="parameters/walk/blend_position" duration_ms=1000
   → {samples: [{t_ms: 0, value: {x: 0.5, y: 0}}, {t_ms: 500, value: {x: 0.5, y: 0}}, ...]}
   → 確認 blend_position 穩定在 {x: 0.5, y: 0} ✓
```

---

## 範例 5：動畫視覺驗證（連續截圖）

```
AI: 確認技能動畫「火焰斬」的視覺特效正確播放

1. godot_game play scene="res://arena.tscn" frozen=true

2. godot_exec eval code="Player.mana = 100; Player.learn_skill('fire_slash')"
   → 設定可施放技能

3. godot_game_time step_until condition="Player.is_on_floor()" timeout_ms=2000
   → 等玩家落地

4. godot_game_time step ms=200 inputs=[
     {type: "action", action: "fire_slash", pressed: true, at_ms: 0}
   ]
   → 施放技能，推進 200ms 讓動畫開始

5. godot_screenshot burst count=15 duration_ms=1500 format="jpeg" quality=70 max_width=1280
   → {paths: ["/tmp/shot_0.jpg", "/tmp/shot_1.jpg", ...], dimensions: {width: 1280, height: 720}, count: 15, duration_ms: 1500}
   → 1.5 秒內截 15 張，涵蓋技能動畫全過程

6. AI 視覺模型依序讀取 paths 中的圖檔
   → 確認：第 0-2 幀為起手動作、第 3-8 幀為火焰特效出現、第 9-14 幀為收招
   → 若特效缺失或時序不對 → 診斷 AnimationPlayer 軌道設定

7. godot_game stop
```

> **`burst` vs `watch`**：`watch` 只回傳數值時序（如 `blend_position` 的變化），適合驗證動畫狀態機邏輯。`burst` 回傳連續視覺幀，適合驗證動畫的視覺呈現（姿勢、特效、轉場）。需兩者結合時，先 `watch` 確認邏輯正確，再 `burst` 確認視覺正確。
