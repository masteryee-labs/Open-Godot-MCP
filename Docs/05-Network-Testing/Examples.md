# Network Testing — Examples

> 5 個完整工作流範例。概念見 [Guide.md](Guide.md)。

---

## 範例 1：基本連線測試

```
AI: 我要測試 multiplayer 連線是否正常

1. godot_network launch_instance role="host" scene="res://arena.tscn"
   → {instance_id: "inst_1", game_port: 7070}

2. godot_network launch_instance role="client" args={"connect_to": "127.0.0.1:7070"}
   → {instance_id: "inst_2", game_port: 7080}

3. godot_network list_instances
   → 確認 inst_2 connected: true

4. godot_network sync_state instances=["inst_1", "inst_2"]
   → 確認 all_in_sync: true

5. godot_network terminate instance_id="inst_2"
   → 模擬 client 斷線

6. godot_network list_instances
   → 確認 inst_1 players 減少
```

---

## 範例 2：同步驗證

```
AI: 我要驗證玩家移動會正確同步到所有 client

1. godot_network launch_instance role="host" scene="res://arena.tscn"
2. godot_network launch_instance role="client" args={"connect_to": "127.0.0.1:7070"}

3. godot_network switch instance_id="inst_1"
4. godot_game play frozen=true
5. godot_game_time step ms=1000 inputs=[
     {type: "action", action: "move_right", pressed: true, at_ms: 0}
   ]

6. godot_network sync_state instances=["inst_1", "inst_2"]
   → 檢查 /root/Player1 在兩個實例的位置是否一致
   → 若 in_sync: false → 同步有問題，AI 診斷

7. godot_network switch instance_id="inst_2"
8. godot_runtime_state digest
   → 確認 client 端看到玩家移動
```

---

## 範例 3：網路條件測試

```
AI: 我要測試高延遲下的遊戲表現

1. 啟動 host + 2 個 client

2. godot_network network_condition instance_id="inst_2" latency_ms=300 loss_pct=10 jitter_ms=100
   → inst_2 模擬 300ms 延遲 + 10% 丟包

3. godot_network switch instance_id="inst_1"
4. godot_game play
5. godot_input action action="move_right" pressed=true
6. godot_runtime_state watch node_path="/root/Player1" property="position" duration_ms=3000
   → 觀察 host 上玩家位置

7. godot_network switch instance_id="inst_2"
8. godot_runtime_state watch node_path="/root/Player1" property="position" duration_ms=3000
   → 觀察高延遲 client 上玩家位置
   → 比較兩者，驗證延遲補償是否有效

9. godot_screenshot game instance_id="inst_2" max_width=1280 format="jpeg" quality=70
```

---

## 範例 4：斷線重連測試

```
AI: 我要測試玩家斷線後重連能恢復狀態

1. 啟動 host + client

2. godot_network switch instance_id="inst_2"
3. godot_exec eval code="Player.score = 500; Player.health = 80"

4. godot_network terminate instance_id="inst_2"
   → 模擬斷線

5. godot_network launch_instance role="client" args={"connect_to": "127.0.0.1:7070", "reconnect": true}
   → inst_3

6. godot_network switch instance_id="inst_3"
7. godot_runtime_state inspect node_path="/root/Player" properties=["score", "health"]
   → 確認 score=500, health=80（狀態恢復）
   → 若未恢復 → 重連邏輯有問題
```

---

## 範例 5：壓力測試

```
AI: 我要測試伺服器能承受 50 個玩家

1. godot_network launch_instance role="host" scene="res://arena.tscn"

2. godot_batch execute operations=[
     {tool: "godot_network", action: "simulate_peer", params: {instance_id: "inst_1", peer_config: {peer_id: 2, player_name: "Bot1"}}},
     {tool: "godot_network", action: "simulate_peer", params: {instance_id: "inst_1", peer_config: {peer_id: 3, player_name: "Bot2"}}},
     ...
     {tool: "godot_network", action: "simulate_peer", params: {instance_id: "inst_1", peer_config: {peer_id: 51, player_name: "Bot50"}}}
   ]

3. godot_profiler snapshot instance_id="inst_1"
   → {fps: 45, memory: 256MB, process_time: 12ms}
   → 50 個 peer 下 FPS 仍可接受

4. godot_runtime_state inspect node_path="/root/Server" properties=["player_count", "avg_latency"]
   → {player_count: 50, avg_latency: 45}
```
