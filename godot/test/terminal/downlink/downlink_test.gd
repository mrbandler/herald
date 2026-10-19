extends GdUnitTestSuite

var _downlink: Downlink
var _notices: AtomSpy
var _rows: AtomSpy
var _completions: AtomSpy

func _window(items: Array[ManifestItem]) -> PassWindow:
	var window := PassFixture.window_one()
	window.manifest = items
	return window

func _item(id: int, rows: int) -> ManifestItem:
	var item := ManifestItem.new()
	item.id = id
	item.type = "AUTH"
	item.size = 1
	item.rows = rows
	return item

func before_test() -> void:
	_downlink = auto_free(Downlink.new())
	_downlink.model = DownlinkModel.new()
	_downlink.receiver_model = ReceiverModel.new()
	_downlink.current_pass = ResourceValue.new()
	_downlink.current_pass.value = _window([_item(21, 16), _item(22, 32)])
	_downlink.carrier_present = BoolValue.new()
	_downlink.speak_open = BoolValue.new()
	_downlink.locked = BoolValue.new()
	_downlink.signal_strength = FloatValue.new()
	_downlink.speak_opened = Event.new()
	_downlink.downlink_open = BoolValue.new()
	_downlink.manifest = ResourceListValue.new()
	_downlink.manifest_received = BoolValue.new()
	_downlink.download_queue = ResourceListValue.new()
	_downlink.storage = ResourceListValue.new()
	_downlink.download_received = IntValue.new()
	_downlink.running_item = ResourceValue.new()
	_downlink.shown_item = ResourceValue.new()
	_downlink.monitor_mode = IntValue.new()
	_downlink.progress_line = StringValue.new()
	_downlink.status_notice = StringEvent.new()
	_downlink.out = StringEvent.new()
	_downlink.manifest_arrived = Event.new()
	_downlink.row_received = Event.new()
	_downlink.download_complete = Event.new()
	_notices = AtomSpy.events(_downlink.status_notice)
	_rows = AtomSpy.events(_downlink.row_received)
	_completions = AtomSpy.events(_downlink.download_complete)
	add_child(_downlink)

func _open_and_lock(strength: float = 1.0) -> void:
	_downlink.carrier_present.value = true
	_downlink.locked.value = true
	_downlink.signal_strength.value = strength

func _run(seconds: float) -> void:
	var steps := ceili(seconds * 60.0)
	for _i: int in range(steps):
		_downlink.tick(1.0 / 60.0)

func _receive_manifest() -> void:
	_open_and_lock()
	_run(3.1)

func test_no_push_without_lock_or_downlink() -> void:
	_run(5.0)
	assert_bool(_downlink.manifest_received.value).is_false()
	_downlink.carrier_present.value = true
	_run(5.0)
	assert_bool(_downlink.manifest_received.value).is_false()
	assert_str(_downlink.progress_line.value).is_empty()

func test_a_shut_downlink_leaves_the_line_to_the_uplink() -> void:
	_downlink.progress_line.value = "XMIT SEQ [#---------] 0/1"
	_run(1.0)
	assert_str(_downlink.progress_line.value).is_equal("XMIT SEQ [#---------] 0/1")

func test_push_completes_after_its_seconds() -> void:
	_open_and_lock()
	_run(1.5)
	assert_str(_downlink.progress_line.value).starts_with("RECV MANIFEST [")
	_run(1.6)
	assert_bool(_downlink.manifest_received.value).is_true()
	assert_int(_downlink.manifest.value.size()).is_equal(2)
	assert_array(_notices.calls).contains_exactly(["MANIFEST RECEIVED. 2 ITEMS"])
	assert_str(_downlink.progress_line.value).is_empty()

func test_a_lost_lock_restarts_the_push() -> void:
	_open_and_lock()
	_run(2.5)
	_downlink.locked.value = false
	_run(0.1)
	_downlink.locked.value = true
	_run(2.5)
	assert_bool(_downlink.manifest_received.value).is_false()
	_run(0.6)
	assert_bool(_downlink.manifest_received.value).is_true()

func test_window_without_manifest_stays_idle() -> void:
	var empty: Array[ManifestItem] = []
	_downlink.current_pass.value = _window(empty)
	_receive_manifest()
	assert_bool(_downlink.manifest_received.value).is_false()
	assert_str(_downlink.progress_line.value).is_empty()
	assert_array(_notices.calls).is_empty()

func test_an_item_downloads_with_graded_rows() -> void:
	_receive_manifest()
	_downlink.download_queue.add(_downlink.manifest.value[0])
	_run(7.6)
	assert_int(_downlink.download_received.value).is_equal(8)
	assert_int((_downlink.running_item.value as StoredItem).sent()).is_equal(8)
	assert_str(_downlink.progress_line.value).is_equal("RECV 21 AUTH [#####-----] 8/16")
	assert_int(_downlink.download_queue.value.size()).is_equal(1)
	_downlink.signal_strength.value = 0.1
	_run(7.6)
	assert_int(_completions.calls.size()).is_equal(1)
	assert_int(_downlink.download_queue.value.size()).is_equal(0)
	var stored := _downlink.storage.value[0] as StoredItem
	assert_int(stored.sent()).is_equal(16)
	assert_int(stored.noisy()).is_equal(8)
	assert_int(_rows.calls.size()).is_equal(16)
	assert_str(_notices.calls[-1]).is_equal("21 RECEIVED 16/16. CLEAN 8 NOISY 8 LOST 0")

func test_a_second_download_merges_into_the_stored_copy() -> void:
	_receive_manifest()
	var item := _downlink.manifest.value[0] as ManifestItem
	var lost: Array[int] = []
	lost.resize(16)
	lost.fill(DownlinkModel.Grade.LOST)
	_downlink.storage.add(DownlinkFixture.stored(item, lost))
	_downlink.download_queue.add(item)
	_run(15.2)
	assert_int(_downlink.storage.value.size()).is_equal(1)
	var stored := _downlink.storage.value[0] as StoredItem
	assert_int(stored.clean()).is_equal(16)
	assert_str(_notices.calls[-1]).is_equal("21 RECEIVED 16/16. CLEAN 16 NOISY 0 LOST 0")

func test_rows_without_lock_are_lost() -> void:
	_receive_manifest()
	_downlink.download_queue.add(_downlink.manifest.value[0])
	_downlink.locked.value = false
	_run(1.9)
	assert_int(_downlink.download_received.value).is_equal(0)
	assert_str(_downlink.progress_line.value).is_equal("RECV 21 AUTH [#---------] 0/16")

func test_items_run_one_after_another() -> void:
	_receive_manifest()
	_downlink.download_queue.add(_downlink.manifest.value[0])
	_downlink.download_queue.add(_downlink.manifest.value[1])
	_run(15.1)
	assert_int(_downlink.storage.value.size()).is_equal(1)
	assert_int(_downlink.download_queue.value.size()).is_equal(1)
	_run(15.1)
	assert_int(_downlink.storage.value.size()).is_equal(2)

func test_uplink_cuts_the_running_item_and_drops_the_queue() -> void:
	_receive_manifest()
	_downlink.download_queue.add(_downlink.manifest.value[0])
	_downlink.download_queue.add(_downlink.manifest.value[1])
	_run(8.5)
	_downlink.speak_open.value = true
	_downlink.speak_opened.raise()
	assert_int(_downlink.download_queue.value.size()).is_equal(0)
	var stored := _downlink.storage.value[0] as StoredItem
	assert_int(stored.sent()).is_equal(9)
	assert_str(_notices.calls[-1]).is_equal("21 CUT 9/16. CLEAN 9 NOISY 0 LOST 0")
	assert_int(_completions.calls.size()).is_equal(0)
	assert_bool(_downlink.downlink_open.value).is_false()
	assert_str(_downlink.progress_line.value).is_empty()

func test_uplink_abandons_an_unfinished_push() -> void:
	_open_and_lock()
	_run(1.0)
	_downlink.speak_open.value = true
	_downlink.speak_opened.raise()
	_run(5.0)
	assert_bool(_downlink.manifest_received.value).is_false()
	assert_str(_downlink.progress_line.value).is_empty()

func test_a_cut_before_the_first_row_stores_nothing() -> void:
	_receive_manifest()
	_downlink.download_queue.add(_downlink.manifest.value[0])
	_run(0.5)
	_downlink.speak_open.value = true
	_downlink.speak_opened.raise()
	assert_int(_downlink.storage.value.size()).is_equal(0)
	assert_int(_downlink.download_queue.value.size()).is_equal(0)
	assert_int(_downlink.download_received.value).is_equal(0)
	assert_str(_notices.calls[-1]).is_equal("MANIFEST RECEIVED. 2 ITEMS")

func test_the_next_item_starts_from_zero() -> void:
	_receive_manifest()
	_downlink.download_queue.add(_downlink.manifest.value[0])
	_downlink.download_queue.add(_downlink.manifest.value[1])
	_run(15.1)
	assert_int(_downlink.storage.value.size()).is_equal(1)
	assert_int(_downlink.download_received.value).is_equal(0)

func test_storage_is_written_before_the_queue_drops_the_item() -> void:
	_receive_manifest()
	var item := _downlink.manifest.value[0]
	_downlink.download_queue.add(item)
	var queued_at_store: Array[bool] = []
	_downlink.storage.updated.connect(
		func(_previous: Variant, _current: Variant) -> void:
			queued_at_store.append(_downlink.download_queue.value.has(item)),
	)
	_run(15.1)
	assert_array(queued_at_store).is_equal([true])

func test_the_manifest_is_announced_in_the_terminal_and_rung() -> void:
	var lines := AtomSpy.events(_downlink.out)
	var bells := AtomSpy.events(_downlink.manifest_arrived)
	_receive_manifest()
	assert_array(lines.calls).is_equal(["-- MANIFEST RECEIVED. 2 ITEM(S). TYPE MANIFEST --"])
	assert_int(bells.calls.size()).is_equal(1)

func test_an_image_streams_onto_the_monitor() -> void:
	var image := _item(23, 4)
	image.type = "IMG"
	_downlink.current_pass.value = _window([image])
	_receive_manifest()
	_downlink.download_queue.add(_downlink.manifest.value[0])
	_run(1.0)
	assert_object(_downlink.shown_item.value).is_same(_downlink.running_item.value)
	assert_int(_downlink.monitor_mode.value).is_equal(MonitorModel.Mode.STREAM)
	_run(16.0)
	assert_int(_downlink.monitor_mode.value).is_equal(MonitorModel.Mode.SNOW)
	assert_object(_downlink.shown_item.value).is_null()

func test_text_leaves_the_monitor_alone() -> void:
	_receive_manifest()
	_downlink.download_queue.add(_downlink.manifest.value[0])
	_run(1.0)
	assert_int(_downlink.monitor_mode.value).is_equal(MonitorModel.Mode.SNOW)
	assert_object(_downlink.shown_item.value).is_null()
