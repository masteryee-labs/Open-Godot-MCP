# 07 — Roadmap

> Open Godot MCP 開發路線圖。按優先級分階段。

---

## 開發原則

1. **先穩定再功能**——連線穩定是底線，不穩的 MCP 再多功能也沒用
2. **先核心再擴展**——確定性 playtesting 是核心差異化，先做完整
3. **先免費再一切**——所有功能 MIT 開源，不做 freemium
4. **測試驅動**——每個功能都要有測試，AI 能自己驗證

---

## Phase 0：基礎架構（MVP）

> 目標：能連線、能編輯、能啟動遊戲。證明架構可行。

### 0.1 MCP Server 骨架

- [ ] Python 專案結構（pyproject.toml, src/open_godot_mcp/）
- [ ] FastMCP server 入口（stdio transport）
- [ ] 基礎工具註冊機制
- [ ] 錯誤處理與日誌

### 0.2 Editor Bridge 骨架

- [ ] GDScript EditorPlugin（plugin.cfg, plugin.gd）
- [ ] WebSocket server（可配置 port）
- [ ] JSON-RPC dispatcher
- [ ] Handshake 協議
- [ ] Variant 序列化（variant_codec.gd）

### 0.3 連線穩定機制

- [ ] 心跳機制（5s ping/pong）
- [ ] 智慧重連（指數退避 + 最大次數）
- [ ] Windows Port Reservation 偵測
- [ ] Port 自動避讓
- [ ] 連線狀態 dock UI

### 0.4 基礎編輯器工具

- [ ] `godot_editor_read`（state, selection, open_scenes, viewport, performance）
- [ ] `godot_editor_edit`（open_scene, save_scene, save_all, set_selection, focus_node, quit）
- [ ] `godot_scene`（create, read, save, save_as, hierarchy, instantiate）
- [ ] `godot_node_read`（inspect, tree, find, children, properties）
- [ ] `godot_node_edit`（create, delete, reparent, rename, duplicate, set_property, set_properties, set_groups）
- [ ] `godot_script`（read, create, edit, write, validate, attach, detach）
- [ ] `godot_project`（info, get_setting, set_setting, list_settings, autoload_list/add/remove, rescan）
- [ ] `godot_input_map`（list, add, remove, bind, ensure, get）
- [ ] `godot_resource`（inspect, list, find, info）
- [ ] `godot_filesystem`（list, read, search, create, delete, rename）
- [ ] `godot_docs`（fetch, search）
- [ ] `godot_log`（get, errors, clear）
- [ ] `godot_health`（check, diagnostics）

### 0.5 驗證

- [ ] 基礎測試套件
- [ ] 連線穩定性測試（斷線重連、port 衝突）
- [ ] 編輯器操作 round-trip 測試

**Phase 0 完成標準**：AI 能穩定連線、編輯場景/節點/腳本、連線不會無故斷開。

---

## Phase 1：真實遊戲操作（核心差異化）

> 目標：AI 能真的「玩」遊戲、看狀態、修 BUG。這是解決用戶核心痛點的階段。

### 1.1 Runtime Autoload

- [ ] runtime_autoload.gd（遊戲進程內）
- [ ] Debugger channel 連線（Editor Bridge ↔ Running Game）
- [ ] 自動注入/移除機制（遊戲啟動時注入、停止時移除）
- [ ] 匯出時 strip（mcp_export_plugin.gd）

### 1.2 遊戲控制

- [ ] `godot_game`（play, stop, pause, resume, status）
- [ ] Frozen 模式支援（time_scale=0 啟動）

### 1.3 時鐘控制（確定性 playtesting 核心）

- [ ] `godot_game_time freeze`
- [ ] `godot_game_time unfreeze`（解除凍結）
- [ ] `godot_game_time step`（含 inputs 參數）
- [ ] `godot_game_time step_until`（condition 求值）

### 1.4 輸入模擬

- [ ] `godot_input action`
- [ ] `godot_input key`（含 modifiers）
- [ ] `godot_input mouse_button`
- [ ] `godot_input mouse_motion`
- [ ] `godot_input joypad`
- [ ] `godot_input text`

### 1.5 狀態觀察

- [ ] `godot_runtime_state digest`（mcp_watch 群組 + _mcp_state()）
- [ ] `godot_runtime_state inspect`
- [ ] `godot_runtime_state watch`
- [ ] `godot_runtime_state signals`

### 1.6 GDScript 注入

- [ ] `godot_exec eval`（含 await 支援）
- [ ] `godot_exec call`

### 1.7 截圖

- [ ] `godot_screenshot game`（含壓縮、存檔）
- [ ] `godot_screenshot editor`
- [ ] `godot_screenshot region`
- [ ] `godot_screenshot burst`（連續截圖，用於動畫/連續動作觀察）

### 1.8 驗證

- [ ] 確定性 playtesting 端到端測試
- [ ] 輸入模擬精確時序測試
- [ ] 狀態觀察準確性測試
- [ ] 範例：AI 自主重現並修復穿牆 BUG

**Phase 1 完成標準**：AI 能啟動遊戲、凍結時鐘、注入輸入、觀察狀態、截圖、自主驗證修復。

---

## Phase 2：連線遊戲測試（獨有功能）

> 目標：AI 能測試 multiplayer 遊戲。所有現有 MCP 都缺的能力。

### 2.1 多實例管理

- [ ] `godot_instance launch_editor`
- [ ] `godot_instance list`
- [ ] `godot_instance switch`
- [ ] `godot_instance terminate`
- [ ] `godot_instance adopt`
- [ ] Port 隔離自動分配

### 2.2 網路實例

- [ ] `godot_network launch_instance`（host/client）
- [ ] `godot_network list_instances`
- [ ] `godot_network switch`
- [ ] `godot_network terminate`

### 2.3 網路條件注入

- [ ] Network conditioner（封包攔截）
- [ ] `godot_network network_condition`（latency, loss, jitter）
- [ ] 頻寬限制（未來）

### 2.4 同步驗證

- [ ] `godot_network sync_state`
- [ ] `godot_network rpc_call`
- [ ] `godot_network simulate_peer`

### 2.5 驗證

- [ ] 多實例啟動/終止測試
- [ ] 同步狀態比較測試
- [ ] 網路條件注入測試
- [ ] 斷線重連測試
- [ ] 範例：AI 自主測試 4 人連線遊戲同步

**Phase 2 完成標準**：AI 能啟動多實例、驗證同步、注入網路條件、測試斷線重連。

---

## Phase 3：除錯與程式碼智慧

> 目標：完整開發體驗，DAP + LSP 整合。

### 3.1 DAP 整合

- [ ] `godot_debugger set_breakpoint`（含 condition）
- [ ] `godot_debugger remove_breakpoint`
- [ ] `godot_debugger resume` / `step_over` / `step_into`
- [ ] `godot_debugger stack_trace`
- [ ] `godot_debugger variables`
- [ ] `godot_debugger sessions`（偵錯 session 狀態）
- [ ] 自動連線（遊戲 pause 時自動報告）

### 3.2 LSP 整合

- [ ] `godot_lsp diagnostics`
- [ ] `godot_lsp complete`
- [ ] `godot_lsp definition`
- [ ] `godot_lsp hover`
- [ ] `godot_lsp symbols`

### 3.3 效能分析

- [ ] `godot_profiler snapshot`
- [ ] `godot_profiler series`（含 spike 偵測）
- [ ] `godot_profiler spikes`

### 3.4 測試框架

- [ ] `godot_test list`
- [ ] `godot_test run`
- [ ] `godot_test results`
- [ ] `godot_test create`
- [ ] McpTestSuite 基類

### 3.5 資源操作工具

- [ ] `godot_animation`（list, get, create, add_track, delete, play, stop, preset）
- [ ] `godot_tilemap`（read_cells, set_cell, set_cells, clear）
- [ ] `godot_asset`（generate_2d, list, info, import）
- [ ] `godot_export`（presets, export, add_preset）
- [ ] `godot_batch`（execute）

**Phase 3 完成標準**：AI 能設定中斷點、inspect 變數、靜態診斷、效能分析、跑測試、操作動畫/TileMap/資產/匯出。

---

## Phase 4：Token 效率優化

> 目標：每個工具都有省 token 模式。

### 4.1 Diff 回傳

- [ ] 場景樹變更 diff
- [ ] 節點屬性變更 diff
- [ ] 腳本編輯 diff（已含於 `godot_script edit`）

### 4.2 摘要模式

- [ ] 節點樹摘要（depth 限制 + children_count）
- [ ] 資源型別感知輸出
- [ ] 日誌摘要（since_ms + level 過濾）

### 4.3 截圖優化

- [ ] JPEG/WebP 壓縮
- [ ] 解析度降採樣
- [ ] 磁碟存檔 + 路徑回傳（不進 context）

### 4.4 批次操作

- [ ] 批次結果彙總（`godot_batch execute` 已在 Phase 3.5 實作）

### 4.5 MCP Resources & Prompts

- [ ] `godot://editor/state` 等 resources
- [ ] `playtest` / `debug_breakpoint` / `network_test` 等 prompts

**Phase 4 完成標準**：Token 消耗比 Phase 1 減少 50%+。

---

## Phase 5：生產就緒

> 目標：穩定、文件齊全、易用。

### 5.1 文件

- [ ] 完整 API 文件（所有 tools/actions）
- [ ] 教學影片
- [ ] 範例專案
- [ ] 疑難排解指南擴充

### 5.2 測試

- [ ] 完整單元測試
- [ ] 整合測試
- [ ] 端到端測試（AI 自主完成任務的 eval harness）
- [ ] 連線壓力測試

### 5.3 部署

- [ ] PyPI 發布
- [ ] Godot Asset Library 發布
- [ ] CI/CD（GitHub Actions）
- [ ] 跨平台測試（Windows / macOS / Linux）

### 5.4 效能

- [ ] 大型專案效能測試（10K+ 節點）
- [ ] 記憶體使用優化
- [ ] 延遲優化

**Phase 5 完成標準**：PyPI 可安裝、Godot Asset Library 可下載、三平台測試通過。

---

## Phase 6：未來擴展

> 目標：進階功能，按社群需求推進。
>
> **缺口來源**：[../09-Research/Paid-MCP-Analysis.md](../09-Research/Paid-MCP-Analysis.md) 的論壇調研與競品分析。

### 6.0 競爭力缺口（立即補）

> 這些是付費競品都有、論壇開發者重複要求、但 Open Godot MCP 缺少的功能。

#### 6.0.1 Undo/Redo 支援

- [ ] `godot_node_edit` create/delete/reparent/set_property 包入 `EditorUndoRedoManager`
- [ ] `godot_scene` create/save 包入 undo action
- [ ] `godot_script` edit 包入 undo action
- [ ] 場景 dirty 標記（`mark_scene_as_unsaved()`）

#### 6.0.2 Signal 連接管理

- [ ] `godot_node_edit connect_signal`（source, signal, target, method）
- [ ] `godot_node_edit disconnect_signal`
- [ ] `godot_node_read get_signals`（列出所有 signal + connections）

#### 6.0.3 Node Groups

- [ ] `godot_node_edit set_groups` / `add_to_group` / `remove_from_group`
- [ ] `godot_node_read get_groups`
- [ ] `godot_node_read find_in_group`

#### 6.0.4 Batch Node Creation

- [ ] `godot_node_edit create_batch`（一次建多個 node，partial 失敗回滾）

#### 6.0.5 Assert / Verification

- [ ] `godot_assert`（在遊戲進程內執行條件判斷）
- [ ] `godot_assert_screen_text`（OCR 或 pixel match）
- [ ] `godot_assert_image_diff`（baseline 比對 + tolerance）

#### 6.0.6 Input Recording / Replay

- [ ] `godot_input record_start` / `record_stop`
- [ ] `godot_input replay`（確定性回放）
- [ ] 錄製格式序列化（JSON time-series）

#### 6.0.7 DAP 擴充

- [ ] `godot_debugger set_breakpoint`（含 condition）
- [ ] `godot_debugger remove_breakpoint`
- [ ] `godot_debugger resume` / `step_over` / `step_into`
- [ ] `godot_debugger stack_trace`
- [ ] `godot_debugger variables`
- [ ] 自動連線（遊戲 pause 時自動報告）

#### 6.0.8 C# Compile-Check

> 詳見 [../08-CSharp-Support/Compatibility.md](../08-CSharp-Support/Compatibility.md) 與 [../08-CSharp-Support/Syntax-Check.md](../08-CSharp-Support/Syntax-Check.md)。

- [ ] `godot_csharp_check`（syntax, build, analyze）— Roslyn syntax-first 語法檢查
- [ ] `godot_csharp_script`（C# 檔案讀寫 + Roslyn 整合）
- [ ] C# 專案自動偵測與模式切換

### 6.1 AI 工作流增強

- [ ] 自動 BUG 重現（從錯誤 log 自動生成 playtest 腳本）
- [ ] 自動測試生成（從場景結構生成測試骨架）
- [ ] 效能自動優化建議

### 6.2 更多 Godot 功能

- [ ] AnimationTree 操作（state machine, blend tree, transitions）
- [ ] Shader 編輯（create/edit/assign/params）
- [ ] NavigationServer 操作（nav mesh bake, agent, pathfinding）
- [ ] PhysicsServer 直接操作（collision setup, layers, raycasts）
- [ ] Audio 控制（player, bus effects chain）
- [ ] Theme/UI overrides（StyleBoxFlat, color/font overrides）
- [ ] Particles（GPU particles + presets）
- [ ] 3D Scene 建構（MeshInstance, PBR material, lighting, camera）

### 6.3 程式碼分析（靜態）

- [ ] `godot_analyze dependency_graph`（preload/load 引用圖譜）
- [ ] `godot_analyze signal_map`（signal 連接流向圖）
- [ ] `godot_analyze impact_check`（變更影響分析）
- [ ] `godot_analyze unused_resources`（未使用資源偵測）
- [ ] `godot_analyze project_summary`（專案結構摘要）

### 6.4 MCP 協議完整性

- [ ] MCP Resources（`godot://editor/state` 等）
- [ ] MCP Prompts（`playtest` / `debug_breakpoint` / `network_test`）
- [ ] Tool annotations（read-only / destructive / open-world）
- [ ] `tools/list_changed` 通知
- [ ] Effort slider（動態控制 advertised tools 數量）

### 6.5 團隊協作

- [ ] 多 AI client 共享 session
- [ ] 操作錄製與回放
- [ ] Git 整合
- [ ] Audit log（最近 200 次呼叫記錄）

### 6.6 雲端測試

- [ ] 遠端 Godot 實例管理
- [ ] 雲端 multiplayer 測試（真實跨網路）
- [ ] CI/CD 整合（GitHub Actions 跑 playtest）

---

## 版本規劃

| 版本 | 對應 Phase | 目標 |
|------|-----------|------|
| v0.1.0 | Phase 0 | MVP——能連線、能編輯 |
| v0.2.0 | Phase 1 | 確定性 playtesting |
| v0.3.0 | Phase 2 | 連線遊戲測試 |
| v0.4.0 | Phase 3 | DAP + LSP + Profiler |
| v0.5.0 | Phase 4 | Token 效率優化 |
| v1.0.0 | Phase 5 | 生產就緒 |
| v1.x+ | Phase 6 | 持續擴展 |

---

## 貢獻指南

歡迎貢獻。請先讀 [../00-Overview/Overview.md](../00-Overview/Overview.md) 了解設計理念。

### 優先貢獻領域

1. **Phase 0/1**——核心架構與確定性 playtesting
2. **連線穩定改進**——回報連線問題、改進重連機制
3. **跨平台測試**——macOS / Linux 上的相容性
4. **文件與範例**——工作流範例、教學

### 不接受的貢獻

- 付費功能 / freemium 設計
- 違反 MIT 授權的程式碼
- 硬編碼 port 或路徑
- 不含測試的功能
