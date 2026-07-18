"""Register MCP Prompts (Docs/02-Tools/Index.md §MCP Prompts).

Prompts are guided workflows the AI can invoke. Each returns a string
of instructions tailored to the provided arguments.
"""

from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext


def register_prompts(mcp: FastMCP, ctx: ServerContext) -> None:
    @mcp.prompt()
    def playtest(scene: str = "", frozen: bool = True) -> str:
        """Complete deterministic playtest workflow.

        Args:
            scene: res:// path to test scene, or "" for current editor scene.
            frozen: Start with frozen clock (deterministic mode).
        """
        scene_arg = f'"{scene}"' if scene else ""
        mode = "frozen=true" if frozen else "frozen=false"
        return f"""# Deterministic Playtest Workflow

You are about to run a deterministic playtest of the game. Follow these steps:

1. **Start the game in deterministic mode**:
   ```
   godot_game play scene={scene_arg} {mode}
   ```
   Wait for runtime_ready=true. If false, poll godot_game status.

2. **Set up the test scene** (if needed):
   ```
   godot_exec eval code="Player.add_to_group('mcp_watch')"
   ```
   Use eval to grant items, skip to levels, spawn test entities.

3. **Step until a condition is met**:
   ```
   godot_game_time step_until condition="Player.is_on_floor()" timeout_ms=5000
   ```

4. **Observe state (cheap, no screenshot)**:
   ```
   godot_runtime_state digest
   ```
   Check positions, health, velocity via JSON — saves vision tokens.

5. **Inject input at precise times**:
   ```
   godot_game_time step ms=500 inputs=[
     {{type: "action", action: "move_right", pressed: true, at_ms: 0}},
     {{type: "action", action: "jump", pressed: true, at_ms: 200}}
   ]
   ```

6. **Verify the result**:
   ```
   godot_runtime_state digest
   ```
   Compare before/after to confirm the expected change occurred.

7. **Screenshot only if visual confirmation is needed**:
   ```
   godot_screenshot game max_width=1280 format="jpeg" quality=70
   ```

8. **Stop the game**:
   ```
   godot_game stop
   ```

**Key rules**:
- Always check `ok` field in responses.
- Use digest (JSON) over screenshots for logic bugs — saves 90% tokens.
- Mouse coordinates are ACTUAL window pixels — call godot_game status for viewport_size first.
- resume (pause system) != unfreeze (time_scale). Use unfreeze to exit deterministic mode.
"""

    @mcp.prompt()
    def debug_breakpoint(script: str, line: int, condition: str = "") -> str:
        """Breakpoint debugging workflow.

        Args:
            script: res:// path to the GDScript file.
            line: Line number (1-based) for the breakpoint.
            condition: Optional GDScript boolean expression (evaluated in local scope).
        """
        cond = f' condition="{condition}"' if condition else ""
        return f"""# Breakpoint Debugging Workflow

1. **Set the breakpoint**:
   ```
   godot_debugger set_breakpoint script_path="{script}" line={line}{cond}
   ```
   Condition is evaluated in LOCAL scope at the breakpoint (can access local vars and self).

2. **Start the game**:
   ```
   godot_game play
   ```

3. **Wait for the breakpoint to hit**:
   ```
   godot_debugger sessions
   ```
   Look for `paused: true` in the response.

4. **Inspect the stack**:
   ```
   godot_debugger stack_trace
   ```

5. **Examine variables** (frame_id=0 is innermost):
   ```
   godot_debugger variables frame_id=0 scope="local"
   godot_debugger variables scope="members"
   ```

6. **Step or resume**:
   ```
   godot_debugger step_over   # or step_into
   godot_debugger resume
   ```

7. **Remove the breakpoint when done**:
   ```
   godot_debugger remove_breakpoint script_path="{script}" line={line}
   godot_game stop
   ```
"""

    @mcp.prompt()
    def network_test(peer_count: int = 2, scene: str = "") -> str:
        """Multiplayer network testing workflow.

        Args:
            peer_count: Total instances (host + clients). Minimum 2.
            scene: res:// path for the host to load.
        """
        scene_arg = f' scene="{scene}"' if scene else ""
        clients = max(0, peer_count - 1)
        return f"""# Network Testing Workflow ({peer_count} peers: 1 host + {clients} clients)

1. **Launch the host**:
   ```
   godot_network launch_instance role="host"{scene_arg}
   ```
   Note the game_port from the response (e.g. 7070).

2. **Launch clients** (repeat {clients} times):
   ```
   godot_network launch_instance role="client" args={{"connect_to": "127.0.0.1:7070"}}
   ```

3. **Verify connections**:
   ```
   godot_network list_instances
   ```
   All instances should show `connected: true`.

4. **Test synchronized state**:
   ```
   godot_network sync_state
   ```
   Check `all_in_sync: true` and each node's `in_sync` field.

5. **Inject network conditions** (optional):
   ```
   godot_network network_condition instance_id="inst_2" latency_ms=200 loss_pct=5 jitter_ms=50
   ```

6. **Simulate additional peers for stress testing**:
   ```
   godot_batch execute operations=[
     {{"tool": "godot_network", "action": "simulate_peer", "params": {{"instance_id": "inst_1", "peer_config": {{"peer_id": 2, "player_name": "Bot1"}}}}}},
     ...
   ]
   ```

7. **Test disconnection/reconnection**:
   ```
   godot_network terminate instance_id="inst_2"
   godot_network launch_instance role="client" args={{"connect_to": "127.0.0.1:7070", "reconnect": true}}
   ```

8. **Clean up**:
   ```
   godot_network terminate instance_id="inst_1"
   ```
"""

    @mcp.prompt()
    def build_scene(description: str) -> str:
        """Build a scene from a natural-language description.

        Args:
            description: What the scene should contain and do.
        """
        return f"""# Build Scene Workflow

Target scene description: {description}

Follow these steps:

1. **Check current project state**:
   ```
   godot_project info
   godot_editor_read state
   ```

2. **Plan the scene structure** — identify root node type, child nodes, scripts needed.

3. **Create the scene file**:
   ```
   godot_scene create path="res://scenes/<name>.tscn" root_type="<RootType>" root_name="<Name>"
   ```

4. **Open it and add nodes** (use batch for efficiency):
   ```
   godot_editor_edit open_scene path="res://scenes/<name>.tscn"
   godot_batch execute operations=[
     {{"tool": "godot_node_edit", "action": "create", "params": {{"type": "Sprite2D", "name": "Player", "parent_path": "/root/<Name>"}}}},
     ...
   ]
   ```

5. **Create and attach scripts**:
   ```
   godot_script create path="res://<name>.gd" extends="CharacterBody2D" content="..."
   godot_script attach node_path="/root/<Name>/Player" script_path="res://<name>.gd"
   ```

6. **Set properties**:
   ```
   godot_node_edit set_properties node_path="/root/<Name>/Player" properties={{"position": {{"x": 100, "y": 200}}}}
   ```

7. **Save and validate**:
   ```
   godot_scene save path="res://scenes/<name>.tscn"
   godot_lsp diagnostics path="res://<name>.gd"
   ```

8. **Verify by running**:
   ```
   godot_game play scene="res://scenes/<name>.tscn" frozen=true
   godot_runtime_state digest
   godot_game stop
   ```

**Rules**:
- Use res:// paths for scene/script operations.
- Use /root/... node paths for node operations.
- Godot types are JSON objects: Vector2={{"x":..,"y":..}}, Color={{"r":..,"g":..,"b":..,"a":..}}.
- Use batch to reduce round-trips when creating many nodes.
"""

    @mcp.prompt()
    def fix_bug(description: str) -> str:
        """Bug fixing workflow: reproduce, diagnose, fix, verify.

        Args:
            description: What the bug is.
        """
        return f"""# Bug Fix Workflow

Bug description: {description}

1. **Reproduce the bug deterministically**:
   ```
   godot_game play frozen=true
   godot_exec eval code="<setup code to trigger the bug condition>"
   godot_game_time step_until condition="<condition that exposes the bug>" timeout_ms=10000
   godot_runtime_state digest
   ```
   Capture the BAD state (positions, values) in the digest.

2. **Diagnose** — read the relevant code and scene structure:
   ```
   godot_node_read inspect node_path="/root/<suspected_node>"
   godot_script read path="res://<suspected_script>.gd"
   godot_lsp diagnostics path="res://<suspected_script>.gd"
   ```
   Look for logic errors, wrong assumptions, missing checks.

3. **Fix the code**:
   ```
   godot_script edit path="res://<script>.gd" edits=[{{"old": "<buggy code>", "new": "<fixed code>"}}]
   godot_script validate path="res://<script>.gd"
   ```

4. **Verify the fix**:
   ```
   godot_game stop
   godot_game play frozen=true
   godot_exec eval code="<same setup code>"
   godot_game_time step_until condition="<same condition>" timeout_ms=10000
   godot_runtime_state digest
   ```
   Confirm the state is now CORRECT (compare to step 1).

5. **Visual confirmation if needed**:
   ```
   godot_screenshot game max_width=1280 format="jpeg" quality=70
   ```

6. **Clean up**:
   ```
   godot_game stop
   ```

**Key**: The deterministic approach lets YOU verify the fix without human ferrying screenshots.
The freeze/step/digest loop is your verification harness.
"""
