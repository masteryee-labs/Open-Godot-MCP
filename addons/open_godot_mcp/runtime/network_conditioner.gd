extends MultiplayerPeerExtension
class_name McpNetworkConditioner

## Network Conditioner — wraps a real MultiplayerPeer to inject
## latency / loss / jitter into multiplayer packets.
## Docs: 05-Network-Testing/Guide.md §網路條件注入
##
## Install via:
##   get_tree().get_multiplayer().set_multiplayer_peer(conditioner)
## The conditioner wraps the original peer; all calls forward to it
## after passing through the condition filter.

var _inner: MultiplayerPeer = null
var _latency_ms: float = 0.0
var _loss_pct: float = 0.0
var _jitter_ms: float = 0.0
var _pending: Array = []  # queued outbound packets: {buffer, send_time}
var _driver: Timer = null


func set_inner(peer: MultiplayerPeer) -> void:
	_inner = peer


func get_inner() -> MultiplayerPeer:
	return _inner


func set_conditions(latency: float, loss: float, jitter: float) -> void:
	_latency_ms = latency
	_loss_pct = loss
	_jitter_ms = jitter


func get_conditions() -> Dictionary:
	return {"latency_ms": _latency_ms, "loss_pct": _loss_pct, "jitter_ms": _jitter_ms}


func _setup_driver() -> void:
	if _driver == null:
		_driver = Timer.new()
		_driver.set_wait_time(0.016)
		_driver.set_autostart(true)
		_driver.timeout.connect(_flush)


func start_driver(parent: Node) -> void:
	_setup_driver()
	if _driver.get_parent() == null:
		parent.add_child(_driver)


func stop_driver() -> void:
	if _driver:
		_driver.queue_free()
		_driver = null


func _flush() -> void:
	if _inner == null:
		return
	var now := Time.get_ticks_msec()
	for i in range(_pending.size() - 1, -1, -1):
		if _pending[i].send_time <= now:
			_inner.put_packet(_pending[i].buffer)
			_pending.remove_at(i)


# ---- MultiplayerPeerExtension GDScript virtual overrides ----
# Use _script variants (designed for GDScript; take PackedByteArray).

func _put_packet_script(p_buffer: PackedByteArray) -> int:
	if _inner == null:
		return FAILED
	if _latency_ms <= 0.0 and _loss_pct <= 0.0 and _jitter_ms <= 0.0:
		return _inner.put_packet(p_buffer)
	if randf() < _loss_pct / 100.0:
		return OK  # Drop silently
	var delay := _latency_ms + randf_range(-_jitter_ms, _jitter_ms)
	if delay <= 0.0:
		return _inner.put_packet(p_buffer)
	_pending.append({"buffer": p_buffer, "send_time": Time.get_ticks_msec() + delay})
	return OK


func _get_packet_script() -> PackedByteArray:
	if _inner == null:
		return PackedByteArray()
	return _inner.get_packet()


func _get_available_packet_count() -> int:
	if _inner == null:
		return 0
	return _inner.get_available_packet_count()


func _get_max_packet_size() -> int:
	if _inner == null:
		return 0
	return _inner.get_max_packet_size()


func _get_connection_status() -> int:
	if _inner == null:
		return MultiplayerPeer.CONNECTION_DISCONNECTED
	return _inner.get_connection_status()


func _set_transfer_channel(p_channel: int) -> void:
	if _inner:
		_inner.set_transfer_channel(p_channel)


func _get_transfer_channel() -> int:
	if _inner:
		return _inner.get_transfer_channel()
	return 0


func _set_transfer_mode(p_mode: int) -> void:
	if _inner:
		_inner.set_transfer_mode(p_mode)


func _get_transfer_mode() -> int:
	if _inner:
		return _inner.get_transfer_mode()
	return MultiplayerPeer.TRANSFER_MODE_RELIABLE


func _set_refuse_new_connections(p_refuse: bool) -> void:
	if _inner:
		_inner.set_refuse_new_connections(p_refuse)


func _is_refusing_new_connections() -> bool:
	if _inner:
		return _inner.is_refusing_new_connections()
	return true


func _is_server() -> bool:
	if _inner:
		return _inner.is_server()
	return false


func _get_unique_id() -> int:
	if _inner:
		return _inner.get_unique_id()
	return 1


func _set_target_peer(p_peer: int) -> void:
	if _inner:
		_inner.set_target_peer(p_peer)


func _poll() -> void:
	if _inner:
		_inner.poll()


func _close() -> void:
	if _inner:
		_inner.close()
	_pending.clear()


func _disconnect_peer(p_peer: int, p_force: bool) -> void:
	if _inner:
		_inner.disconnect_peer(p_peer, p_force)


func _get_packet_channel() -> int:
	if _inner:
		return _inner.get_packet_channel()
	return 0


func _get_packet_mode() -> int:
	if _inner:
		return _inner.get_packet_mode()
	return MultiplayerPeer.TRANSFER_MODE_RELIABLE


func _get_packet_peer() -> int:
	if _inner:
		return _inner.get_packet_peer()
	return 0
