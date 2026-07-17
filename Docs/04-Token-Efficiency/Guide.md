# Token Efficiency — Guide

> AI 的 context window 是有限資源。Open Godot MCP 的每個設計決策都考慮 Token 效率。

> 具體策略見 [Strategies.md](Strategies.md)。

---

## 問題

現有 MCP 的 Token 浪費：

| 浪費源 | 現有 MCP 的表現 | 影響 |
|--------|----------------|------|
| 工具定義太多 | thediymaker 149 tools，schema 定義吃大量 context | AI 還沒開工就花一堆 token 讀定義 |
| 完整場景樹回傳 | 每次回傳所有節點所有屬性 | 大型場景一次回傳數 KB JSON |
| PNG 截圖無壓縮 | base64 PNG 直接進 context | 一張 1080p 截圖 ~2MB base64 ≈ 500K tokens |
| 無 diff 機制 | 每次都回傳完整資料 | 重複查詢浪費 |
| 無摘要模式 | 節點樹無結構骨架選項 | AI 要讀完整樹才知道結構 |

---

## 核心原則

1. **能用 JSON 回答的問題就不截圖**——cheap observation
2. **read/write 分離**——read auto-allow，write gate
3. **diff 回傳**——只回傳變更部分
4. **截圖存磁碟**——不進 context
5. **批次操作**——減少 round-trip

---

## Token 成本估算

### 典型工作流

| 工作流 | 傳統 MCP | Open Godot MCP | 節省 |
|--------|---------|----------------|------|
| 讀取場景結構 | ~5K tokens（完整樹） | ~500 tokens（摘要 depth=2） | 90% |
| 驗證玩家移動 | ~3K tokens（截圖+視覺） | ~300 tokens（digest JSON） | 90% |
| 修改腳本 | ~5K tokens（重寫全文） | ~300 tokens（diff） | 94% |
| 建立場景 | ~10K tokens（10 次 round-trip） | ~2K tokens（批次） | 80% |
| 讀取日誌 | ~2K tokens（全部） | ~200 tokens（since_ms） | 90% |

### 工具定義的 context 占用

| MCP | 工具數 | schema context |
|-----|--------|---------------|
| thediymaker | 149 | ~50K tokens |
| Coding-Solo | 20 | ~7K tokens |
| satelliteoflove | 21 | ~7K tokens |
| **Open Godot MCP** | 30 | ~10K tokens |

> 30 tools 是平衡點：涵蓋完整工作流，但 schema 定義不會吃太多 context。

---

## AI Client 設定建議

### Auto-allow 清單（read 工具，不需確認）

```
godot_editor_read
godot_node_read
godot_resource
godot_runtime_state
godot_screenshot
godot_lsp
godot_profiler
godot_log (get, errors actions)
godot_docs
godot_health
godot_filesystem (read actions)
godot_scene (read actions)
godot_script (read, validate actions)
godot_project (read actions)
godot_input_map (list, get actions)
godot_animation (list, get actions)
godot_tilemap (read_cells action)
godot_game (status action)
godot_debugger (stack_trace, variables, sessions actions)
godot_test (list, results actions)
godot_network (list_instances, sync_state actions)
godot_instance (list action)
godot_asset (list, info actions)
godot_export (presets action)
```

### Gated 清單（write 工具，每次確認）

```
godot_editor_edit
godot_scene (create, save, save_as, instantiate)
godot_node_edit
godot_script (create, edit, write, attach, detach)
godot_project (set_setting, autoload_add, autoload_remove, rescan)
godot_input_map (add, remove, bind, ensure)
godot_animation (create, add_track, delete, play, stop, preset)
godot_tilemap (set_cell, set_cells, clear)
godot_game (play, stop, pause, resume)
godot_game_time
godot_input
godot_exec
godot_debugger (set_breakpoint, remove_breakpoint, resume, step_over, step_into)
godot_test (run, create)
godot_network (launch_instance, switch, terminate, simulate_peer, network_condition, rpc_call)
godot_instance (launch_editor, switch, terminate, adopt)
godot_filesystem (create, delete, rename)
godot_asset (generate_2d, import)
godot_export (export, add_preset)
godot_log (clear)
godot_batch
```
