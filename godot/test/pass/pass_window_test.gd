extends GdUnitTestSuite

const PASS_01 := "res://game/data/passes/pass_01.tres"
const PASS_02 := "res://game/data/passes/pass_02.tres"

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
	var window: PassWindow = load(PASS_01)
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

func test_shipped_window_two_loads_with_ascending_marks() -> void:
	var window: PassWindow = load(PASS_02)
	assert_int(window.number).is_equal(2)
	var times := window.mark_times()
	for i: int in range(1, times.size()):
		assert_float(times[i]).is_greater(times[i - 1])

func test_window_one_has_a_letter_and_window_two_none() -> void:
	var one: PassWindow = load(PASS_01)
	var two: PassWindow = load(PASS_02)
	assert_str(one.letter).starts_with("Seek:")
	assert_str(two.letter).is_empty()

func test_window_two_lists_its_manifest() -> void:
	var two: PassWindow = load(PASS_02)
	assert_int(two.manifest.size()).is_equal(2)
	assert_int(two.manifest[0].id).is_equal(21)
	assert_str(two.manifest[0].type).is_equal("AUTH")
	assert_int(two.manifest[1].rows).is_equal(32)
	var one: PassWindow = load(PASS_01)
	assert_int(one.manifest.size()).is_equal(0)

func test_window_two_offers_the_downlink_commands() -> void:
	var two: PassWindow = load(PASS_02)
	var names := two.command_set.names()
	for command: String in ["HELP", "SEQ", "TX", "CLR", "MANIFEST", "GET", "STAT", "STORE", "DEL"]:
		assert_bool(names.has(command)).override_failure_message(command).is_true()
