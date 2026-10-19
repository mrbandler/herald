extends GdUnitTestSuite

func test_countdown_rounds_up_to_whole_seconds() -> void:
	assert_str(PassMark.new("UPLINK", 42.3).countdown()).is_equal("UPLINK T-00:43")
	assert_str(PassMark.new("BELL", 61.0).countdown()).is_equal("BELL T-01:01")

func test_shows_station_time_before_los() -> void:
	var clock: WallClock = auto_free(WallClock.new())
	clock.pass_time = FloatValue.new()
	clock.current_pass = ResourceValue.new()
	clock.current_pass.value = PassFixture.window_one()
	add_child(clock)
	assert_str(clock.text).is_equal("02:40")
	clock.pass_time.value = 100.0
	assert_str(clock.text).is_equal("02:41")

func test_format_time_of_day() -> void:
	assert_str(WallClock.format_time(9600.0)).is_equal("02:40")
	assert_str(WallClock.format_time(9659.9)).is_equal("02:40")
	assert_str(WallClock.format_time(86400.0 + 60.0)).is_equal("00:01")

func test_shows_station_time_after_los() -> void:
	var clock: WallClock = auto_free(WallClock.new())
	clock.pass_time = FloatValue.new()
	clock.current_pass = ResourceValue.new()
	clock.current_pass.value = PassFixture.window_one()
	add_child(clock)
	clock.pass_time.value = 125.0
	assert_str(clock.text).is_equal("02:51")
