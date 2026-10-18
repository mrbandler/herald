extends GdUnitTestSuite

func test_next_mark_before_aos() -> void:
	var mark := PassFixture.window_one().next_mark(10.0)
	assert_str(mark.name).is_equal("AOS")
	assert_float(mark.remaining).is_equal(20.0)

func test_landing_on_a_mark_points_at_the_next_one() -> void:
	var mark := PassFixture.window_one().next_mark(30.0)
	assert_str(mark.name).is_equal("UPLINK")
	assert_float(mark.remaining).is_equal(65.0)

func test_between_speak_and_los() -> void:
	var mark := PassFixture.window_one().next_mark(100.0)
	assert_str(mark.name).is_equal("LOS")
	assert_float(mark.remaining).is_equal(15.0)

func test_shipped_window_one_loads_with_ascending_marks() -> void:
	var window: PassWindow = load("res://game/data/passes/pass_01.tres")
	assert_int(window.number).is_equal(1)
	var times := window.mark_times()
	for i: int in range(1, times.size()):
		assert_float(times[i]).is_greater(times[i - 1])

func test_landing_on_the_bell_stays_at_bell_zero() -> void:
	var mark := PassFixture.window_one().next_mark(175.0)
	assert_str(mark.name).is_equal("BELL")
	assert_float(mark.remaining).is_equal(0.0)

func test_after_the_bell_stays_at_bell_zero() -> void:
	var mark := PassFixture.window_one().next_mark(200.0)
	assert_str(mark.name).is_equal("BELL")
	assert_float(mark.remaining).is_equal(0.0)

func test_station_time_runs_faster_after_los() -> void:
	var window := PassFixture.window_one()
	assert_float(window.station_time(0.0)).is_equal(9600.0)
	assert_float(window.station_time(115.0)).is_equal(9715.0)
	assert_float(window.station_time(175.0)).is_equal(9715.0 + 60.0 * 60.0)
