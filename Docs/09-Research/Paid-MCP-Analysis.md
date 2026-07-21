# 付費 Godot MCP 功能分析

> 2026-07 調研。分析市面上付費 Godot MCP 的功能、定價、實作難度，並對比 Open Godot MCP 的缺口。
>
> 相關：[Existing-MCP-Survey.md](Existing-MCP-Survey.md) | [../07-Roadmap/Roadmap.md](../07-Roadmap/Roadmap.md)

---

## 1. 市面付費 Godot MCP 一覽

| 產品 | 定價 | 工具數 | 架構 | 付費模式 |
|------|------|--------|------|----------|
| [Godot MCP Pro](https://y1uda.itch.io/godot-mcp-pro) (youichi-uda) | $15 一次買斷 | 175 | Node.js + GDScript, WebSocket | 付費解鎖 server/ 目錄 |
| [GodotIQ Pro](https://godotiq.com) | $19 一次買斷 | 24 免費 + 14 Pro | Python + GDScript | Pro bundle（私有，license key） |
| [Beckett Full](https://beckettlabs.itch.io/beckett-godot-mcp) (beckettlabs) | $15 一次買斷 | 37 skill packs | 純 GDScript，零 sidecar | 付費解鎖 playtest/assert/input |
| [StraySpark Godot MCP](https://www.strayspark.studio/products/godot-mcp-server) | $32-$96 一次買斷 | 131 | TS + GDScript | 個人/商用分級 |
| [GDAI MCP](https://github.com/hi-godot/godot-ai) ( referenced) | $19 一次買斷 | ~30 | Python + GDScript | 付費解鎖完整工具 |

**定價模式觀察**：全部都是「一次買斷，終身更新」，無訂閱制。價格區間 $15-$96。最貴的 StraySpark 按營收分級（$100k 以下 $32，以上 $96）。

---

## 2. 付費功能拆解——到底賣什麼？

### 2.1 Godot MCP Pro（$15, 175 tools）——賣「工具廣度」

付費解鎖的 23 個類別：

| 類別 | 免費有？ | 付費獨有 | 實作難度 | Open Godot MCP 現狀 |
|------|---------|----------|----------|---------------------|
| Scene & Node 管理 | ✅ | full undo/redo | 中 | ❌ 無 undo/redo |
| Script 編輯 | ✅ | — | — | ✅ 有 |
| Input 模擬 | ✅ | recording/replay | 中 | ⚠️ 有基礎輸入，無錄製 |
| Runtime 分析 | ✅ | 15 tools（live tree, tweak, capture） | 中 | ✅ 有 digest/inspect |
| 3D Scene 建構 | — | MeshInstance, PBR material, lighting, camera | 中 | ❌ 無 |
| Animation & AnimationTree | — | state machine, blend tree, keyframes | 高 | ⚠️ 有基礎 animation，無 AnimationTree |
| Physics | — | collision setup, layers, raycasts | 中 | ❌ 無 |
| Navigation | — | nav mesh baking, agent, pathfinding | 中 | ❌ 無 |
| Particles | — | GPU particles + presets | 低 | ❌ 無 |
| Audio | — | player, bus effects chain | 低 | ❌ 無 |
| TileMapLayer | ✅ | — | — | ✅ 有 |
| Shader | — | create/edit/assign/params | 中 | ❌ 無 |
| Theme/UI | — | StyleBoxFlat, color/font overrides | 低 | ❌ 無 |
| Resource | ✅ | .tres CRUD, autoload | 低 | ⚠️ 有 inspect/list/find |
| Batch | ✅ | find by type, bulk set, dependency analysis | 中 | ✅ 有 batch execute |
| Testing & QA | — | automated scenarios, assertions, screenshot diff | 高 | ❌ 無 |
| Code analysis | — | unused resources, signal flow map, complexity | 中 | ❌ 無 |
| Export | ✅ | — | — | ✅ 有 presets |
| Smart type parsing | ✅ | Vector2, Color 等 | 低 | ✅ variant_codec 有 |
| UndoRedo | ✅ | 全操作 | 中 | ❌ 無 |

**核心賣點**：工具數量（175 vs 免費的 ~30）。付費解鎖的不是「更難的功能」，而是「更多領域的覆蓋」。

### 2.2 GodotIQ Pro（$19, 14 intelligence tools）——賣「分析智慧」

Pro 獨有的 14 個「智慧」工具（全部 filesystem-only，不需 addon）：

| 工具 | 功能 | 實作難度 | Open Godot MCP 現狀 |
|------|------|----------|---------------------|
| `project_summary` | 專案結構摘要 | 低 | ❌ 無 |
| `file_context` | 檔案上下文分析 | 低 | ❌ 無 |
| `dependency_graph` | 依賴圖譜 | 中 | ❌ 無 |
| `validate` | 程式碼驗證 | 低 | ⚠️ 有 script validate |
| `signal_map` | signal 流向圖 | 中 | ❌ 無 |
| `impact_check` | 變更影響分析 | 中 | ❌ 無 |
| `trace_flow` | 執行流追蹤 | 高 | ❌ 無 |
| `animation_audit` | 動畫審計 | 中 | ❌ 無 |
| `asset_registry` | 資產清單 | 低 | ⚠️ 有 resource list |
| `suggest_scale` | 縮放建議 | 低 | ❌ 無 |
| `scene_map` | 場景地圖 | 中 | ⚠️ 有 scene hierarchy |
| `spatial_audit` | 空間配置審計 | 中 | ❌ 無 |
| `placement` | 放置建議 | 中 | ❌ 無 |
| `explore` | 視覺探索 | 中 | ❌ 無 |

**核心賣點**：不是「更難的引擎操作」，而是「靜態分析 + 建議」。這些工具讀檔案、建圖譜、給建議，**不需要活引擎**。本質是 Python 腳本做 AST/regex 分析。

### 2.3 Beckett Full（$15）——賣「AI 能 playtest」

免費 Lite vs 付費 Full 的差異：

| 功能 | Lite 免費 | Full 付費 | 實作難度 | Open Godot MCP 現狀 |
|------|----------|----------|----------|---------------------|
| Inspect node/class | ✅ | ✅ | — | ✅ 有 |
| Author scenes/scripts | ✅ | ✅ | — | ✅ 有 |
| GDScript + C# compile-check | ✅ | ✅ | — | ⚠️ GDScript 有，C# 無 |
| Undo + batch rollback | ✅ | ✅ | — | ❌ 無 |
| Run game + tail logs | ✅ | ✅ | — | ✅ 有 |
| Screenshot + live tree | ✅ | ✅ | — | ✅ 有 |
| MCP Resources + Prompts | ✅ | ✅ | — | ❌ 無 |
| **AI drives input** | — | ✅ | 中 | ✅ **已有** |
| **AI verifies (asserts)** | — | ✅ | 高 | ❌ 無 |
| **In-editor test runner** | — | ✅ | 中 | ⚠️ 有 godot_test 但非 in-editor |
| **Animation authoring** | — | ✅ | 中 | ⚠️ 有基礎 |
| **Screen-text/image diff** | — | ✅ | 高 | ❌ 無 |
| **Effort slider 1-6** | ✅(1-4) | ✅(1-6) | 低 | ❌ 無 |

**核心賣點**：playtest loop（input → assert → screenshot diff → fix）。Beckett 認為這是「每個免費 Godot MCP 的缺口」。

### 2.4 StraySpark（$32-$96, 131 tools）——賣「完整 + 商用授權」

16 個類別，131 tools。賣點是「full source code + commercial license + priority support」。功能覆蓋與 Godot MCP Pro 類似但更貴。

---

## 3. 付費功能值得付費嗎？——難度分析

### 3.1 「不難做」的功能（低成本高價值）

| 功能 | 難度 | 為什麼不難 | 建議優先級 |
|------|------|-----------|-----------|
| **Undo/Redo** | 中 | Godot 有 `EditorUndoRedoManager` API，wrap do/undo method 即可 | **P0** — 用戶期望基本功能 |
| **Signal connect/disconnect** | 低 | `node.connect(signal, target, method)` 一行呼叫 | **P0** — 場景編輯必需 |
| **Node groups** | 低 | `add_to_group` / `get_groups` | **P1** |
| **Resource .tres CRUD** | 低 | `ResourceSaver.save()` / `load()` | **P1** |
| **Audio player 控制** | 低 | `AudioStreamPlayer.play()/stop()` | **P2** |
| **Theme/UI overrides** | 低 | `add_theme_override` | **P2** |
| **Shader create/edit** | 中 | 文件讀寫 + `ShaderMaterial` | **P1** |
| **Project summary** | 低 | 遞迴掃描 res:// + 統計 | **P1** |
| **Effort slider** | 低 | 動態 tools/list 過濾 | **P2** |

### 3.2 「中等難度」的功能

| 功能 | 難度 | 關鍵挑戰 | 建議優先級 |
|------|------|----------|-----------|
| **Input recording/replay** | 中 | 需時間軸序列化 + 確定性回放 | **P1** — playtesting 核心 |
| **3D Scene 建構** | 中 | MeshInstance3D + Material + Light 的組合 | **P2** |
| **Physics collision setup** | 中 | 自動偵測 2D/3D + 形狀配對 | **P2** |
| **Navigation mesh bake** | 中 | `NavigationServer3D.bake()` + region 設定 | **P2** |
| **Dependency graph** | 中 | 解析 .gd `preload` / `load` + .tscn node 引用 | **P1** |
| **Signal flow map** | 中 | 遞迴掃描所有 .tscn 的 connection + .gd 的 `connect()` | **P1** |
| **Impact check** | 中 | 反向依賴圖 + 變更擴散分析 | **P1** |
| **AnimationTree** | 高 | StateMachine + BlendTree 的圖狀結構操作 | **P2** |
| **C# compile-check** | 中 | `dotnet build` + 結構化錯誤解析 | **P1** — 見 [../08-CSharp-Support/](../08-CSharp-Support/) |

### 3.3 「真的很難」的功能

| 功能 | 難度 | 為什麼難 | 建議優先級 |
|------|------|----------|-----------|
| **Screenshot diff（視覺回歸）** | 高 | 需像素比對 + tolerance + baseline 管理 + CI 整合 | **P2** |
| **Assert framework** | 高 | 需在遊戲進程內執行條件判斷 + 結構化回報 | **P1** |
| **Trace flow（執行流追蹤）** | 高 | 需靜態分析 + 動態插樁 + 跨檔案追蹤 | **P3** |
| **Automated test scenarios** | 高 | 需場景描述語言 + 自動生成 + 執行 + 驗證 | **P2** |

---

## 4. 論壇開發者渴望的功能

來源：Godot Forum、GitHub Issues、Reddit、DEV Community。

### 4.1 高頻需求（多個來源重複提及）

| 需求 | 來源 | Open Godot MCP 現狀 | 建議 |
|------|------|---------------------|------|
| **Input simulation（AI 能玩遊戲）** | Coding-Solo #68, Godot MCP Pro blog, Beckett | ✅ 已有 | — |
| **Runtime scene tree（AI 看活遊戲）** | Coding-Solo #57, tomyud1 v0.5.0 | ✅ 已有 | — |
| **Screenshot capture** | 幾乎所有 MCP | ✅ 已有 | — |
| **Undo/Redo（Ctrl+Z AI 操作）** | satelliteoflove #166, Farraskuy, Godot MCP Pro | ❌ **缺** | **P0** |
| **Signal connect/disconnect** | Farraskuy, ReDev1L, yurineko73 | ❌ **缺** | **P0** |
| **Script attach to node** | Coding-Solo #57 | ⚠️ 有 attach | 確認完整性 |
| **Set main scene** | Coding-Solo #57 | ⚠️ 有 project settings | 確認 |
| **Batch node creation** | satelliteoflove #166 | ❌ **缺** | **P1** |
| **DAP debugging（breakpoint + step）** | rosskarchner, TransitionMatrix, Godot MCP Pro | ⚠️ 有 sessions | **P1** — 擴充 |
| **C# support** | tugcantopaloglu, IvanMurzak, LuoxuanLove, LeanderM99 | ❌ **缺** | **P1** — 見 [../08-CSharp-Support/](../08-CSharp-Support/) |
| **Assert / verification** | Beckett, godot-ai-playtest, Stagehand | ❌ **缺** | **P1** |
| **Visual regression（screenshot diff）** | Stagehand, godot-ai-playtest, Beckett | ❌ **缺** | **P2** |
| **Input recording/replay** | Godot MCP Pro, Farraskuy, Beckett | ❌ **缺** | **P1** |
| **Code analysis（unused resources, signal map）** | GodotIQ Pro, Godot MCP Pro | ❌ **缺** | **P1** |

### 4.2 中頻需求

| 需求 | 來源 | 建議 |
|------|------|------|
| **3D scene building** | Godot MCP Pro, tugcantopaloglu | P2 |
| **Navigation mesh bake** | Godot MCP Pro, tugcantopaloglu | P2 |
| **Shader editing** | Godot MCP Pro, tugcantopaloglu | P1 |
| **AnimationTree** | Godot MCP Pro, Farraskuy | P2 |
| **Audio control** | Godot MCP Pro, tugcantopaloglu | P2 |
| **Theme/UI overrides** | Farraskuy | P2 |
| **Particles** | Godot MCP Pro, Farraskuy | P2 |
| **Physics collision setup** | Godot MCP Pro, tugcantopaloglu | P2 |
| **MCP Resources & Prompts** | Beckett, rosskarchner, koltyakov | P1 |
| **Effort slider（tool 數量控制）** | Beckett, Godot MCP Pro | P2 |
| **Audit log** | Beckett | P2 |

### 4.3 低頻但有趣的需求

| 需求 | 來源 | 說明 |
|------|------|------|
| **CSG 操作** | tugcantopaloglu | 建構式實體幾何 |
| **MultiMesh instancing** | tugcantopaloglu | 大量實例渲染 |
| **Procedural mesh** | tugcantopaloglu | 頂點陣列生成網格 |
| **Editor UI 自動化** | LuoxuanLove | 點擊 editor 控件、座標映射 |
| **Git 整合** | Roadmap Phase 6 | 版本控制整合 |
| **CI/CD 整合** | Stagehand, godot-ai-playtest | GitHub Actions 跑 playtest |

---

## 5. Open Godot MCP 的缺口分析

### 5.1 「必須補」的缺口（用戶期望但沒有）

| # | 缺口 | 影響 | 難度 | 建議 Phase |
|---|------|------|------|-----------|
| G1 | **Undo/Redo** | AI 改了場景無法 Ctrl+Z，用戶不敢讓 AI 大改 | 中 | 立即 |
| G2 | **Signal connect/disconnect** | 場景編輯基本操作，沒有等於半殘 | 低 | 立即 |
| G3 | **Node groups 操作** | 場景邏輯常用 | 低 | 立即 |
| G4 | **Batch node creation** | AI 建場景要逐個 create，token 浪費 | 低 | 短期 |
| G5 | **Assert/verification** | playtest loop 缺驗證環節 | 高 | 短期 |
| G6 | **Input recording/replay** | 確定性回歸測試缺基礎 | 中 | 短期 |
| G7 | **DAP breakpoint + step** | 有 sessions 但不能實際 debug | 中 | 短期 |
| G8 | **C# compile-check** | .NET 用戶完全無法用 | 中 | 短期 |

### 5.2 「應該補」的缺口（競品都有）

| # | 缺口 | 影響 | 難度 | 建議 Phase |
|---|------|------|------|-----------|
| G9 | **Shader create/edit** | 無法 AI 生成 shader | 中 | 中期 |
| G10 | **Resource .tres CRUD** | 只能 inspect 不能 create/edit | 低 | 中期 |
| G11 | **Code analysis（signal map, dependency graph）** | AI 無法理解專案結構 | 中 | 中期 |
| G12 | **MCP Resources & Prompts** | 缺 MCP 協議的完整公民權 | 低 | 中期 |
| G13 | **3D scene building** | 3D 遊戲完全無法操作 | 中 | 中期 |
| G14 | **Physics collision setup** | 需手動設定碰撞 | 中 | 中期 |
| G15 | **Navigation mesh bake** | 尋路功能無法 AI 操作 | 中 | 中期 |

### 5.3 「有了更好」的缺口（差異化）

| # | 缺口 | 影響 | 難度 | 建議 Phase |
|---|------|------|------|-----------|
| G16 | **Screenshot diff（視覺回歸）** | 自動捕捉 UI 回歸 | 高 | 長期 |
| G17 | **AnimationTree 操作** | 複雜動畫狀態機 | 高 | 長期 |
| G18 | **Audio control** | 音效測試 | 低 | 長期 |
| G19 | **Theme/UI overrides** | UI 主題操作 | 低 | 長期 |
| G20 | **Particles** | 視覺特效 | 低 | 長期 |
| G21 | **Effort slider** | token 控制 | 低 | 長期 |
| G22 | **Audit log** | 安全審計 | 低 | 長期 |

### 5.4 Open Godot MCP 的獨有優勢（競品沒有）

| 優勢 | 說明 |
|------|------|
| **確定性 playtesting** | freeze/step/step_until — 只有 satelliteoflove 有類似功能 |
| **網路條件注入** | latency/loss/jitter — 所有競品都缺 |
| **多實例 multiplayer 測試** | host/client 實例管理 — 所有競品都缺 |
| **Editor + Game 雙通道** | editor 進程和 game 進程獨立通訊 |
| **Token 效率設計** | digest/摘要/diff — 多數端品工具數多但 token 重 |
| **MIT 完全免費** | 無 freemium、無 license key |

---

## 6. 結論：付費功能真的值得付費嗎？

### 6.1 值得付費的（如果不想自己做的話）

1. **Undo/Redo** — 每個付費 MCP 都有，用戶期望基本功能。但實作不難（`EditorUndoRedoManager`）。
2. **Assert/verification + Screenshot diff** — Beckett Full 的核心賣點。playtest loop 的最後一塊拼圖。實作較難但價值極高。
3. **C# support** — 多個付費 MCP 賣這個。.NET 用戶剛需。實作中等。
4. **Code analysis（signal map, dependency graph）** — GodotIQ Pro 的核心。靜態分析不需活引擎。實作中等。

### 6.2 不值得付費的（自己做很快）

1. **Signal connect/disconnect** — 一行 `node.connect()`，10 分鐘實作。
2. **Node groups** — `add_to_group()` / `get_groups()`，10 分鐘。
3. **Resource .tres CRUD** — `ResourceSaver.save()`，30 分鐘。
4. **Audio control** — `AudioStreamPlayer.play()`，30 分鐘。
5. **Theme/UI overrides** — `add_theme_override()`，30 分鐘。
6. **Shader create/edit** — 文件讀寫 + `ShaderMaterial`，1 小時。
7. **Project summary** — 遞迴掃描，1 小時。
8. **Effort slider** — 動態過濾 tools/list，1 小時。

### 6.3 Open Godot MCP 的策略

**不賣功能，賣穩定 + 確定性 + 網路測試。**

Open Godot MCP 的差異化不在工具數量（175 vs 36），而在：
1. **確定性 playtesting** — 凍結時鐘、精確步進、條件等待
2. **網路測試** — 多實例 + 網路條件注入（獨有）
3. **連線穩定** — 心跳、重連、port 避讓
4. **Token 效率** — digest/摘要/diff 設計

**建議補的優先級**：
1. **立即**：Undo/Redo（G1）+ Signal connect（G2）+ Node groups（G3）
2. **短期**：Batch creation（G4）+ Assert（G5）+ Input replay（G6）+ DAP擴充（G7）+ C# check（G8）
3. **中期**：Shader（G9）+ Resource CRUD（G10）+ Code analysis（G11）+ MCP Resources（G12）+ 3D/Physics/Nav（G13-G15）
4. **長期**：Screenshot diff（G16）+ AnimationTree（G17）+ Audio/Theme/Particles（G18-G20）

---

## 參考來源

- [Godot MCP Pro](https://y1uda.itch.io/godot-mcp-pro) — $15, 175 tools
- [GodotIQ FAQ](https://godotiq.com/reference/faq/) — $19, 14 Pro tools
- [Beckett](https://beckettlabs.itch.io/beckett-godot-mcp) — $15, Lite vs Full
- [StraySpark](https://www.strayspark.studio/products/godot-mcp-server) — $32-$96, 131 tools
- [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp) — 4.8k stars, 免費
- [tomyud1/godot-mcp](https://github.com/tomyud1/godot-mcp) — 免費, 42 tools
- [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp) — 確定性 playtesting
- [Farraskuy/Godot-MCP](https://github.com/Farraskuy/Godot-MCP) — 168 tools, 25 categories
- [tugcantopaloglu/godot-mcp](https://github.com/tugcantopaloglu/godot-mcp) — 157 tools, C# support
- [yurineko73/Godot-MCP-Native](https://github.com/yurineko73/Godot-MCP-Native) — 155 tools, 純 GDScript
- [TransitionMatrix/godot-dap-mcp-server](https://github.com/TransitionMatrix/godot-dap-mcp-server) — DAP debugging
- [marcushale/godot-ai-playtest](https://github.com/marcushale/godot-ai-playtest) — 外部 TCP 控制
- [mrf/godot-stagehand](https://github.com/mrf/godot-stagehand) — Playwright for Godot
- [Erodenn/godot-mcp-runtime](https://github.com/Erodenn/godot-mcp-runtime) — zero-footprint
- [Godot Forum: MCP Pro](https://forum.godotengine.org/t/godot-mcp-pro-162-tools-for-ai-powered-godot-development/135467)
- [Godot Forum: Free MCP](https://forum.godotengine.org/t/godot-free-open-source-mcp-server-addon/133890)
- [Godot Forum: Beckett](https://forum.godotengine.org/t/beckett-zero-sidecar-mcp-server-for-godot-4-2-the-ai-sees-and-optionally-playtests-your-game/141177)
- [GitHub: ACP support proposal](https://github.com/godotengine/godot-proposals/discussions/14918)
- [DEV.to: I Built a Godot MCP Server](https://dev.to/y1uda/i-built-a-godot-mcp-server-because-existing-ones-couldnt-let-ai-test-my-game-47dl)
- [Summer Engine: What Is Godot MCP](https://www.summerengine.com/blog/what-is-godot-mcp)
