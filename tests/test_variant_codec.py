"""Test variant codec path helpers."""

from open_godot_mcp.utils.variant_codec import (
    ensure_vector2,
    is_color,
    is_node_path,
    is_res_path,
    is_vector2,
    is_vector3,
    require_node_path,
    require_res_path,
)


def test_is_node_path():
    assert is_node_path("/root/Player")
    assert is_node_path("/root/Level/Enemies/Goblin")
    assert not is_node_path("res://player.gd")
    assert not is_node_path("Player")


def test_is_res_path():
    assert is_res_path("res://player.gd")
    assert is_res_path("res://levels/level1.tscn")
    assert not is_res_path("/root/Player")
    assert not is_res_path("player.gd")


def test_require_node_path():
    assert require_node_path("/root/Player") == "/root/Player"
    try:
        require_node_path("res://foo")
        assert False, "should have raised"
    except ValueError:
        pass


def test_require_res_path():
    assert require_res_path("res://foo.gd") == "res://foo.gd"
    try:
        require_res_path("/root/Foo")
        assert False, "should have raised"
    except ValueError:
        pass


def test_is_vector2():
    assert is_vector2({"x": 100, "y": 200})
    assert not is_vector2({"x": 1, "y": 2, "z": 3})
    assert not is_vector2("Vector2(100, 200)")
    assert not is_vector2([100, 200])


def test_is_vector3():
    assert is_vector3({"x": 1, "y": 2, "z": 3})
    assert not is_vector3({"x": 1, "y": 2})


def test_is_color():
    assert is_color({"r": 1.0, "g": 0.5, "b": 0.0, "a": 1.0})
    assert is_color({"r": 1.0, "g": 0.5, "b": 0.0})
    assert not is_color({"x": 1, "y": 2})


def test_ensure_vector2():
    v = ensure_vector2({"x": "100", "y": "200"})
    assert v == {"x": 100.0, "y": 200.0}
    try:
        ensure_vector2("bad")
        assert False, "should have raised"
    except TypeError:
        pass
