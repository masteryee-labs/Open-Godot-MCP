# Changelog

All notable changes to Open Godot MCP are documented here.
One entry per release. Version truth = git history + this file.

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
