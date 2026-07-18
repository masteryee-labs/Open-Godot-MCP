"""Variant codec — encode/decode Godot Variant types to/from JSON.

Implements the JSON encoding table in Docs/02-Tools/Index.md §Godot 型別的 JSON 編碼.

Godot types are encoded as JSON **objects** (not strings or arrays):
  Vector2      -> {"x": float, "y": float}
  Vector3      -> {"x": float, "y": float, "z": float}
  Color        -> {"r": float, "g": float, "b": float, "a": float}
  Rect2        -> {"x", "y", "width", "height"}
  Quaternion   -> {"x", "y", "z", "w"}
  Transform2D  -> {"rotation", "scale": Vector2, "origin": Vector2}
  Basis        -> {"x": Vector3, "y": Vector3, "z": Vector3}
  NodePath     -> str
  Array        -> JSON array
  Dictionary   -> JSON object
  primitives   -> JSON native

The Python side only deals with JSON already decoded from the wire; the
GDScript side (variant_codec.gd) does the actual Variant <-> dict conversion.
Here we provide validation + light normalization for inbound params.
"""

from __future__ import annotations

from typing import Any

# ---- Inbound validation helpers (params coming from the AI client) ----

def is_vector2(v: Any) -> bool:
    return isinstance(v, dict) and "x" in v and "y" in v and "z" not in v


def is_vector3(v: Any) -> bool:
    return isinstance(v, dict) and "x" in v and "y" in v and "z" in v


def is_color(v: Any) -> bool:
    return isinstance(v, dict) and {"r", "g", "b"} <= set(v.keys())


def is_rect2(v: Any) -> bool:
    return isinstance(v, dict) and {"x", "y", "width", "height"} <= set(v.keys())


def ensure_vector2(v: Any, *, name: str = "value") -> dict[str, float]:
    """Validate that *v* is a Vector2-shaped dict and return it with float coords."""
    if not is_vector2(v):
        raise TypeError(f"{name} must be a Vector2 object {{x, y}}, got: {v!r}")
    return {"x": float(v["x"]), "y": float(v["y"])}


def ensure_vector3(v: Any, *, name: str = "value") -> dict[str, float]:
    if not is_vector3(v):
        raise TypeError(f"{name} must be a Vector3 object {{x, y, z}}, got: {v!r}")
    return {"x": float(v["x"]), "y": float(v["y"]), "z": float(v["z"])}


def ensure_color(v: Any, *, name: str = "value") -> dict[str, float]:
    if not is_color(v):
        raise TypeError(f"{name} must be a Color object {{r, g, b, a?}}, got: {v!r}")
    out = {"r": float(v["r"]), "g": float(v["g"]), "b": float(v["b"])}
    out["a"] = float(v.get("a", 1.0))
    return out


def ensure_rect2(v: Any, *, name: str = "value") -> dict[str, float]:
    if not is_rect2(v):
        raise TypeError(f"{name} must be a Rect2 object {{x, y, width, height}}, got: {v!r}")
    return {
        "x": float(v["x"]),
        "y": float(v["y"]),
        "width": float(v["width"]),
        "height": float(v["height"]),
    }


# ---- Path format helpers (see Index.md §路徑參數的三種格式) ----

def is_node_path(p: Any) -> bool:
    """Node paths look like ``/root/...``."""
    return isinstance(p, str) and p.startswith("/root")


def is_res_path(p: Any) -> bool:
    """Resource paths look like ``res://...``."""
    return isinstance(p, str) and p.startswith("res://")


def is_filesystem_path(p: Any) -> bool:
    """Filesystem paths are absolute or res:// (for filesystem tools)."""
    return isinstance(p, str) and (is_res_path(p) or _is_absolute(p))


def _is_absolute(p: str) -> bool:
    if not p:
        return False
    # POSIX absolute or Windows drive letter
    return p.startswith("/") or (len(p) >= 2 and p[1] == ":") or p.startswith("\\\\")


def require_node_path(p: Any, *, name: str = "node_path") -> str:
    if not is_node_path(p):
        raise ValueError(f"{name} must be a node path '/root/...', got: {p!r}")
    return p


def require_res_path(p: Any, *, name: str = "path") -> str:
    if not is_res_path(p):
        raise ValueError(f"{name} must be a res:// path, got: {p!r}")
    return p


def require_path(p: Any, *, name: str = "path") -> str:
    """Accept either res:// or a filesystem path."""
    if not isinstance(p, str) or not p:
        raise ValueError(f"{name} must be a non-empty path string, got: {p!r}")
    return p
