# Token Efficiency — Strategies

> 10 大省 token 策略。概念見 [Guide.md](Guide.md)。

---

## 1. 工具數量精簡（~30 tools，~145 actions）

**原則**：相關操作收進同一工具的 `action` 參數。

```
❌ thediymaker: create_node, delete_node, rename_node, reparent_node,
   duplicate_node, move_node, set_node_property, set_node_properties...
   （8 個工具定義 = 8 份 schema in context）

✅ Open Godot MCP: godot_node_edit（1 個工具，8 個 action）
   （1 份 schema in context）
```

**Token 節省**：149 tools → 30 tools，schema 定義 context 減少 ~80%。

---

## 2. Read/Write 分離 + Auto-allow

見 [Guide.md](Guide.md) §AI Client 設定建議。

---

## 3. Cheap Observation（JSON state，不燒 vision token）

```
❌ 傳統：截圖 → AI 視覺分析 → 「玩家在哪裡？」
   Token 成本：~2000 tokens（vision）

✅ Open Godot MCP：godot_runtime_state digest → JSON
   Token 成本：~200 tokens（JSON）
```

---

## 4. 截圖壓縮與存檔

```
❌ 傳統：base64 PNG 直接進 context
   1080p 截圖 → ~2MB base64 → ~500K tokens

✅ Open Godot MCP：
   - 預設存檔到磁碟，回傳路徑（不進 context）
   - format=jpeg, quality=70 → ~50KB
   - max_width=1280 降解析度
   - AI 視覺模型讀磁碟圖檔，不進 context
```

| 設定 | 大小 | Token 成本 |
|------|------|-----------|
| base64 PNG 1080p | ~2MB | ~500K tokens（爆 context） |
| base64 JPEG 1280w q70 | ~80KB | ~20K tokens |
| 磁碟 JPEG 1280w q70 + 路徑回傳 | ~80KB | ~50 tokens（路徑） |
| `burst` 15 張磁碟 JPEG 1280w q70 + 路徑陣列回傳 | 15 × ~80KB | ~200 tokens（15 個路徑），AI 按需讀圖 |

---

## 5. Diff 回傳

### 場景樹變更

```
❌ 傳統：修改節點後回傳完整場景樹
   1000 節點的場景 → ~50KB JSON

✅ Open Godot MCP：回傳 diff
   {changed: [{path: "/root/Player", property: "position", old: {x:100,y:0}, new: {x:120,y:0}}]}
   → ~200 bytes
```

### 腳本編輯

```
❌ 傳統：AI 重寫整個檔案
   500 行腳本 → ~5KB

✅ Open Godot MCP：godot_script edit（diff-based）
   AI 只提供 old（舊片段）→ new（新片段）
   → ~200 bytes
```

---

## 6. 節點樹摘要模式

```
godot_node_read tree depth=2
→ 只回傳前 2 層結構骨架，不回傳葉節點屬性

{
  "root": "Level1",
  "children": [
    {"name": "Player", "type": "CharacterBody2D", "children_count": 5},
    {"name": "Enemies", "type": "Node2D", "children_count": 12},
    {"name": "UI", "type": "CanvasLayer", "children_count": 8}
  ]
}
```

AI 看到結構後，按需 `godot_node_read inspect` 查特定節點詳情。

---

## 7. 增量查詢

### 日誌

```
godot_log get since_ms=5000
→ 只回傳最近 5 秒的日誌
```

### 信號時間線

```
godot_runtime_state signals since_ms=2000
→ 只回傳最近 2 秒的信號觸發
```

---

## 8. 分頁

```
godot_node_read tree offset=100 limit=50
→ 跳過前 100 個節點，只回傳 50 個
```

---

## 9. 型別感知輸出

```
❌ 傳統：godot_resource inspect 回傳所有 property dump
   SpriteFrames → 200+ properties，大部分無意義

✅ Open Godot MCP：型別感知
   SpriteFrames → {animations: ["idle", "run", "jump"], frame_counts: {idle: 4, run: 8, jump: 6}}
```

---

## 10. 批次操作

```
❌ 傳統：建立 10 個節點 = 10 次 round-trip

✅ Open Godot MCP：godot_batch execute
   operations: [
     {tool: "godot_node_edit", action: "create", params: {...}},
     ...
   ]
   → 一次 round-trip
```

---

## 進階技巧

### 用 digest 取代截圖

```
❌ godot_screenshot game → AI 視覺分析「玩家在哪」
✅ godot_runtime_state digest → JSON 直接告訴 AI 玩家座標
```

### 用 watch 取代多次 digest

```
❌ 連續 10 次 digest 觀察移動
✅ 一次 watch duration_ms=2000 → 時序資料
```

### 用 step_until 取代手動 step + 檢查

```
❌
godot_game_time step ms=16
godot_runtime_state inspect ... 檢查條件
... 重複數十次

✅
godot_game_time step_until condition="is_on_floor()" timeout_ms=5000
```

### 用 LSP 診斷取代啟動遊戲

```
❌ godot_game play → 看錯誤 → stop
✅ godot_lsp diagnostics path="res://player.gd"
```
