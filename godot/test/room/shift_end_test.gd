extends GdUnitTestSuite

## Runs without a Sleep node, so the test never reloads the scene.

var _end: ShiftEnd
var _ended: AtomSpy

func before_test() -> void:
	_end = auto_free(ShiftEnd.new())
	_end.tunables = Tunables.new()
	_end.morning_bell = Event.new()
	_end.shift_ended = Event.new()
	_end.window_number = IntValue.new()
	_end.window_number.value = 1
	_ended = AtomSpy.events(_end.shift_ended)
	add_child(_end)

func test_ends_the_shift_only_once() -> void:
	_end.morning_bell.raise()
	_end.morning_bell.raise()
	assert_int(_ended.calls.size()).is_equal(1)

func test_advances_to_the_next_window() -> void:
	_end.morning_bell.raise()
	assert_int(_end.window_number.value).is_equal(2)

func test_advances_only_once() -> void:
	_end.morning_bell.raise()
	_end.morning_bell.raise()
	assert_int(_end.window_number.value).is_equal(2)

func _require(required: String, sent: bool) -> void:
	var window := PassFixture.window_one()
	window.required = required
	_end.current_pass = ResourceValue.new()
	_end.current_pass.value = window
	_end.last_sent = StringListValue.new()
	_end.last_sent.value = PackedStringArray([required] if sent else [])

func test_a_missed_required_command_keeps_the_window() -> void:
	_require("INSERT", false)
	assert_str(_end.missed_command()).is_equal("INSERT")
	_end.morning_bell.raise()
	assert_int(_end.window_number.value).is_equal(1)

func test_a_sent_required_command_moves_on() -> void:
	_require("INSERT", true)
	assert_str(_end.missed_command()).is_empty()

func test_the_final_window_stays_and_picks_an_ending() -> void:
	_require("", true)
	(_end.current_pass.value as PassWindow).final = true
	_end.last_sent.value = PackedStringArray(["TRANSFER"])
	_end.storage = ResourceListValue.new()
	_end.ending_model = EndingModel.new()
	_end.morning_bell.raise()
	assert_int(_end.window_number.value).is_equal(1)
	assert_str(_end.ending()[0]).is_equal(_end.ending_model.transfer_title)
