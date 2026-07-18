"""Filesystem, docs, log tools.

Docs: 02-Tools/Filesystem.md
  filesystem: list, read, search, create, delete, rename
  docs: fetch, search
  log: get, errors, clear
"""
from __future__ import annotations

import logging
import re

import httpx
from fastmcp import FastMCP

from ..context import ServerContext
from ..utils.error_codes import fail, ok
from ._helpers import make_simple_tool, make_tool

log = logging.getLogger(__name__)

# Godot docs base — version-matched at call time.
_DOCS_BASE = "https://docs.godotengine.org/en/{ver}/classes/class_{cls}.html"
_DOCS_SEARCH = "https://docs.godotengine.org/en/{ver}/search.html?q={q}"

# Minimal HTML→text: strip tags, collapse whitespace, keep code blocks.
_TAG_RE = re.compile(r"<[^>]+>")
_WS_RE = re.compile(r"\n{3,}")


def _html_to_text(html: str) -> str:
    # Preserve <pre><code> blocks before stripping
    html = html.replace("<pre>", "\n```\n").replace("</pre>", "\n```\n")
    html = html.replace("<code>", "`").replace("</code>", "`")
    html = html.replace("<h1>", "\n# ").replace("</h1>", "\n")
    html = html.replace("<h2>", "\n## ").replace("</h2>", "\n")
    html = html.replace("<h3>", "\n### ").replace("</h3>", "\n")
    html = html.replace("<h4>", "\n#### ").replace("</h4>", "\n")
    html = html.replace("<p>", "\n").replace("</p>", "\n")
    html = html.replace("<li>", "\n- ").replace("</li>", "")
    html = html.replace("<br>", "\n").replace("<br/>", "\n")
    text = _TAG_RE.sub("", html)
    text = _WS_RE.sub("\n\n", text)
    # Decode common HTML entities
    text = text.replace("&lt;", "<").replace("&gt;", ">").replace("&amp;", "&")
    text = text.replace("&quot;", '"').replace("&#39;", "'").replace("&nbsp;", " ")
    return text.strip()


def _godot_version(ctx: ServerContext) -> str:
    """Get the Godot version from the active bridge handshake, or default."""
    bridge = ctx.bridge()
    if bridge and bridge.info.godot_version:
        v = bridge.info.godot_version
        # Format: "4.7-stable (official)" or "4.5.stable" → "4.7" / "4.5"
        m = re.match(r"(\d+)\.(\d+)", v)
        if m:
            return f"{m.group(1)}.{m.group(2)}"
    return "4.5"  # Default to latest stable


def register_filesystem_tools(mcp: FastMCP, ctx: ServerContext) -> None:
    make_simple_tool(
        mcp,
        ctx,
        "godot_filesystem",
        "File ops. Actions: "
        "list(path,include_hidden?) {entries:[{name,type,size?}]}, "
        "read(path,start_line?,end_line?,max_bytes?) {content,total_lines} "
        "(TEXT files only; binary -> UNSUPPORTED_FILE_TYPE; 1-based lines), "
        "search(query,glob?,max_results?) {matches:[{path,line,line_number,match_text}]} "
        "(query is Python re regex), "
        "create(path,content) write, "
        "delete(path,confirm?) write (dangerous paths need confirm=true), "
        "rename(old_path,new_path) write. "
        "path accepts res:// or absolute filesystem path.",
    )

    @make_tool(
        mcp,
        ctx,
        "godot_docs",
        "Godot official docs (version-matched, auto-allow). Actions: "
        "fetch(class_name,method?) {markdown,url} "
        "(fetches the live Godot docs page, converts to markdown), "
        "search(query) {results:[{title,url,snippet}]}.",
    )
    async def godot_docs(action: str, params: dict | None = None) -> dict:
        params = params or {}
        if action == "fetch":
            cls = params.get("class_name", "")
            method = params.get("method", "")
            if not cls:
                return fail("INVALID_ARGUMENT", "class_name required")
            ver = _godot_version(ctx)
            url = _DOCS_BASE.format(ver=ver, cls=cls.lower())
            if method:
                url += f"#{method}"
            try:
                async with httpx.AsyncClient(timeout=10.0, follow_redirects=True) as client:
                    resp = await client.get(url)
                    resp.raise_for_status()
                    text = _html_to_text(resp.text)
                    # Truncate to reasonable size
                    if len(text) > 20000:
                        text = text[:20000] + "\n\n... (truncated)"
                    return ok(markdown=text, url=url)
            except httpx.HTTPStatusError as e:
                return fail("NOT_FOUND", f"Docs page not found: {url} ({e.response.status_code})")
            except (httpx.RequestError, Exception) as e:
                return fail("INTERNAL_ERROR", f"Failed to fetch docs: {e}")
        elif action == "search":
            query = params.get("query", "")
            if not query:
                return fail("INVALID_ARGUMENT", "query required")
            ver = _godot_version(ctx)
            url = _DOCS_SEARCH.format(ver=ver, q=httpx.URL(query).path)
            try:
                async with httpx.AsyncClient(timeout=10.0, follow_redirects=True) as client:
                    resp = await client.get(url)
                    resp.raise_for_status()
                    text = _html_to_text(resp.text)
                    # Extract search result links (simplified)
                    results = []
                    for m in re.finditer(r'href="([^"]+)"[^>]*>([^<]+)</a>', resp.text):
                        href = m.group(1)
                        title = m.group(2)
                        if href.startswith("class_") or "class_" in href:
                            full_url = f"https://docs.godotengine.org/en/{ver}/{href}"
                            results.append({"title": title, "url": full_url, "snippet": ""})
                        if len(results) >= 20:
                            break
                    if not results:
                        return ok(results=[{
                            "title": f"Search: {query}",
                            "url": url,
                            "snippet": text[:500],
                        }])
                    return ok(results=results)
            except (httpx.RequestError, Exception) as e:
                return fail("INTERNAL_ERROR", f"Failed to search docs: {e}")
        else:
            return fail("INVALID_ARGUMENT", f"Unknown action: {action}")

    make_simple_tool(
        mcp,
        ctx,
        "godot_log",
        "Log access. Actions: "
        "get(source?=editor|game|plugin|all,count?,offset?,since_ms?) "
        "{entries:[{time,level,source,message}]} (auto-allow), "
        "errors(max?,include_warnings?) {errors:[...]} (auto-allow), "
        "clear (write, gated).",
    )
