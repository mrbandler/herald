extends GdUnitTestSuite


func test_format_rounds_up_to_whole_seconds() -> void:
	assert_str(WallClock.format(PassMark.new("SPEAK", 42.3))).is_equal("SPEAK T-00:43")
	assert_str(WallClock.format(PassMark.new("BELL", 61.0))).is_equal("BELL T-01:01")


func test_shows_the_next_mark() -> void:
	var clock: WallClock = auto_free(WallClock.new())
	clock.pass_time = FloatValue.new()
	clock.current_pass = ResourceValue.new()
	clock.current_pass.value = PassFixture.window_one()
	add_child(clock)
	assert_str(clock.text).is_equal("AOS T-00:30")
	clock.pass_time.value = 100.0
	assert_str(clock.text).is_equal("LOS T-00:15")
