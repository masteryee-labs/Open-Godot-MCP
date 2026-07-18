"""Tool registration — import and call every tool module's register function.

Order matches Docs/02-Tools/Index.md §工具清單.
"""

from __future__ import annotations

from fastmcp import FastMCP

from ..context import ServerContext


def register_all_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    # Phase 0 — editor, scene, node, script, project, resource, filesystem, docs, log, health
    from .editor import register_editor_tools
    from .filesystem import register_filesystem_tools
    from .health import register_health_tools
    from .node import register_node_tools
    from .project import register_project_tools
    from .resource import register_resource_tools
    from .scene import register_scene_tools
    from .script import register_script_tools

    register_editor_tools(mcp, ctx)
    register_scene_tools(mcp, ctx)
    register_node_tools(mcp, ctx)
    register_script_tools(mcp, ctx)
    register_project_tools(mcp, ctx)
    register_resource_tools(mcp, ctx)
    register_filesystem_tools(mcp, ctx)
    register_health_tools(mcp, ctx)

    # Phase 1 — game control, time, input, runtime state, exec, screenshot
    from .exec_tool import register_exec_tools
    from .game import register_game_tools
    from .game_time import register_game_time_tools
    from .input import register_input_tools
    from .runtime_state import register_runtime_state_tools
    from .screenshot import register_screenshot_tools

    register_game_tools(mcp, ctx)
    register_game_time_tools(mcp, ctx)
    register_input_tools(mcp, ctx)
    register_runtime_state_tools(mcp, ctx)
    register_exec_tools(mcp, ctx)
    register_screenshot_tools(mcp, ctx)

    # Phase 2 — network, instance
    from .instance import register_instance_tools
    from .network import register_network_tools

    register_network_tools(mcp, ctx)
    register_instance_tools(mcp, ctx)

    # Phase 3 — debugger, lsp, profiler, test, animation, tilemap, asset, export, batch
    from .animation import register_animation_tools
    from .asset import register_asset_tools
    from .batch import register_batch_tools
    from .csharp import register_csharp_tools
    from .debugger import register_debugger_tools
    from .export import register_export_tools
    from .lsp import register_lsp_tools
    from .profiler import register_profiler_tools
    from .test import register_test_tools
    from .tilemap import register_tilemap_tools

    register_debugger_tools(mcp, ctx)
    register_lsp_tools(mcp, ctx)
    register_profiler_tools(mcp, ctx)
    register_test_tools(mcp, ctx)
    register_animation_tools(mcp, ctx)
    register_tilemap_tools(mcp, ctx)
    register_asset_tools(mcp, ctx)
    register_export_tools(mcp, ctx)
    register_batch_tools(mcp, ctx)
    register_csharp_tools(mcp, ctx)
