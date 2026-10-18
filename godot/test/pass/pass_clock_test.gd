extends GdUnitTestSuite

var _clock: PassClock

func before_test() -> void:
	_clock = auto_free(PassClock.new())
	_clock.pass_time = FloatValue.new()
	_clock.shift_ended = Event.new()
	add_child(_clock)
	_clock.set_process(false)

func test_tick_advances_time() -> void:
	_clock.tick(0.5)
	_clock.tick(0.25)
	assert_float(_clock.pass_time.value).is_equal(0.75)

func test_stops_when_the_shift_ends() -> void:
	_clock.tick(1.0)
	_clock.shift_ended.raise()
	_clock.tick(1.0)
	assert_float(_clock.pass_time.value).is_equal(1.0)
