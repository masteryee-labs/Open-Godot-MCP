# Architecture — 整體架構

> 三層分離、技術選型、目錄結構。本檔描述靜態結構，不涉及協議細節（見 [Transport.md](Transport.md)）或連線穩定（見 [Connection-Stability.md](Connection-Stability.md)）。

---

## 三層架構

```
┌─────────────────┐     stdio     ┌─────────────────────┐  WebSocket   ┌──────────────────────┐
│   AI Client     │ ◄───────────► │  MCP Server         │ ◄──────────► │  Editor Bridge       │
│  (Claude, etc.) │   MCP protocol│  (Python, FastMCP)  │  :6970       │  (GDScript EditorPlugin)│
└─────────────────┘               └─────────────────────┘              └──────────────────────┘
                                         │                                      │
                                         │ TCP (DAP)                            │ debugger wire
                                         ▼                                      ▼
                                  ┌──────────────┐                   ┌──────────────────────┐
                                  │  Godot DAP   │                   │  Running Game        │
                                  │  (內建)       │                   │  (autoload, 可選)     │
                                  └──────────────┘                   └──────────────────────┘
                                         │
                                         │ TCP (LSP)
                                         ▼
                                  ┌──────────────┐
                                  │  Godot LSP   │
                                  │  (內建)       │
                                  └──────────────┘
```

## 三層分離

| 層 | 職責 | 技術 |
|----|------|------|
| **MCP Server** | 對 AI 暴露工具、資源、prompts；驗證輸入；路由到 bridge | Python + FastMCP，stdio transport |
| **Editor Bridge** | 在 Godot 編輯器內執行編輯操作；管理 runtime 連線 | GDScript EditorPlugin + WebSocket server |
| **Runtime Autoload** | 在遊戲進程內執行輸入模擬、狀態觀察、GDScript 注入 | GDScript autoload，透過 debugger channel 溝通 |

## 技術選型：為什麼選 Python + GDScript

| 選項 | 優點 | 缺點 | 決定 |
|------|------|------|------|
| Python (FastMCP) + GDScript | MCP 生態成熟、FastMCP 開發快、GDScript 原生存取 Godot API | 需 Python 環境 | **採用** |
| TypeScript (Node) + GDScript | Coding-Solo/satelliteoflove 用此方案、npm 生態大 | 需 Node.js、TS 型別維護成本 | 不採用 |
| 純 GDScript | 無外部依賴 | GDScript 不適合寫 MCP server、無 stdio transport 支援 | 不採用 |

Python 是因為：(1) FastMCP v3 是目前最成熟的 MCP server 框架；(2) GDScript 負責 Godot 端，Python 負責 MCP 協議，職責清晰。

> **C# Godot 相容性**：GDScript 寫的 Editor Bridge 能載入在 C# (mono) Godot 上，但腳本工具/LSP/runtime eval 需另外處理。詳見 [../08-CSharp-Support/Compatibility.md](../08-CSharp-Support/Compatibility.md)。

---

## 目錄結構（規劃）

```
Open-Godot-MCP/
├── README.md
├── LICENSE                          # MIT
├── pyproject.toml                   # Python 套件定義
├── src/
│   └── open_godot_mcp/              # MCP Server (Python)
│       ├── __init__.py
│       ├── server.py                # FastMCP server 入口
│       ├── bridge.py                # WebSocket client to Editor Bridge
│       ├── dap.py                   # DAP client
│       ├── lsp.py                   # LSP client
│       ├── instance_manager.py      # 多實例管理
│       ├── tools/                   # MCP 工具定義
│       │   ├── editor.py
│       │   ├── scene.py
│       │   ├── node.py
│       │   ├── script.py
│       │   ├── project.py           # godot_project + godot_input_map
│       │   ├── resource.py          # godot_resource + godot_animation + godot_tilemap
│       │   ├── input.py
│       │   ├── game.py              # godot_game + godot_game_time
│       │   ├── runtime_state.py     # godot_runtime_state + godot_exec
│       │   ├── screenshot.py
│       │   ├── debugger.py          # DAP 工具
│       │   ├── lsp.py               # LSP 工具
│       │   ├── profiler.py
│       │   ├── test.py
│       │   ├── network.py           # 連線遊戲測試
│       │   ├── instance.py          # 編輯器實例管理
│       │   ├── filesystem.py        # godot_filesystem + godot_docs + godot_log
│       │   ├── utility.py           # godot_batch + godot_asset + godot_export + godot_health
│       │   └── ...                  # 按需擴展
│       ├── resources/               # MCP resources
│       └── prompts/                 # MCP prompts
├── addons/
│   └── open_godot_mcp/              # Godot addon (GDScript)
│       ├── plugin.cfg
│       ├── plugin.gd                # EditorPlugin 入口
│       ├── bridge/
│       │   ├── websocket_server.gd  # WebSocket server
│       │   ├── connection.gd        # 連線管理 + 心跳 + 重連
│       │   └── dispatcher.gd        # 工具路由
│       ├── handlers/                # 編輯器操作 handlers
│       │   ├── editor_handler.gd
│       │   ├── scene_handler.gd
│       │   ├── node_handler.gd
│       │   ├── script_handler.gd
│       │   └── ...
│       ├── runtime/
│       │   ├── runtime_autoload.gd  # 遊戲進程 autoload
│       │   ├── input_simulator.gd
│       │   ├── state_observer.gd
│       │   ├── clock_controller.gd  # freeze/step
│       │   └── network_conditioner.gd  # 網路條件注入（延遲/丟包/抖動）
│       ├── debugger/
│       │   └── mcp_debugger_plugin.gd
│       ├── export/
│       │   └── mcp_export_plugin.gd  # 匯出時 strip runtime
│       ├── dock/
│       │   └── mcp_dock.gd           # 連線狀態 UI
│       └── utils/
│           ├── variant_codec.gd      # Variant 序列化
│           ├── port_resolver.gd      # port 衝突偵測
│           ├── windows_port_reservation.gd
│           └── error_codes.gd
├── tests/                           # 測試
├── Docs/                            # 本文件目錄
└── examples/                        # 範例專案
```

---

## 相關文件

- [Transport.md](Transport.md) — 4 條通訊通道的協議
- [Connection-Stability.md](Connection-Stability.md) — 連線穩定設計
- [Multi-Instance.md](Multi-Instance.md) — 多實例管理
- [Runtime-Autoload.md](Runtime-Autoload.md) — Runtime autoload 設計與啟動流程
