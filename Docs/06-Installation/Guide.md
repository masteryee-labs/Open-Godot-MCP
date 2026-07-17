# Installation — Guide

> Open Godot MCP 安裝與設定。疑難排解見 [Troubleshooting.md](Troubleshooting.md)。

---

## 系統需求

| 項目 | 需求 |
|------|------|
| Godot | 4.5+（addon 使用 4.5 的 Logger class） |
| Python | 3.11+ |
| uv | 推薦（或 pip） |
| AI Client | 任何支援 MCP stdio 的 client |

> **C# Godot**：需 mono build。相容性見 [../08-CSharp-Support/Compatibility.md](../08-CSharp-Support/Compatibility.md)。

---

## 安裝步驟

### 1. 安裝 MCP Server（Python）

#### 方式 A：從 PyPI 安裝（推薦）

```bash
uv tool install open-godot-mcp
# 或
pip install open-godot-mcp
```

#### 方式 B：從原始碼安裝

```bash
git clone https://github.com/masteryee-labs/Open-Godot-MCP.git
cd Open-Godot-MCP
uv venv && uv pip install -e .
```

#### 驗證

```bash
open-godot-mcp --version
# → open-godot-mcp 0.1.0
```

### 2. 安裝 Godot Addon

#### 方式 A：自動注入（推薦）

MCP Server 在首次連線時自動將 addon 注入到 Godot 專案。

#### 方式 B：手動安裝

1. 複製 `addons/open_godot_mcp/` 到你的 Godot 專案的 `addons/` 目錄
2. **Project > Project Settings > Plugins** 啟用「Open Godot MCP」
3. 重啟 Godot

#### 方式 C：透過 MCP Server

```bash
open-godot-mcp --install-addon /path/to/your/godot/project
```

### 3. 設定 AI Client

#### Claude Desktop

```json
{
  "mcpServers": {
    "open-godot-mcp": {"command": "open-godot-mcp"}
  }
}
```

#### Claude Code

```bash
claude mcp add open-godot-mcp -- open-godot-mcp
```

#### Cursor

`~/.cursor/mcp.json`：

```json
{
  "mcpServers": {
    "open-godot-mcp": {"command": "open-godot-mcp"}
  }
}
```

#### Codex / Codex CLI

`~/.codex/config.toml`：

```toml
[mcp_servers.open-godot-mcp]
command = "open-godot-mcp"
```

#### Devin / Devin CLI

`.devin/mcp.json`：

```json
{
  "mcpServers": {
    "open-godot-mcp": {"command": "open-godot-mcp"}
  }
}
```

#### 使用 uv run / uvx

```json
{"command": "uv", "args": ["run", "open-godot-mcp"]}
{"command": "uvx", "args": ["open-godot-mcp"]}
```

### 4. 驗證連線

1. 開啟 Godot 專案
2. 啟動 AI Client
3. 請 AI 執行 `godot_health check`

---

## 進階設定

### Port 設定

#### 環境變數

```bash
export OPEN_GODOT_MCP_PORT=7000
export OPEN_GODOT_MCP_DAP_PORT=6006
export OPEN_GODOT_MCP_LSP_PORT=6005
```

#### EditorSettings

**Editor > Editor Settings > Open Godot MCP**：

| 設定 | 預設 | 說明 |
|------|------|------|
| `bridge/port` | 6970 | Editor Bridge WebSocket port |
| `bridge/auto_port` | true | 衝突時自動避讓 |
| `bridge/heartbeat_interval` | 5 | 心跳間隔（秒） |
| `bridge/reconnect_max` | 20 | 最大重連次數 |
| `runtime/auto_inject` | true | 遊戲啟動時自動注入 runtime autoload |
| `runtime/strip_on_export` | true | 匯出時移除 runtime |
| `security/allow_eval` | true | 允許 `godot_exec eval` |
| `security/read_only` | false | 唯讀模式 |
| `security/auth_token` | "" | Bridge 連線驗證金鑰（空字串=不驗證；詳見 [../01-Architecture/Transport.md](../01-Architecture/Transport.md) §通道 2） |

### 唯讀模式

```bash
open-godot-mcp --read-only
```

### 安全設定

#### 停用 `godot_exec eval`

```bash
open-godot-mcp --no-eval
```

#### 限制可存取的路徑

```bash
open-godot-mcp --allowed-paths /home/user/project1,/home/user/project2
```

### WSL2 設定

```bash
export OPEN_GODOT_MCP_HOST_IP=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
open-godot-mcp --bridge-host $OPEN_GODOT_MCP_HOST_IP
```

---

## 多專案設定

```json
{
  "mcpServers": {
    "open-godot-mcp": {
      "command": "open-godot-mcp",
      "args": ["--projects", "/path/to/project1,/path/to/project2"]
    }
  }
}
```

---

## 解除安裝

### 移除 MCP Server

```bash
uv tool uninstall open-godot-mcp
```

### 移除 Godot Addon

1. Godot 專案設定內停用
2. 刪除 `addons/open_godot_mcp/`
3. 重啟 Godot
