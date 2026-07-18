"""Tools package — all MCP tool definitions.

Each module registers one or more tools onto a FastMCP instance via
``register_*_tools(mcp, ctx)``. The package ``register_all_tools`` calls
them all in order matching Docs/02-Tools/Index.md.

Design (Index.md §設計原則):
  - godot_<domain>_<access> where access = read | edit
  - read tools: auto-allow; edit tools: gated
  - Related actions collapsed into one tool's ``action`` param
  - Every tool returns {ok: bool, ...}; on failure {ok:false, error:{code,message}}
"""

from ._registry import register_all_tools

__all__ = ["register_all_tools"]
