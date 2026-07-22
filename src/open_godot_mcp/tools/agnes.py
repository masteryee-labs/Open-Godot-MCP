"""Agnes API tools — vision (image understanding), image generation, video generation.

Dynamically registered based on ~/.open_godot_mcp/config.json (see agnes_config.py).
When the user disables Agnes in the dock, these tools are unregistered and the
AI client never sees them — preventing accidental use of lower-tier vision
when the model itself has vision capability.

Agnes API (https://apihub.agnes-ai.com/v1):
  - agnes-2.0-flash: chat + image understanding (public URL only, NO base64)
  - agnes-image-2.0-flash: text-to-image, image-to-image (POST /images/generations)
  - agnes-video-v2.0: text-to-video, image-to-video (async: POST /videos + GET poll)

Local image files for vision must be uploaded to a public URL first (uguu.se,
3h auto-delete) because Agnes does not accept base64 data URIs.

Rate-limit / quota handling (no silent fallback, no skip):
  - 429: rotate to next API key; if all keys exhausted, backoff [2,4,8]s then retry
  - 402: QUOTA_EXHAUSTED (no retry, rotate to next key first)
  - 403: PERMISSION_DENIED (no retry)
  - 401: AUTH_FAILED (no retry, rotate to next key first)
  - 5xx / network: API_ERROR

API key rotation: config.agnes.api_keys is a list. On 429/402/401, the next
key is tried. If all keys are exhausted, backoff retries kick in. This lets
users register multiple free-tier keys to pool their per-minute quota.
"""

from __future__ import annotations

import asyncio
import json
import logging
import os
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid
from pathlib import Path

from fastmcp import FastMCP

from ..agnes_config import get_api_keys, load_config
from ..context import ServerContext
from ..utils.error_codes import fail, ok

log = logging.getLogger(__name__)

UGUU_UPLOAD_URL = "https://uguu.se/upload.php?output=json"
UGUU_TIMEOUT = 90
RATE_BACKOFF = [2.0, 4.0, 8.0]
RATE_MAX_RETRIES = 3
HTTP_TIMEOUT = 180


# ---- HTTP helpers ----


def _agnes_cfg() -> dict:
    return dict(load_config().get("agnes", {}))


def _post_json(url: str, headers: dict, payload: dict, timeout: int = HTTP_TIMEOUT) -> tuple[int, dict | str]:
    """POST JSON. Returns (status_code, parsed_json_or_body_text)."""
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


def _get_json(url: str, headers: dict, timeout: int = HTTP_TIMEOUT) -> tuple[int, dict | str]:
    req = urllib.request.Request(url, method="GET")
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


def _classify_http_error(code: int, body: dict | str) -> tuple[str, str]:
    """Map HTTP status to (error_code, message)."""
    snippet = body[:300] if isinstance(body, str) else str(body)[:300]
    if code == 401:
        return "AUTH_FAILED", f"Agnes API key invalid or expired (HTTP 401). {snippet}"
    if code == 402:
        return "QUOTA_EXHAUSTED", f"Agnes account quota/balance exhausted (HTTP 402). {snippet}"
    if code == 403:
        return "PERMISSION_DENIED", f"Agnes API key lacks permission for this model (HTTP 403). {snippet}"
    if code == 429:
        return "RATE_LIMITED", f"Agnes rate limit hit (HTTP 429, free tier RPM 20). {snippet}"
    if code in (500, 502, 503, 504, 524):
        return "SERVER_ERROR", f"Agnes server error (HTTP {code}, retryable). {snippet}"
    if 400 <= code < 500:
        return "API_ERROR", f"Agnes HTTP {code}: {snippet}"
    return "API_ERROR", f"Agnes HTTP {code}: {snippet}"


def _call_with_retry(
    url: str, api_keys: list[str], payload: dict, timeout: int = HTTP_TIMEOUT
) -> dict:
    """POST with key rotation + backoff. Returns ok() dict or fail() dict.

    On 429/402/401: rotate to the next API key. If all keys are tried in this
    round, sleep with backoff and start a new round.
    On 5xx (500/502/503/504/524): backoff and retry with the same key (server
    error is not key-specific, per Agnes docs §503 "Retry later").
    After RATE_MAX_RETRIES rounds, return the last error.
    """
    if not api_keys:
        return fail("AUTH_FAILED", "No Agnes API keys configured")
    last_err = None
    key_count = len(api_keys)
    for attempt in range(RATE_MAX_RETRIES + 1):
        key_idx = attempt % key_count
        api_key = api_keys[key_idx]
        headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}
        code, body = _post_json(url, headers, payload, timeout)
        if code == 200:
            return ok(response=body)
        err_code, msg = _classify_http_error(code, body)
        # Key-level errors: rotate to next key immediately (no sleep)
        if err_code in ("RATE_LIMITED", "QUOTA_EXHAUSTED", "AUTH_FAILED"):
            last_err = (err_code, msg)
            # If we haven't tried all keys yet in this round, rotate immediately
            if key_idx < key_count - 1:
                log.warning("agnes %s on key %d/%d, rotating to next key", err_code, key_idx + 1, key_count)
                continue
            # All keys exhausted this round — backoff if retries remain
            if attempt < RATE_MAX_RETRIES:
                wait = RATE_BACKOFF[min(attempt // key_count, len(RATE_BACKOFF) - 1)]
                log.warning("agnes all %d keys exhausted (%s), backoff %.1fs", key_count, err_code, wait)
                time.sleep(wait)
                continue
            return fail(err_code, msg)
        # Server errors: backoff and retry (not key-specific, same key is fine)
        if err_code == "SERVER_ERROR":
            last_err = (err_code, msg)
            if attempt < RATE_MAX_RETRIES:
                wait = RATE_BACKOFF[min(attempt, len(RATE_BACKOFF) - 1)]
                log.warning("agnes %s (HTTP %d), backoff %.1fs before retry", err_code, code, wait)
                time.sleep(wait)
                continue
            return fail(err_code, msg)
        # Non-rotatable, non-retryable errors: return immediately
        return fail(err_code, msg)
    return fail(last_err[0], last_err[1]) if last_err else fail("RATE_LIMITED", "Agnes rate limit exhausted")


# ---- uguu.se upload (local file → public URL for Agnes vision) ----


def _upload_uguu(file_path: str, timeout: int = UGUU_TIMEOUT) -> str:
    """Upload a local file to uguu.se, return the public URL.

    uguu.se auto-deletes files + server records after 3 hours.
    Raises RuntimeError on failure.
    """
    boundary = "----uguu" + uuid.uuid4().hex
    with open(file_path, "rb") as f:
        data = f.read()
    fn = os.path.basename(file_path)
    body = (
        ("--" + boundary + "\r\n"
         'Content-Disposition: form-data; name="files[]"; filename="' + fn + '"\r\n'
         "Content-Type: image/png\r\n\r\n").encode("utf-8")
        + data
        + ("\r\n--" + boundary + "--\r\n").encode("utf-8")
    )
    req = urllib.request.Request(
        UGUU_UPLOAD_URL,
        data=body,
        headers={"Content-Type": "multipart/form-data; boundary=" + boundary},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        obj = json.loads(resp.read().decode("utf-8"))
    files = obj.get("files") or []
    if not files:
        raise RuntimeError(f"uguu.se response missing files[]: {obj}")
    url = files[0].get("url") or ""
    if not url:
        raise RuntimeError(f"uguu.se returned empty url: {obj}")
    return url


def _resolve_image_to_url(image: str) -> tuple[str | None, dict | None]:
    """Accept image_path or image_url. If local path, upload to uguu.se.

    Returns (url, None) on success or (None, fail_dict) on failure.
    """
    if image.startswith(("http://", "https://")):
        return image, None
    p = Path(image)
    if not p.is_file():
        return None, fail("INVALID_ARGUMENT", f"Image file not found: {image}")
    try:
        url = _upload_uguu(image)
    except urllib.error.HTTPError as e:
        body = ""
        try:
            body = e.read().decode("utf-8", errors="replace")[:300]
        except Exception:
            pass
        return None, fail("UPLOAD_FAILED", f"uguu.se upload failed (HTTP {e.code}): {body}")
    except Exception as e:
        return None, fail("UPLOAD_FAILED", f"uguu.se upload failed: {type(e).__name__}: {e}")
    return url, None


# ---- tool: agnes_vision ----


async def _agnes_vision(action: str, params: dict | None = None) -> dict:
    params = params or {}
    cfg = _agnes_cfg()
    if not cfg.get("enabled") or not cfg.get("vision"):
        return fail("TOOL_DISABLED", "Agnes vision is not enabled in the dock config")
    api_keys = get_api_keys(cfg)
    if not api_keys:
        return fail("AUTH_FAILED", "No Agnes API keys configured")
    base_url = cfg.get("base_url", "https://apihub.agnes-ai.com/v1").rstrip("/")
    model = cfg.get("text_model", "agnes-2.0-flash")

    if action == "analyze":
        image = params.get("image") or params.get("image_path") or params.get("image_url")
        question = params.get("question") or "Describe this image in detail."
        if not image:
            return fail("INVALID_ARGUMENT", "Required: image (local path or public URL)")
        url, err = _resolve_image_to_url(image)
        if err:
            return err
        payload = {
            "model": model,
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": question},
                        {"type": "image_url", "image_url": {"url": url}},
                    ],
                }
            ],
            "chat_template_kwargs": {"enable_thinking": False},
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
        return ok(content=content, image_url=url, model=model)
    return fail("INVALID_ARGUMENT", f"Unknown action: {action}. Supported: analyze")


# ---- tool: agnes_image_generate ----


async def _agnes_image_generate(action: str, params: dict | None = None) -> dict:
    params = params or {}
    cfg = _agnes_cfg()
    if not cfg.get("enabled") or not cfg.get("image_generate"):
        return fail("TOOL_DISABLED", "Agnes image generation is not enabled in the dock config")
    api_keys = get_api_keys(cfg)
    if not api_keys:
        return fail("AUTH_FAILED", "No Agnes API keys configured")
    base_url = cfg.get("base_url", "https://apihub.agnes-ai.com/v1").rstrip("/")
    model = cfg.get("image_model", "agnes-image-2.0-flash")

    if action == "generate":
        prompt = params.get("prompt")
        if not prompt:
            return fail("INVALID_ARGUMENT", "Required: prompt")
        size = params.get("size", "1024x1024")
        payload = {
            "model": model,
            "prompt": prompt,
            "size": size,
            "extra_body": {"response_format": params.get("response_format", "url")},
        }
        result = await asyncio.to_thread(
            _call_with_retry, base_url + "/images/generations", api_keys, payload
        )
        if not result.get("ok"):
            return result
        return ok(response=result["response"], model=model, size=size)
    if action == "edit":
        prompt = params.get("prompt")
        image = params.get("image") or params.get("image_path") or params.get("image_url")
        if not prompt or not image:
            return fail("INVALID_ARGUMENT", "Required: prompt, image (path or URL)")
        url, err = _resolve_image_to_url(image)
        if err:
            return err
        size = params.get("size", "1024x1024")
        payload = {
            "model": model,
            "prompt": prompt,
            "size": size,
            "extra_body": {
                "image": [url],
                "response_format": params.get("response_format", "url"),
            },
        }
        result = await asyncio.to_thread(
            _call_with_retry, base_url + "/images/generations", api_keys, payload
        )
        if not result.get("ok"):
            return result
        return ok(response=result["response"], model=model, size=size, input_image_url=url)
    return fail("INVALID_ARGUMENT", f"Unknown action: {action}. Supported: generate, edit")


# ---- tool: agnes_video_generate (async task API) ----


async def _agnes_video_generate(action: str, params: dict | None = None) -> dict:
    params = params or {}
    cfg = _agnes_cfg()
    if not cfg.get("enabled") or not cfg.get("video_generate"):
        return fail("TOOL_DISABLED", "Agnes video generation is not enabled in the dock config")
    api_keys = get_api_keys(cfg)
    if not api_keys:
        return fail("AUTH_FAILED", "No Agnes API keys configured")
    base_url = cfg.get("base_url", "https://apihub.agnes-ai.com/v1").rstrip("/")
    model = cfg.get("video_model", "agnes-video-v2.0")

    if action == "create":
        prompt = params.get("prompt")
        if not prompt:
            return fail("INVALID_ARGUMENT", "Required: prompt")
        payload: dict = {
            "model": model,
            "prompt": prompt,
            "width": int(params.get("width", 1152)),
            "height": int(params.get("height", 768)),
            "num_frames": int(params.get("num_frames", 121)),
            "frame_rate": float(params.get("frame_rate", 24)),
        }
        if params.get("negative_prompt"):
            payload["negative_prompt"] = params["negative_prompt"]
        if params.get("seed") is not None:
            payload["seed"] = int(params["seed"])
        # image-to-video: optional single image URL
        if params.get("image"):
            url, err = _resolve_image_to_url(params["image"])
            if err:
                return err
            payload["image"] = url
        result = await asyncio.to_thread(
            _call_with_retry, base_url + "/videos", api_keys, payload
        )
        if not result.get("ok"):
            return result
        resp = result["response"]
        video_id = resp.get("video_id") if isinstance(resp, dict) else None
        return ok(response=resp, video_id=video_id, model=model)
    if action == "status":
        video_id = params.get("video_id") or params.get("task_id")
        if not video_id:
            return fail("INVALID_ARGUMENT", "Required: video_id (or task_id)")
        # Recommended endpoint: GET /agnesapi?video_id=<id>
        poll_url = f"https://apihub.agnes-ai.com/agnesapi?video_id={urllib.parse.quote(video_id)}"
        headers = {"Authorization": f"Bearer {api_keys[0]}", "Content-Type": "application/json"}
        code, body = await asyncio.to_thread(_get_json, poll_url, headers)
        if code == 200:
            return ok(response=body, video_id=video_id)
        err_code, msg = _classify_http_error(code, body if isinstance(body, str) else json.dumps(body))
        return fail(err_code, msg)
    return fail("INVALID_ARGUMENT", f"Unknown action: {action}. Supported: create, status")


# ---- registration ----

_TOOL_FNS = {
    "agnes_vision": _agnes_vision,
    "agnes_image_generate": _agnes_image_generate,
    "agnes_video_generate": _agnes_video_generate,
}

_TOOL_DESCRIPTIONS = {
    "agnes_vision": (
        "Analyze an image via Agnes 2.0 Flash (free, public-URL-only, NO base64). "
        "Actions: analyze(image, question?, max_tokens?, temperature?). "
        "Local image files are auto-uploaded to uguu.se (3h auto-delete) to get a public URL. "
        "Use this only when the calling model itself lacks vision — Agnes vision is lower-tier."
    ),
    "agnes_image_generate": (
        "Generate or edit images via Agnes Image 2.0 Flash (free, $0/image). "
        "Actions: generate(prompt, size?, response_format?), edit(prompt, image, size?, response_format?). "
        "size like '1024x1024' or '1024x768'. response_format: 'url' (default) or 'b64_json'."
    ),
    "agnes_video_generate": (
        "Generate video via Agnes Video V2.0 (async task API, $0/second). "
        "Actions: create(prompt, width?, height?, num_frames?, frame_rate?, negative_prompt?, seed?, image?), "
        "status(video_id). create returns video_id; poll status until complete."
    ),
}


def register_agnes_tools(mcp: FastMCP, ctx: ServerContext, only: set[str] | None = None) -> None:
    """Register Agnes tools. If *only* is given, register just those names.

    Used both at server build (only=None → register all enabled) and for
    hot-reload single-tool add (only={name}).
    """
    names = set(only) if only is not None else set(_TOOL_FNS.keys())
    for name in names:
        if name not in _TOOL_FNS:
            continue
        fn = _TOOL_FNS[name]
        desc = _TOOL_DESCRIPTIONS[name]
        mcp.tool(name=name, description=desc)(fn)
