extends GdUnitTestSuite

## Runs without a fade node, so the test never reloads the scene.

var _end: ShiftEnd
var _spy: AtomSpy
var _ended: AtomSpy


func before_test() -> void:
	_end = auto_free(ShiftEnd.new())
	_end.tunables = Tunables.new()
	_end.morning_bell = Event.new()
	_end.shift_ended = Event.new()
	_end.acked = BoolValue.new()
	_end.out = StringEvent.new()
	_spy = AtomSpy.events(_end.out)
	_ended = AtomSpy.events(_end.shift_ended)
	add_child(_end)


func test_reports_the_ack_and_ends_the_shift() -> void:
	_end.acked.value = true
	_end.morning_bell.raise()
	assert_array(_spy.calls).is_equal(["HEARTBEAT ACKNOWLEDGED"])
	assert_int(_ended.calls.size()).is_equal(1)


func test_reports_a_missing_ack() -> void:
	_end.morning_bell.raise()
	assert_array(_spy.calls).is_equal(["NO ACK SENT"])
