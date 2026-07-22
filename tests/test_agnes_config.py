"""Tests for agnes_config: load, save, git safety, tool-enabled queries."""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from open_godot_mcp import agnes_config as ac


@pytest.fixture
def cfg_path(tmp_path, monkeypatch):
    """Point the config at a tmp_path-based location via HOME/USERPROFILE."""
    monkeypatch.setenv("HOME", str(tmp_path))
    monkeypatch.setenv("USERPROFILE", str(tmp_path))
    return ac.default_config_path()


def test_defaults_all_disabled(cfg_path):
    cfg = ac.load_config()
    assert cfg["agnes"]["enabled"] is False
    assert cfg["nvidia"]["enabled"] is False
    assert ac.all_enabled_tools(cfg) == []


def test_save_then_load_roundtrip(cfg_path):
    cfg = {
        "agnes": {"enabled": True, "api_keys": ["sk-x", "sk-y"], "vision": True, "image_generate": False, "video_generate": True},
        "nvidia": {"enabled": True, "api_keys": ["nv-y"], "vision": False, "image_generate": True},
    }
    report = ac.save_config(cfg)
    assert report.in_git_repo is False  # tmp_path is not a git repo
    loaded = ac.load_config()
    assert loaded["agnes"]["enabled"] is True
    assert loaded["agnes"]["api_keys"] == ["sk-x", "sk-y"]
    assert loaded["nvidia"]["api_keys"] == ["nv-y"]
    # Defaults preserved for unspecified fields
    assert loaded["agnes"]["base_url"].startswith("https://apihub.agnes-ai.com")


def test_backward_compat_single_api_key(cfg_path):
    """Old config with api_key (string) should be converted to api_keys (list)."""
    cfg_path.parent.mkdir(parents=True, exist_ok=True)
    cfg_path.write_text(json.dumps({
        "agnes": {"enabled": True, "api_key": "sk-legacy", "vision": True},
        "nvidia": {"enabled": False, "api_key": "", "vision": False},
    }), encoding="utf-8")
    loaded = ac.load_config()
    assert loaded["agnes"]["api_keys"] == ["sk-legacy"]
    assert loaded["nvidia"]["api_keys"] == []


def test_enabled_tools_listing(cfg_path):
    cfg = {
        "agnes": {"enabled": True, "api_keys": ["k"], "vision": True, "image_generate": True, "video_generate": False},
        "nvidia": {"enabled": True, "api_keys": ["k"], "vision": False, "image_generate": True},
    }
    ac.save_config(cfg)
    loaded = ac.load_config()
    enabled = ac.all_enabled_tools(loaded)
    assert "agnes_vision" in enabled
    assert "agnes_image_generate" in enabled
    assert "agnes_video_generate" not in enabled
    assert "nvidia_vision" not in enabled
    assert "nvidia_image_generate" in enabled


def test_enabled_but_no_key_yields_nothing(cfg_path):
    cfg = {"agnes": {"enabled": True, "api_keys": [], "vision": True}}
    ac.save_config(cfg)
    assert ac.all_enabled_tools(ac.load_config()) == []


def test_multiple_keys_pool(cfg_path):
    """Multiple keys should all be loaded and tools enabled."""
    cfg = {"agnes": {"enabled": True, "api_keys": ["k1", "k2", "k3"], "vision": True}}
    ac.save_config(cfg)
    loaded = ac.load_config()
    assert ac.get_api_keys(loaded["agnes"]) == ["k1", "k2", "k3"]
    assert "agnes_vision" in ac.all_enabled_tools(loaded)


def test_keys_stripped_and_filtered(cfg_path):
    """Empty/whitespace keys should be filtered out."""
    cfg = {"agnes": {"enabled": True, "api_keys": ["k1", "  ", "", "  k2  "], "vision": True}}
    ac.save_config(cfg)
    loaded = ac.load_config()
    assert ac.get_api_keys(loaded["agnes"]) == ["k1", "k2"]


def test_corrupt_file_falls_back_to_defaults(cfg_path):
    cfg_path.parent.mkdir(parents=True, exist_ok=True)
    cfg_path.write_text("{not valid json", encoding="utf-8")
    cfg = ac.load_config()
    assert cfg["agnes"]["enabled"] is False
    assert cfg["nvidia"]["enabled"] is False


def test_git_safety_inside_repo_warns(tmp_path, monkeypatch):
    # Build a fake git repo with a config file inside it, NOT gitignored.
    repo = tmp_path / "myrepo"
    repo.mkdir()
    (repo / ".git").mkdir()  # fake .git dir
    cfg_dir = repo / ".open_godot_mcp"
    cfg_dir.mkdir()
    cfg_file = cfg_dir / "config.json"
    cfg_file.write_text("{}", encoding="utf-8")
    report = ac.check_git_safety(cfg_file)
    assert report.in_git_repo is True
    assert report.gitignore_covers is False
    assert "gitignore" in report.warning.lower()


def test_git_safety_covered_by_gitignore(tmp_path):
    repo = tmp_path / "myrepo"
    repo.mkdir()
    (repo / ".git").mkdir()
    cfg_dir = repo / ".open_godot_mcp"
    cfg_dir.mkdir()
    cfg_file = cfg_dir / "config.json"
    cfg_file.write_text("{}", encoding="utf-8")
    (repo / ".gitignore").write_text(".open_godot_mcp/\n", encoding="utf-8")
    report = ac.check_git_safety(cfg_file)
    assert report.in_git_repo is True
    assert report.gitignore_covers is True
    assert report.warning == ""


def test_git_safety_outside_repo_clean(tmp_path):
    cfg_file = tmp_path / "config.json"  # tmp_path has no .git
    cfg_file.write_text("{}", encoding="utf-8")
    report = ac.check_git_safety(cfg_file)
    assert report.in_git_repo is False
    assert report.warning == ""
