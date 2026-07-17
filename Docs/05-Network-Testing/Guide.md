# Network Testing — Guide

> Open Godot MCP 獨有功能——連線遊戲測試。讓 AI 自主測試 multiplayer 遊戲的同步、延遲、斷線重連。

> 工具 API 見 [../02-Tools/Network.md](../02-Tools/Network.md)。
> 完整範例見 [Examples.md](Examples.md)。

---

## 問題

用戶反映的痛點：

> 「兩個 MCP 都有一個問題，就是如果要測連線遊戲的話，沒辦法測。」

所有現有 Godot MCP 都缺連線測試能力。Open Godot MCP 是唯一提供的。

---

## 多實例架構

```
┌─────────────────┐
│   MCP Server    │
│                 │
│  Instance Mgr   │
│   ├─ Host       │ → Godot 實例 1 (game port 7070)
│   ├─ Client 1   │ → Godot 實例 2 (game port 7080)
│   ├─ Client 2   │ → Godot 實例 3 (game port 7090)
│   └─ Client 3   │ → Godot 實例 4 (game port 7100)
│                 │
│  Network Cond.  │ ← 注入延遲/丟包/抖動
└─────────────────┘
```

每個實例是獨立的 Godot 進程，各自有獨立的 game multiplayer port（與 bridge port 分開，見 [../01-Architecture/Multi-Instance.md](../01-Architecture/Multi-Instance.md)）。MCP Server 統一管理。

---

## 網路條件注入

### 封包攔截

在 runtime autoload 內，透過自訂 `MultiplayerPeer` 包裝層攔截封包：

```gdscript
# runtime/network_conditioner.gd
extends Node

var _latency_ms: float = 0.0
var _loss_pct: float = 0.0
var _jitter_ms: float = 0.0
var _pending_packets: Array = []

func _process(delta):
    var now = Time.get_ticks_msec()
    var ready = []
    for i in range(_pending_packets.size() - 1, -1, -1):
        if _pending_packets[i].send_time <= now:
            ready.append(_pending_packets[i])
            _pending_packets.remove_at(i)
    for pkt in ready:
        _actual_send(pkt)

func intercept_send(packet, peer_id):
    if randf() < _loss_pct / 100.0:
        return  # 丟棄
    var delay = _latency_ms + randf_range(-_jitter_ms, _jitter_ms)
    _pending_packets.append({
        "packet": packet,
        "peer_id": peer_id,
        "send_time": Time.get_ticks_msec() + delay
    })
```

### 支援的網路條件

| 條件 | 參數 | 模擬 |
|------|------|------|
| 延遲 | `latency_ms` | 封包延遲 N ms 發送 |
| 丟包 | `loss_pct` | 隨機丟棄 N% 封包 |
| 抖動 | `jitter_ms` | 延遲隨機 ±N ms |
| 頻寬限制 | `bandwidth_kbps`（未來） | 限制封包大小/速率 |

---

## 與確定性 Playtesting 結合

連線測試也可用確定性模式。以下範例的 `instance_id` 是所有工具的可選參數（不指定則用作用中實例），見 [../01-Architecture/Multi-Instance.md](../01-Architecture/Multi-Instance.md)：

```
1. godot_network launch_instance role="host" scene="res://arena.tscn"
   → {instance_id: "inst_1", game_port: 7070}
2. godot_network launch_instance role="client" args={"connect_to": "127.0.0.1:7070"}

3. godot_game play frozen=true instance_id="inst_1"
4. godot_game play frozen=true instance_id="inst_2"

5. godot_game_time step ms=1000 inputs=[
     {type: "action", action: "move_right", pressed: true, at_ms: 0}
   ] instance_id="inst_1"

6. godot_game_time step ms=1000 instance_id="inst_2"

7. godot_network sync_state instances=["inst_1", "inst_2"]
   → 確定性比較同步狀態
```

> **確定性連線測試**：兩邊都 frozen，AI 精確控制時間推進，觀察同步在每個時間點的狀態。

---

## 限制

### 能做

- ✅ 多實例啟動（host + N client）
- ✅ 模擬 peer（不需完整 Godot 進程）
- ✅ 網路條件注入（延遲/丟包/抖動）
- ✅ 同步狀態比較
- ✅ RPC 傳播驗證
- ✅ 斷線重連測試
- ✅ 壓力測試
- ✅ 與確定性 playtesting 結合

### 不能做

- ❌ 測試真實跨網路連線（只在 localhost）——用 `network_condition` 模擬
- ❌ 測試 ENet/WebSocket 以外的自訂協議（除非遊戲自己支援）
- ❌ 模擬 NAT 穿透——需真實環境

### 注意

- 多實例會佔用較多系統資源（每個 Godot 進程 ~200MB RAM）
- `simulate_peer` 在 host 進程內模擬，不測試真實網路棧
- 網路條件注入只影響應用層封包，不模擬 TCP 重傳等底層行為
