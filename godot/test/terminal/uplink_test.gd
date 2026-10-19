extends GdUnitTestSuite

var _uplink: Uplink
var _spy: AtomSpy
var _sent: AtomSpy

func before_test() -> void:
	_uplink = auto_free(Uplink.new())
	_uplink.model = UplinkModel.new()
	_uplink.model.seconds_per_command = 2.0
	_uplink.tx_requested = Event.new()
	_uplink.los = Event.new()
	_uplink.uplinked = Event.new()
	_uplink.sequence = StringListValue.new()
	_uplink.sequence.value = PackedStringArray(["ACK"])
	_uplink.locked = BoolValue.new()
	_uplink.locked.value = true
	_uplink.transmitting = BoolValue.new()
	_uplink.out = StringEvent.new()
	_uplink.progress_line = StringValue.new()
	_uplink.last_sent = StringListValue.new()
	_spy = AtomSpy.events(_uplink.out)
	_sent = AtomSpy.events(_uplink.uplinked)
	add_child(_uplink)
	_uplink.set_process(false)

func test_sends_after_the_transmit_time() -> void:
	_uplink.tx_requested.raise()
	assert_bool(_uplink.transmitting.value).is_true()
	_uplink.tick(1.5)
	assert_array(_sent.calls).is_empty()
	_uplink.tick(1.0)
	assert_bool(_uplink.transmitting.value).is_false()
	assert_array(_uplink.sequence.value).is_empty()
	assert_array(_uplink.last_sent.value).contains_exactly(["ACK"])
	assert_int(_sent.calls.size()).is_equal(1)
	assert_array(_spy.calls).is_equal(["TRANSMITTING...", "1 COMMANDS SENT."])

func test_shows_the_progress_while_sending() -> void:
	_uplink.sequence.value = PackedStringArray(["ACK", "ACK"])
	_uplink.tx_requested.raise()
	assert_str(_uplink.progress_line.value).is_equal("XMIT SEQ [----------] 0/2")
	_uplink.tick(2.5)
	assert_str(_uplink.progress_line.value).is_equal("XMIT SEQ [######----] 1/2")
	_uplink.tick(2.0)
	assert_str(_uplink.progress_line.value).is_empty()

func test_losing_lock_aborts_and_keeps_the_sequence() -> void:
	_uplink.tx_requested.raise()
	_uplink.locked.value = false
	_uplink.tick(5.0)
	assert_bool(_uplink.transmitting.value).is_false()
	assert_array(_uplink.sequence.value).contains_exactly(["ACK"])
	assert_array(_uplink.last_sent.value).is_empty()
	assert_array(_sent.calls).is_empty()
	assert_array(_spy.calls).is_equal(["TRANSMITTING...", "UPLINK FAILED. SIGNAL LOCK LOST"])
	assert_str(_uplink.progress_line.value).is_empty()

func test_los_aborts_and_a_retry_still_sends() -> void:
	_uplink.tx_requested.raise()
	_uplink.los.raise()
	assert_array(_spy.calls).is_equal(["TRANSMITTING...", "UPLINK FAILED. LOS"])
	assert_array(_sent.calls).is_empty()
	assert_bool(_uplink.transmitting.value).is_false()
	assert_array(_uplink.sequence.value).contains_exactly(["ACK"])
	_uplink.tx_requested.raise()
	_uplink.tick(2.5)
	assert_int(_sent.calls.size()).is_equal(1)

func test_duration_scales_with_the_sequence() -> void:
	_uplink.sequence.value = PackedStringArray(["ACK", "ACK"])
	_uplink.tx_requested.raise()
	_uplink.tick(3.9)
	assert_bool(_uplink.transmitting.value).is_true()
	_uplink.tick(0.2)
	assert_bool(_uplink.transmitting.value).is_false()
	assert_str(_spy.calls[-1]).is_equal("2 COMMANDS SENT.")

func test_busy_guard() -> void:
	_uplink.tx_requested.raise()
	_uplink.tx_requested.raise()
	assert_array(_spy.calls).is_equal(["TRANSMITTING...", "TRANSMISSION IN PROGRESS"])
