# Changelog

All notable changes to Open Godot MCP are documented here.
One entry per release. Version truth = git history + this file.

## [0.1.10] — 2026-07-23

### Fixed

- **Client 連線 ENet port 自動解析**：client role 啟動時，`args.connect_to` 帶的 port 原本是 MCP WS port（例如 `127.0.0.1:7070`），但遊戲需要連的是 ENet port（例如 `8910`）。現在自動從 `Data/CSV/game_settings.csv` 讀取 `network,default_port` 的值，取代 `connect_to` 的 port，讓遊戲連到正確的 ENet 伺服器。若 `game_settings.csv` 不存在或無對應 row，則沿用原 `connect_to`（遊戲內建預設 port）。

### Tests

- 新增 3 個測試：`_read_enet_port` 找到 port、檔案不存在回 `None`、row 不存在回 `None`。

## [0.1.9] — 2026-07-23

### Added

- **遊戲實體路由（Game Instance Routing）**：當透過 `godot_network switch` 切換到獨立遊戲行程時，runtime 類工具（`godot_exec`、`godot_game`、`godot_game_time`、`godot_input`、`godot_runtime_state`、`godot_screenshot`、`godot_profiler`、`godot_log`）自動路由到該遊戲行程，而非編輯器的 PIE。編輯器專屬工具（`godot_editor_read`、`godot_scene`、`godot_node_read`、`godot_script`、`godot_project`）仍走編輯器 bridge，互不干擾。明確指定 `instance_id` 時優先於 active instance。
- **`godot_network switch` 支援 `editor`**：傳入 `instance_id="editor"`（或空字串）可清除 active game instance，讓 runtime 工具回退到編輯器。
- **`GameInstanceManager.clear_active()`**：新增 API 清除 active game instance。
- **Runtime autoload 新增 `play` / `stop` / `status` 方法**：standalone runtime 可回報 `runtime_ready`、`is_playing`、`runtime_connected`、`fps`，並支援停止行程。

### Tests

- 新增 `tests/test_game_instance_routing.py`（8 個測試）：涵蓋 runtime 工具集定義、路由到 active game instance、編輯器工具不路由、無 game instance 時回退編輯器、明確 `instance_id` 覆寫、`clear_active()` 行為、`switch editor` 清除 active。

## [0.1.8] — 2026-07-22

### Fixed

- **Dock 極窄裁切根因修正**：CheckButton/Button 的文字有不可壓縮的最小寬度，長文字（如「視覺（看圖，base64 直傳）」）強迫 VBox 至其最小寬度，dock 縮到最窄時右邊被裁掉約一個中文字元。`_ready()` 遞迴設所有 Button/CheckButton/OptionButton 的 `text_overrun_behavior = OVERRUN_TRIM_ELLIPSIS`，允許按鈕縮到文字寬度以下並顯示「…」而非硬裁切。
- **截圖清理區排列改善**：從 HBoxContainer（Label + SpinBox 同行）改為 VBoxContainer（Label 在上、SpinBox 在下），SpinBox 取得完整列寬，不再跟 Label 搶水平空間。

### Changed

- **.gitignore 補充**：新增 coverage/profiling（`.coverage`、`htmlcov/`、`coverage.xml`、`*.prof`）、Jupyter（`.ipynb_checkpoints/`）、type stubs（`.pytype/`）、Poetry/Pipfile lock、Windows shortcuts（`*.lnk`）、Godot export temp（`*.tmp.scn`、`*.tmp.tscn`）等開源專案常見排除項。

## [0.1.7] — 2026-07-22

### Fixed

- **Dock 縮窄裁切修正**：截圖清理區原本把「最大保留數 Label + SpinBox + 最大保留時數 Label + SpinBox」4 個元件塞在同一行 HBoxContainer，dock 寬度縮小時最小寬度超過容器導致右側被裁切（`horizontal_scroll_mode = 0` disabled + `clip_contents = true`）。改為拆成兩行，每行只有 Label + SpinBox，最小寬度減半。Label 加 `autowrap_mode = 3` + `size_flags_horizontal = 3`（expand fill），縮窄時文字自動換行不溢出。

## [0.1.6] — 2026-07-22

### Added

- **截圖清理 UI**：Dock 面板新增截圖自動清理設定區（最大保留數 SpinBox + 最大保留時數 SpinBox），直接在 Godot 編輯器內調整，不再需要手動改 ProjectSettings。設定存於 ProjectSettings（per-project）。
- **專案級設定檔**：Dock 面板新增「設定檔位置」區，含「使用專案級設定檔」勾選框。勾選後 Agnes/NVIDIA API 設定檔存於 `<專案根目錄>/.open_godot_mcp/config.json` 而非使用者家目錄，支援不同專案使用不同 API key。Dock 透過 `agnes_config_changed` 事件將路徑傳給 Python server，server 動態切換讀取位置。

### Changed

- **Dock tab 名稱**：`McpDock` → `OpenGodot`，更直觀。
- `context.py`：`on_agnes_config_event` 和 `sync_agnes_tools` 支援 `config_path` 參數，接受 dock 傳來的自訂路徑。
- i18n 新增 7 個 key（`screenshot_section`、`screenshot_max_count`、`screenshot_max_age`、`config_location_section`、`project_config_enable`、`config_path_label`、`config_dir_help_project`），20 語言全部重新生成。

## [0.1.5] — 2026-07-22

### Added

- **行程生命週期管理**：解決 Windows 上 MCP server 孤兒行程無限累積的問題（每次 MCP client crash/重啟就漏一個行程，像病毒一樣越開越多）。
  - **Parent watchdog**：server 啟動時起一個 daemon thread，每 5 秒檢查 parent 行程是否存活。parent 死了 → 立即 self-exit。Linux/macOS 靠 stdin EOF 自然退出，Windows 的 inherited handle 不會關閉，需要這個 watchdog 才能清理孤兒。
  - **`--shutdown-all` CLI 命令**：`open-godot-mcp --shutdown-all` 終止所有執行中的 `open-godot-mcp` 行程（不含自己）。更新前跑一次即可解鎖 `.exe`，不再需要手動工作管理員或重開電腦。
  - 新增 `src/open_godot_mcp/lifecycle.py`：parent 存活檢查（跨平台）、watchdog thread、`shutdown_all_instances()`。

### Changed

- **版本號單一真相來源**：`__init__.py` 改用 `importlib.metadata.version()` 從 pyproject.toml 讀取，`__main__.py`、`context.py`、`bridge.py` 全部引用 `__version__`。不再需要手動同步 4 個檔案的版號。
- `.gitignore` 補完開源專案常見排除：`.env`、`*.log`、`.idea/`、`.vscode/`、編輯器暫存、自我更新殘留檔（`*.update_backup`、`*.ogm_update_tmp`）。

## [0.1.4] — 2026-07-22

### Added

- **截圖自動清理**：解決截圖無限累積導致專案垃圾檔越來越多的問題。三層清理機制：
  - **自動輪轉**：每次 `game` / `editor` / `region` / `burst` 存檔後，自動刪除最舊截圖，只保留最近 N 張（預設 50，可設定）。
  - **過期淘汰**：刪除超過指定時長的舊截圖（預設 24 小時，依檔案修改時間）。
  - **手動 `cleanup` action**：`godot_screenshot cleanup` 可隨時主動清理，支援 `max_count` / `max_age_hours` 參數覆蓋預設。
  - 兩個 ProjectSettings 設定項：`open_godot_mcp/screenshot_max_count`（預設 50）、`open_godot_mcp/screenshot_max_age_hours`（預設 24），可在 Godot 專案設定介面調整。
  - 新增共用工具 `addons/open_godot_mcp/utils/screenshot_cleanup.gd`，editor handler 和 runtime autoload 共用。

### Changed

- `.gitignore` 補完 Python 工具 cache 和 build artifact 排除規則（`.pytest_cache/`、`.ruff_cache/`、`.mypy_cache/`、`*.egg-info/`、`build/`、`dist/`）。

## [0.1.3] — 2026-07-22

### Added

- **Agnes / NVIDIA API 整合（動態註冊工具）**：5 個新工具，預設關閉，需在 dock 面板手動啟用 + 填 API key + 勾選子功能才會註冊。未啟用時 AI 工具清單完全看不到，防止 AI 在本身已有視覺能力時誤用低階視覺。
  - `agnes_vision` — Agnes 2.0 Flash 視覺（URL-only，本地檔自動上傳 uguu.se）
  - `agnes_image_generate` — Agnes Image 2.0 Flash 文生圖/圖生圖（免費）
  - `agnes_video_generate` — Agnes Video V2.0 產影片（非同步任務，免費）
  - `nvidia_vision` — NVIDIA NIM VLM 視覺（base64 直傳，免上傳）
  - `nvidia_image_generate` — NVIDIA FLUX.2-klein-4b 產圖（免費）
  - Config 存於 `~/.open_godot_mcp/config.json`（user home，不在 git repo 內）
  - **API key 輪換**：`api_keys` 支援多 key（陣列）。429/402/401 時自動換下一個 key 重試，所有 key 耗盡才 backoff。向後相容舊 `api_key`（單字串）。dock 面板用 TextEdit 一行一 key。
  - 熱重載：dock 存檔 → bridge event `agnes_config_changed` → MCP server 動態 `add_tool`/`remove_tool`
  - 限流處理：429/402/401 換 key 重試；所有 key 耗盡 → backoff [2,4,8]s 最多 3 輪；403 `PERMISSION_DENIED` 不輪換不重試
  - **5xx 自動重試**：500/502/503/504/524 歸類為 `SERVER_ERROR`，backoff [2,4,8]s 重試最多 3 次（依 Agnes 官方文檔 §503「Retry later」建議）。不換 key（server error 非 key 問題）。
  - git 安全檢查：config 路徑在 git repo 內且未被 .gitignore 排除時，dock 顯示橘色警告（不自動修改 .gitignore）
  - 詳見 [Docs/02-Tools/Agnes-NVIDIA.md](Docs/02-Tools/Agnes-NVIDIA.md)
- **Dock i18n**：20 種語言選擇器（對齊 README 翻譯清單）。語言存於 EditorSettings `open_godot_mcp/ui/language`，預設 `en`。翻譯檔由 `scripts/gen_dock_i18n.py` 從單一來源 dict 生成。
- **新錯誤碼**：`QUOTA_EXHAUSTED`、`AUTH_FAILED`、`API_ERROR`、`SERVER_ERROR`、`UPLOAD_FAILED`（用於 Agnes/NVIDIA 工具）。

### Changed

- **Dock 面板重構**：移除 Settings 按鈕（原僅 print 無實際 UI）、View Log 按鈕（低價值 dump）。保留 Reconnect、Update banner。新增語言選擇器、Agnes/NVIDIA API 區塊、git 安全警告、MCP 未連線提示。
- `tests/test_server.py`：改用 fixture 隔離 config 路徑（避免測試碰觸真實 user config）；新增 `test_agnes_nvidia_not_registered_by_default` 驗證預設關閉。
- **清理 git repo**：移除 ~500 個 AHD（Agent Harness Deploy）harness 檔案（`.agents/`、`.devin/`、`.codex/`、`.hermes/`、`.windsurf/`、`AGENTS.md`）和 `plans/` 內部規劃文件。這些是個人 AI 工具鏈設定，非開源產品一部分。`.gitignore` 新增對應排除規則 + secrets 排除（`**/config.json`、`**/api_keys.json`）。

### Internal

- `agnes_config.py`：config 載入/儲存/路徑解析/git 安全檢查（user-home 路徑、chmod 600、deep-merge defaults）。
- `context.py`：`ServerContext` 加 `_mcp` ref + `_registered_agnes_tools` set + `sync_agnes_tools()` 動態註冊 + `on_agnes_config_event()` bridge event handler。
- `tools/agnes.py`、`tools/nvidia.py`：工具實作 + uguu.se 上傳 helper + 限流處理 + 5xx 重試。
- FastMCP 3.x 相容：`remove_tool` 改用 `mcp.local_provider.remove_tool`（top-level 已 deprecated）。

## [0.1.2] — 2026-07-21

### Fixed

- **bridge 重連不再永久放棄**：slow-stream + on-demand reconnect + 連線鎖，避免一次性斷線後整個 session 失效。
- **TileMap → TileMapLayer 遷移**：Godot 4.3+ 起 TileMapLayer 為唯一支援節點，TileMap 自 4.3 deprecated、4.7 移除。
  - `tilemap_handler.gd` 改用 `get_class()` 字串比對偵測節點型別，避免 4.7+ 直接引用 TileMap 造成 parse error。
  - 舊 TileMap 節點（4.3 以前專案）透過動態分派向後相容。
  - 錯誤訊息由 "TileMap not found" 改為 "TileMapLayer not found" 並提示遷移。

### Changed

- **MCP tool description caveman 壓縮**：25 個 `tools/*.py` 的 description 由長句壓縮為動作清單，降低 MCP client 介面 token 消耗（符合 caveman protocol）。
- `tests/test_server.py`：expected tool 數 30 → 31，補 `godot_csharp_check` 對齊實際註冊清單。

### Internal

- AHD canon 同步：MEMORY_PROTOCOL 新增 context moat 五類別篩選、REDLINES #18 五問存在門、VERIFICATION_PROTOCOL 補強、HARNESS_ENGINEERING 增補「更強模型 → 雙分岔 harness」論述。同步至 `.codex/.devin/.hermes/.windsurf` 各 sink。

## [0.1.1] — 2026-07-18

### Added

- **自動更新通知**：啟動時查詢 GitHub Releases API，偵測新版顯示 "Update available: vX.Y.Z" banner，提供 Update 與 Release notes 連結。
- **一鍵更新**：下載 → SHA-256 驗證 → 停用舊插件 → 解壓（含備份 + 回滾）→ 檔案系統掃描 → 重新啟用。
- **安全設計**：URL 信任驗證（只從 `github.com/masteryee-labs/Open-Godot-MCP/releases/download/` 下載）、zip slip 防護、混合狀態偵測 + 回滾。
- `addons/open_godot_mcp/utils/update_manager.gd`、`update_reload_runner.gd`。
- `.github/workflows/release.yml`：release 發布時自動建構 ZIP + SHA256。

### Fixed

- **MCP 面板 UI 溢出**：`ScrollContainer` 包裹 + Label `autowrap_mode` + Button `SIZE_EXPAND_FILL`，視窗縮小時不再溢出。

## [0.1.0] — 2026-07-18

### Added

- 首次發布。開源 Model Context Protocol server，讓 AI 程式助手自主開發、測試、除錯 Godot 遊戲。
- ~30 MCP tools、~130 actions：編輯器 / 場景 / 節點 / 腳本 / 資源 / 遊戲控制 / 時鐘 / 輸入 / 狀態注入 / DAP 除錯 / LSP / 效能 / 測試 / 連線遊戲 / 多實例 / 檔案系統 / 文件 / 日誌 / 批次 / 資產 / 匯出 / 健康檢查。
- **確定性 Playtesting**：freeze / step / step_until + JSON state digest。
- **連線遊戲測試**（獨有）：多實例啟動、peer 模擬、網路條件注入、同步狀態驗證。
- **Token 效率**：JSON state digest 取代截圖、diff 回傳、截圖壓縮、read/write 分離、批次操作。
- **連線穩定**：可配置 port、Windows Port Reservation 偵測、心跳、指數退避重連。
- 20 語言 README + SEO/AEO/GEO/LLMO 優化。
