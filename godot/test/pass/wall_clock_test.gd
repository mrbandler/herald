extends GdUnitTestSuite

func test_countdown_rounds_up_to_whole_seconds() -> void:
	assert_str(PassMark.new("UPLINK", 42.3).countdown()).is_equal("UPLINK T-00:43")
	assert_str(PassMark.new("BELL", 61.0).countdown()).is_equal("BELL T-01:01")

func test_shows_mission_time_one_day_per_window() -> void:
	var clock: WallClock = auto_free(WallClock.new())
	clock.pass_time = FloatValue.new()
	clock.current_pass = ResourceValue.new()
	clock.current_pass.value = PassFixture.window_one()
	add_child(clock)
	assert_str(clock.text).is_equal("T+ 214Y 077D\n02:40:00")
	clock.pass_time.value = 125.0
	assert_str(clock.text).is_equal("T+ 214Y 077D\n02:42:05")
	var two := PassFixture.window_one()
	two.number = 2
	clock.current_pass.value = two
	clock.pass_time.value = 0.0
	assert_str(clock.text).is_equal("T+ 214Y 078D\n02:40:00")

func test_format_mission_rolls_days_into_years() -> void:
	var seconds := (215.0 * WallClock.YEAR_DAYS + 3.0) * WallClock.DAY + 61.0
	assert_str(WallClock.format_mission(seconds)).is_equal("T+ 215Y 003D\n00:01:01")
