extends GdUnitTestSuite

var _uplink: Uplink
var _out: AtomSpy
var _notices: AtomSpy

func before_test() -> void:
	_uplink = auto_free(Uplink.new())
	_uplink.model = UplinkModel.new()
	_uplink.model.seconds_per_command = 2.0
	_uplink.receiver_model = ReceiverModel.new()
	_uplink.tx_requested = Event.new()
	_uplink.los = Event.new()
	_uplink.sequence = StringListValue.new()
	_uplink.sequence.value = PackedStringArray(["ACK"])
	_uplink.locked = BoolValue.new()
	_uplink.locked.value = true
	_uplink.signal_strength = FloatValue.new()
	_uplink.signal_strength.value = 1.0
	_uplink.transmitting = BoolValue.new()
	_uplink.out = StringEvent.new()
	_uplink.status_notice = StringEvent.new()
	_uplink.progress_line = StringValue.new()
	_uplink.last_sent = StringListValue.new()
	_uplink.acked = BoolValue.new()
	_out = AtomSpy.events(_uplink.out)
	_notices = AtomSpy.events(_uplink.status_notice)
	add_child(_uplink)
	_uplink.set_process(false)

func test_sends_after_the_transmit_time() -> void:
	_uplink.tx_requested.raise()
	assert_bool(_uplink.transmitting.value).is_true()
	_uplink.tick(1.5)
	assert_bool(_uplink.acked.value).is_false()
	_uplink.tick(1.0)
	assert_bool(_uplink.transmitting.value).is_false()
	assert_array(_uplink.sequence.value).is_empty()
	assert_array(_uplink.last_sent.value).contains_exactly(["ACK"])
	assert_bool(_uplink.acked.value).is_true()
	assert_array(_notices.calls).is_equal(["SEQ RECEIVED 1/1. HEARTBEAT ACKNOWLEDGED"])
	assert_array(_out.calls).is_empty()

func test_only_ack_is_the_heartbeat() -> void:
	_uplink.sequence.value = PackedStringArray(["RETX 21"])
	_uplink.tx_requested.raise()
	_uplink.tick(2.5)
	assert_bool(_uplink.acked.value).is_false()
	assert_array(_notices.calls).is_equal(["SEQ RECEIVED 1/1"])

func test_a_lost_lock_keeps_what_arrived_and_queues_the_rest() -> void:
	_uplink.sequence.value = PackedStringArray(["ACK", "RETX 21", "RETX 22"])
	_uplink.tx_requested.raise()
	_uplink.tick(3.0)
	_uplink.locked.value = false
	assert_bool(_uplink.transmitting.value).is_false()
	assert_array(_uplink.sequence.value).is_equal(PackedStringArray(["RETX 21", "RETX 22"]))
	assert_array(_uplink.last_sent.value).contains_exactly(["ACK"])
	var expected := "SEQ CUT 1/3. SIGNAL LOCK LOST. HEARTBEAT ACKNOWLEDGED"
	assert_array(_notices.calls).is_equal([expected])
	assert_str(_uplink.progress_line.value).is_empty()

func test_a_dip_below_the_margin_garbles_the_command_in_flight() -> void:
	_uplink.sequence.value = PackedStringArray(["ACK", "RETX 21"])
	_uplink.tx_requested.raise()
	_uplink.signal_strength.value = 0.3
	_uplink.tick(1.0)
	_uplink.signal_strength.value = 1.0
	_uplink.tick(1.0)
	_uplink.tick(2.0)
	assert_bool(_uplink.transmitting.value).is_false()
	assert_array(_uplink.sequence.value).is_equal(PackedStringArray(["ACK"]))
	assert_array(_uplink.last_sent.value).contains_exactly(["RETX 21"])
	assert_bool(_uplink.acked.value).is_false()
	assert_array(_notices.calls).is_equal(["SEQ RECEIVED 1/2. GARBLED 1"])

func test_a_resend_adds_to_what_this_window_received() -> void:
	_uplink.sequence.value = PackedStringArray(["ACK", "RETX 21"])
	_uplink.tx_requested.raise()
	_uplink.tick(2.5)
	_uplink.locked.value = false
	_uplink.locked.value = true
	_uplink.tx_requested.raise()
	_uplink.tick(2.5)
	assert_array(_uplink.last_sent.value).is_equal(PackedStringArray(["ACK", "RETX 21"]))
	assert_array(_uplink.sequence.value).is_empty()

func test_los_cuts_the_send() -> void:
	_uplink.tx_requested.raise()
	_uplink.los.raise()
	assert_bool(_uplink.transmitting.value).is_false()
	assert_array(_uplink.sequence.value).contains_exactly(["ACK"])
	assert_array(_notices.calls).is_equal(["SEQ CUT 0/1. LOS"])
	assert_array(_out.calls).is_equal(["NO ACK SENT"])

func test_los_after_the_ack_reports_nothing() -> void:
	_uplink.acked.value = true
	_uplink.los.raise()
	assert_array(_out.calls).is_empty()
	assert_array(_notices.calls).is_empty()

func test_shows_the_progress_while_sending() -> void:
	_uplink.sequence.value = PackedStringArray(["ACK", "ACK"])
	_uplink.tx_requested.raise()
	assert_str(_uplink.progress_line.value).is_equal("XMIT SEQ [----------] 0/2")
	_uplink.tick(2.5)
	assert_str(_uplink.progress_line.value).is_equal("XMIT SEQ [######----] 1/2")
	_uplink.tick(2.0)
	assert_str(_uplink.progress_line.value).is_empty()

func test_busy_guard() -> void:
	_uplink.tx_requested.raise()
	_uplink.tx_requested.raise()
	assert_array(_out.calls).is_equal(["TRANSMISSION IN PROGRESS"])
