# Installation — Troubleshooting

> 連線與安裝疑難排解。安裝步驟見 [Guide.md](Guide.md)。

---

## 連線失敗

### 症狀：`godot_health check` 回傳 `bridge_connected: false`

**排查步驟**：

1. **Addon 未啟用**
   - 確認 Godot 專案設定內 Open Godot MCP 已啟用
   - 重啟 Godot 編輯器

2. **Port 衝突**
   - 執行 `godot_health diagnostics` 查看 port 衝突
   - 設定不同 port：`export OPEN_GODOT_MCP_PORT=7000`

3. **Windows Port Reservation**
   - 執行 `netsh interface ipv4 show excludedportrange protocol=tcp`
   - 若預設 port 在保留範圍內，設定其他 port
   - 詳見 [../01-Architecture/Connection-Stability.md](../01-Architecture/Connection-Stability.md) §Windows Port Reservation

4. **防火牆**
   - 確認 localhost WebSocket 未被防火牆擋

5. **Python 環境**
   - 確認 `open-godot-mcp --version` 可執行
   - 確認 AI Client 的 `command` 路徑正確

### 症狀：Runtime 連不上

1. **遊戲未啟動**——`godot_game play` 啟動遊戲後 runtime 才會連線
2. **Autoload 未注入**——確認 `runtime/auto_inject = true`
3. **遊戲崩潰**——`godot_log get source="game"` 確認崩潰原因

---

## 截圖失敗

### 症狀：`godot_screenshot game` 回傳錯誤

1. **遊戲未啟動**——截圖需要遊戲在執行中
2. **Viewport 為空**——確認場景已載入
3. **磁碟空間不足**——截圖存檔需要磁碟空間

---

## 多實例衝突

### 症狀：第二個實例啟動失敗

1. **Port 衝突**——多實例自動分配 port，但若範圍被佔用會失敗
   - 設定不同起始 port：`export OPEN_GODOT_MCP_PORT=8000`
2. **資源不足**——每個 Godot 進程 ~200MB RAM

---

## C# Godot 特定問題

### 症狀：C# 專案的腳本工具/LSP 不工作

這是預期行為——GDScript 工具不適用於 C#。見 [../08-CSharp-Support/Compatibility.md](../08-CSharp-Support/Compatibility.md)。

### 症狀：`godot_exec eval` 在 C# 專案失敗

C# 是編譯式，不能 runtime eval。見 [../08-CSharp-Support/Compatibility.md](../08-CSharp-Support/Compatibility.md) §Runtime `eval`。
