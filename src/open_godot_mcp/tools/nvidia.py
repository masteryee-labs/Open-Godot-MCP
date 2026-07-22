"""NVIDIA API tools — vision (VLM, base64 direct) + image generation (FLUX).

Dynamically registered based on ~/.open_godot_mcp/config.json.
Distinct from Agnes: NVIDIA VLM accepts base64 data URIs (no upload needed),
and FLUX.2-klein-4b is a separate text-to-image endpoint. Both are free.

Endpoints:
  - VLM: POST https://integrate.api.nvidia.com/v1/chat/completions
         (model e.g. meta/llama-3.2-90b-vision-instruct)
  - Image gen: POST https://ai.api.nvidia.com/v1/genai/flux/flux.2-klein-4b
               (returns artifacts[].base64)

Rate-limit / quota handling mirrors agnes.py: key rotation on 429/402/401,
backoff when all keys exhausted. See agnes.py docstring for details.
"""

from __future__ import annotations

import asyncio
import base64
import json
import logging
import os
import time
import urllib.error
import urllib.request
from pathlib import Path

from fastmcp import FastMCP

from ..agnes_config import get_api_keys, load_config
from ..context import ServerContext
from ..utils.error_codes import fail, ok

log = logging.getLogger(__name__)

RATE_BACKOFF = [2.0, 4.0, 8.0]
RATE_MAX_RETRIES = 3
HTTP_TIMEOUT = 180


def _nvidia_cfg() -> dict:
    return load_config().get("nvidia", {})


def _post_json(url: str, headers: dict, payload: dict, timeout: int = HTTP_TIMEOUT) -> tuple[int, dict | str]:
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=data, method="POST")
    for k, v in headers.items():
        req.add_header(k, v)
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            body = resp.read().decode("utf-8", errors="replace")
            code = resp.status
    except urllib.error.HTTPError as e:
        body = ""
        try:
            body = e.read().decode("utf-8", errors="replace")
        except Exception:
            pass
        return e.code, body
    try:
        return code, json.loads(body)
    except json.JSONDecodeError:
        return code, body


def _classify_http_error(code: int, body) -> tuple[str, str]:
    snippet = body[:300] if isinstance(body, str) else str(body)[:300]
    if code == 401:
        return "AUTH_FAILED", f"NVIDIA API key invalid (HTTP 401). {snippet}"
    if code == 402:
        return "QUOTA_EXHAUSTED", f"NVIDIA account quota exhausted (HTTP 402). {snippet}"
    if code == 403:
        return "PERMISSION_DENIED", f"NVIDIA API key lacks permission (HTTP 403). {snippet}"
    if code == 429:
        return "RATE_LIMITED", f"NVIDIA rate limit hit (HTTP 429). {snippet}"
    if code in (500, 502, 503, 504, 524):
        return "SERVER_ERROR", f"NVIDIA server error (HTTP {code}, retryable). {snippet}"
    return "API_ERROR", f"NVIDIA HTTP {code}: {snippet}"


def _call_with_retry(
    url: str, api_keys: list[str], payload: dict, extra_headers: dict | None = None, timeout: int = HTTP_TIMEOUT
) -> dict:
    """POST with key rotation + backoff. Returns ok() dict or fail() dict.

    On 429/402/401: rotate to next key, backoff when all keys exhausted.
    On 5xx: backoff and retry with same key (server error is not key-specific).
    """
    if not api_keys:
        return fail("AUTH_FAILED", "No NVIDIA API keys configured")
    last_err = None
    key_count = len(api_keys)
    for attempt in range(RATE_MAX_RETRIES + 1):
        key_idx = attempt % key_count
        api_key = api_keys[key_idx]
        headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}
        if extra_headers:
            headers.update(extra_headers)
        code, body = _post_json(url, headers, payload, timeout)
        if code == 200:
            return ok(response=body)
        err_code, msg = _classify_http_error(code, body)
        if err_code in ("RATE_LIMITED", "QUOTA_EXHAUSTED", "AUTH_FAILED"):
            last_err = (err_code, msg)
            if key_idx < key_count - 1:
                log.warning("nvidia %s on key %d/%d, rotating to next key", err_code, key_idx + 1, key_count)
                continue
            if attempt < RATE_MAX_RETRIES:
                wait = RATE_BACKOFF[min(attempt // key_count, len(RATE_BACKOFF) - 1)]
                log.warning("nvidia all %d keys exhausted (%s), backoff %.1fs", key_count, err_code, wait)
                time.sleep(wait)
                continue
            return fail(err_code, msg)
        if err_code == "SERVER_ERROR":
            last_err = (err_code, msg)
            if attempt < RATE_MAX_RETRIES:
                wait = RATE_BACKOFF[min(attempt, len(RATE_BACKOFF) - 1)]
                log.warning("nvidia %s (HTTP %d), backoff %.1fs before retry", err_code, code, wait)
                time.sleep(wait)
                continue
            return fail(err_code, msg)
        return fail(err_code, msg)
    return fail(last_err[0], last_err[1]) if last_err else fail("RATE_LIMITED", "NVIDIA rate limit exhausted")


def _image_to_b64_data_uri(image_path: str) -> str:
    """Read a local image file and return a base64 data URI."""
    with open(image_path, "rb") as f:
        b64 = base64.b64encode(f.read()).decode("ascii")
    ext = os.path.splitext(image_path)[1].lower().lstrip(".")
    mime = "image/png" if ext in ("png",) else f"image/{ext or 'png'}"
    return f"data:{mime};base64,{b64}"


# ---- tool: nvidia_vision ----


async def _nvidia_vision(action: str, params: dict | None = None) -> dict:
    params = params or {}
    cfg = _nvidia_cfg()
    if not cfg.get("enabled") or not cfg.get("vision"):
        return fail("TOOL_DISABLED", "NVIDIA vision is not enabled in the dock config")
    api_keys = get_api_keys(cfg)
    if not api_keys:
        return fail("AUTH_FAILED", "No NVIDIA API keys configured")
    base_url = cfg.get("vlm_base_url", "https://integrate.api.nvidia.com/v1").rstrip("/")
    model = cfg.get("vlm_model", "meta/llama-3.2-90b-vision-instruct")

    if action == "analyze":
        image = params.get("image") or params.get("image_path")
        question = params.get("question") or "Describe this image in detail."
        if not image:
            return fail("INVALID_ARGUMENT", "Required: image (local path)")
        if image.startswith(("http://", "https://")):
            img_url = image
        else:
            p = Path(image)
            if not p.is_file():
                return fail("INVALID_ARGUMENT", f"Image file not found: {image}")
            img_url = _image_to_b64_data_uri(image)
        payload = {
            "model": model,
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": question},
                        {"type": "image_url", "image_url": {"url": img_url}},
                    ],
                }
            ],
            "max_tokens": int(params.get("max_tokens", 3000)),
            "temperature": float(params.get("temperature", 0.3)),
        }
        result = await asyncio.to_thread(
            _call_with_retry, base_url + "/chat/completions", api_keys, payload
        )
        if not result.get("ok"):
            return result
        resp = result["response"]
        content = ""
        if isinstance(resp, dict):
            choices = resp.get("choices") or []
            if choices:
                content = choices[0].get("message", {}).get("content", "")
        return ok(content=content, model=model)
    return fail("INVALID_ARGUMENT", f"Unknown action: {action}. Supported: analyze")


# ---- tool: nvidia_image_generate (FLUX) ----


async def _nvidia_image_generate(action: str, params: dict | None = None) -> dict:
    params = params or {}
    cfg = _nvidia_cfg()
    if not cfg.get("enabled") or not cfg.get("image_generate"):
        return fail("TOOL_DISABLED", "NVIDIA image generation is not enabled in the dock config")
    api_keys = get_api_keys(cfg)
    if not api_keys:
        return fail("AUTH_FAILED", "No NVIDIA API keys configured")
    base_url = cfg.get("imggen_base_url", "https://ai.api.nvidia.com/v1/genai").rstrip("/")
    model = cfg.get("imggen_model", "flux/flux.2-klein-4b")
    url = f"{base_url}/{model}"

    if action == "generate":
        prompt = params.get("prompt")
        if not prompt:
            return fail("INVALID_ARGUMENT", "Required: prompt")
        width = int(params.get("width", 768))
        height = int(params.get("height", 576))
        seed = int(params.get("seed", 42))
        payload = {"prompt": prompt, "width": width, "height": height, "seed": seed}
        result = await asyncio.to_thread(
            _call_with_retry, url, api_keys, payload, {"Accept": "application/json"}
        )
        if not result.get("ok"):
            return result
        resp = result["response"]
        # FLUX response: {artifacts: [{base64, finishReason}]}
        b64 = ""
        finish = ""
        if isinstance(resp, dict):
            arts = resp.get("artifacts") or []
            if arts:
                b64 = arts[0].get("base64", "")
                finish = arts[0].get("finishReason", "?")
        # Optional: save to output_path
        saved = None
        if b64 and params.get("output_path"):
            try:
                out = Path(params["output_path"])
                out.parent.mkdir(parents=True, exist_ok=True)
                out.write_bytes(base64.b64decode(b64))
                saved = str(out)
            except Exception as e:
                log.warning("nvidia_image_generate save failed: %s", e)
        return ok(base64=b64, finish_reason=finish, model=model, width=width, height=height, saved=saved)
    return fail("INVALID_ARGUMENT", f"Unknown action: {action}. Supported: generate")


# ---- registration ----

_TOOL_FNS = {
    "nvidia_vision": _nvidia_vision,
    "nvidia_image_generate": _nvidia_image_generate,
}

_TOOL_DESCRIPTIONS = {
    "nvidia_vision": (
        "Analyze an image via NVIDIA NIM VLM (free, supports base64 — no upload needed). "
        "Actions: analyze(image, question?, max_tokens?, temperature?). "
        "image is a local file path; encoded as base64 data URI and sent directly. "
        "Higher quality than Agnes vision; use when Agnes is unavailable or higher fidelity is needed."
    ),
    "nvidia_image_generate": (
        "Generate an image via NVIDIA FLUX.2-klein-4b (free, returns base64). "
        "Actions: generate(prompt, width?, height?, seed?, output_path?). "
        "width/height must be multiples of 32 in [512,1536]. If output_path given, PNG is saved to disk."
    ),
}


def register_nvidia_tools(mcp: FastMCP, ctx: ServerContext, only: set[str] | None = None) -> None:
    """Register NVIDIA tools. If *only* is given, register just those names."""
    names = set(only) if only is not None else set(_TOOL_FNS.keys())
    for name in names:
        if name not in _TOOL_FNS:
            continue
        fn = _TOOL_FNS[name]
        desc = _TOOL_DESCRIPTIONS[name]
        mcp.tool(name=name, description=desc)(fn)
