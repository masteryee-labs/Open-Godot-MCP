extends RefCounted
class_name OgmTestSuite

## Base class for MCP-discoverable test suites.
## Docs: 02-Tools/Test.md
##
## Tests are scripts in res://tests/ that extend McpTestSuite.
## Each func test_*() is one test case. Override set_up()/tear_down()
## for per-test fixture lifecycle.
##
## Assert helpers set _last_error on failure; the runner checks
## _last_error after each test to determine pass/fail.

var _last_error: String = ""
var _assert_count: int = 0


func set_up() -> void:
	pass


func tear_down() -> void:
	pass


func assert_true(condition: bool, message: String = "") -> void:
	_assert_count += 1
	if not condition:
		_last_error = "assert_true failed: %s" % (message if not message.is_empty() else "condition was false")


func assert_false(condition: bool, message: String = "") -> void:
	_assert_count += 1
	if condition:
		_last_error = "assert_false failed: %s" % (message if not message.is_empty() else "condition was true")


func assert_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	_assert_count += 1
	if not _variants_equal(actual, expected):
		_last_error = "assert_eq failed: %s — expected %s, got %s" % [message if not message.is_empty() else "values differ", str(expected), str(actual)]


func assert_ne(actual: Variant, expected: Variant, message: String = "") -> void:
	_assert_count += 1
	if _variants_equal(actual, expected):
		_last_error = "assert_ne failed: %s — values are equal: %s" % [message if not message.is_empty() else "unexpected equality", str(actual)]


func assert_approx_eq(actual: float, expected: float, eps: float = 0.001, message: String = "") -> void:
	_assert_count += 1
	if abs(actual - expected) > eps:
		_last_error = "assert_approx_eq failed: %s — expected ~%s (±%s), got %s" % [message if not message.is_empty() else "out of tolerance", str(expected), str(eps), str(actual)]


func assert_not_null(value: Variant, message: String = "") -> void:
	_assert_count += 1
	if value == null:
		_last_error = "assert_not_null failed: %s" % (message if not message.is_empty() else "value was null")


func assert_is_null(value: Variant, message: String = "") -> void:
	_assert_count += 1
	if value != null:
		_last_error = "assert_is_null failed: %s — got %s" % [message if not message.is_empty() else "value was not null", str(value)]


func fail_test(message: String) -> void:
	_last_error = message


func _variants_equal(a: Variant, b: Variant) -> bool:
	# Vector types need type-aware comparison
	if a is Vector2 and b is Vector2:
		return a.is_equal_approx(b)
	if a is Vector3 and b is Vector3:
		return a.is_equal_approx(b)
	if a is Color and b is Color:
		return a.is_equal_approx(b)
	return a == b
