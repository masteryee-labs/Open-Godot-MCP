# Connection Stability — 連線穩定設計

> 解決現有 MCP「時常連線不到」的核心改進。本檔獨立於協議（見 [Transport.md](Transport.md)）——穩定機制是疊加在通道 2 上的層。

---

## 問題根因分析

從 [tomyud1/godot-mcp](https://github.com/tomyud1/godot-mcp) 原始碼發現的連線不穩根因（用戶反映「時常連線不到」）：

| 根因 | 位置 | 影響 |
|------|------|------|
| 硬編碼 port 6505 | `mcp_client.gd:13` | 其他服務佔用即失敗，無法調整 |
| 無心跳機制 | `mcp_client.gd:137` | 死連線無法偵測，一直以為還連著 |
| 重連退避過長（最高 10s） | `mcp_client.gd:15` | server 重啟後要等數秒 |
| 連線失敗只 print | `mcp_client.gd:92` | 使用者不知道 server 沒啟動 |
| 無 port 衝突偵測 | 全域 | WSL2/Hyper-V/Docker 保留 port 會靜默失敗 |

---

## 對策 1：可配置 port（三層覆蓋）

```
優先序：環境變數 > EditorSettings > 自動避讓 > 預設
```

- **環境變數**：`OPEN_GODOT_MCP_PORT=7000`
- **EditorSettings**：`open_godot_mcp/bridge/port`（GUI 可調）
- **自動避讓**：偵測到預設 port 被佔用時，自動找下一個可用 port
- **預設**：6970（避開常見衝突範圍）

---

## 對策 2：Windows Port Reservation 偵測

借鏡 [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) 的 `windows_port_reservation.gd`：

- 啟動前讀取 `netsh interface ipv4 show excludedportrange protocol=tcp`
- 跳過 Hyper-V / WSL2 / Docker Desktop 保留的 port 範圍
- 若預設 port 落在保留範圍，自動避讓並通知使用者

---

## 對策 3：心跳機制

```
每 5 秒：Server → Bridge 發 ping
3 秒內無 pong → 標記 suspected_dead
連續 3 次 suspected_dead → 斷線，觸發重連
```

- 主動偵測死連線，不靠被動 ping/pong
- 死連線在使用者察覺前就被處理

---

## 對策 4：智慧重連

```
退避序列：1s, 2s, 4s, 8s, 16s, 30s（上限）
最大重連次數：20（到達後停止，通知使用者檢查 server）
重連成功：重置退避序列
```

- 指數退避避免狂連
- 有上限避免無限循環（godot-ai 的缺陷）
- 到達上限時通知使用者，不靜默失敗

---

## 對策 5：連線狀態 UI

Editor dock 面板顯示：

```
┌─────────────────────────────────┐
│ Open Godot MCP                  │
│                                 │
│ 狀態：● 已連線 (port 6970)       │
│ Server：v0.1.0                  │
│ 遊戲：未執行                     │
│                                 │
│ [重連] [設定 port] [查看日誌]    │
└─────────────────────────────────┘
```

- 使用者隨時看到連線狀態
- 斷線時面板變紅，顯示原因
- 可手動重連、改 port

---

## 封包與背壓控制

借鏡 godot-ai 的 backpressure 設計：

| 機制 | 值 | 用途 |
|------|----|------|
| Outbound buffer limit | 4 MB | 超過則拒絕發送，回傳錯誤（避免記憶體爆炸） |
| Packet drain cap per tick | 32 | 每幀最多處理 32 封包（避免單幀卡頓） |
| Screenshot max size | 2 MB | 超過自動降解析度 |
| Scene tree response limit | 500 節點 | 超過要求分頁 |

---

## 相關文件

- [Transport.md](Transport.md) — 協議本身
- [Multi-Instance.md](Multi-Instance.md) — 多實例 port 隔離
- [../06-Installation/Troubleshooting.md](../06-Installation/Troubleshooting.md) — 連線疑難排解
