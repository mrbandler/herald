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

func test_window_papers_carry_the_letter_the_prayer_and_a_capsule() -> void:
	var one: PassWindow = load(PASS_01)
	var two: PassWindow = load(PASS_02)
	assert_int(one.papers.size()).is_equal(2)
	assert_str(one.papers[0].body()).contains("SEQ ADD ACK")
	var prayer := one.papers[1].text_for(one)
	assert_str(prayer).contains("AZ 214.6  EL 38.2")
	assert_str(prayer).contains("DIAL 52")
	assert_str(two.papers[0].text_for(two)).contains("AZ 221.3  EL 41.7")
	assert_float(two.papers[0].arrives_at).is_equal(0.0)
	assert_float(two.papers[1].arrives_at).is_between(1.0, two.aos)

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
	for command: String in [
		"HELP",
		"SEQ",
		"TX",
		"CLR",
		"MANIFEST",
		"GET",
		"STAT",
		"STORE",
		"DEL",
		"MOD",
		"UNLOCK",
		"LS",
		"CD",
		"READ",
		"SHOW",
		"DECODE",
		"VRFY",
		"TAG",
	]:
		assert_bool(names.has(command)).override_failure_message(command).is_true()

func test_window_two_key_and_telemetry() -> void:
	var two: PassWindow = load(PASS_02)
	assert_str(two.manifest[0].note).is_equal("KEY TLM")
	assert_str(two.manifest[0].key_for).is_equal("TLM")
	var clean: Array[int] = []
	clean.resize(two.manifest[1].rows)
	clean.fill(DownlinkModel.Grade.CLEAN)
	var stored := DownlinkFixture.stored(two.manifest[1], clean)
	assert_int(ModuleModel.new().decode_lines(stored).size()).is_equal(8)
	assert_str(two.manifest[1].content).starts_with("HERALD TELEMETRY")

func test_window_three_sends_pictures() -> void:
	var three: PassWindow = load("res://game/data/passes/pass_03.tres")
	assert_int(three.number).is_equal(3)
	var types := PackedStringArray()
	for item: ManifestItem in three.manifest:
		types.append(item.type)
	assert_array(types).is_equal(PackedStringArray(["AUTH", "CAL", "IMG", "TLM"]))
	assert_str(three.manifest[0].key_for).is_equal("IMG")
	assert_object(three.manifest[2].image).is_not_null()
	assert_str(three.papers[0].text_for(three)).contains("AZ 226.8  EL 44.1")
	assert_int(three.papers[1].slot).is_equal(3)
	assert_float(three.papers[2].arrives_at).is_greater(0.0)
