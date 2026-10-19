extends GdUnitTestSuite

var _terminal: Terminal
var _seq: SeqCommand
var _out: AtomSpy

func before_test() -> void:
	_terminal = auto_free(Terminal.new())
	_terminal.model = TerminalModel.new()
	_terminal.model.history_cap = 2
	_terminal.screen = auto_free(Label.new())
	_terminal.out = StringEvent.new()
	_terminal.history = StringListValue.new()
	_terminal.focused = BoolValue.new()
	_terminal.viewing = StringValue.new()
	_terminal.leave = GUIDEAction.new()
	_terminal.terminal_context = GUIDEMappingContext.new()
	_terminal.clear = Event.new()
	_terminal.lean_amount = FloatValue.new()
	_terminal.scroll_rule = auto_free(Label.new())
	_out = AtomSpy.events(_terminal.out)
	_seq = SeqCommand.new()
	_seq.name = "SEQ"
	_seq.out = _terminal.out
	_seq.sequence = StringListValue.new()
	_seq.transmitting = BoolValue.new()
	_terminal.current_pass = TerminalFixture.pass_with([_seq])
	add_child(_terminal)
	_terminal.clear.raise()

func test_submit_echoes_runs_and_draws() -> void:
	_terminal.submit("seq add ack")
	assert_array(_terminal.lines).contains_exactly(["LP4> SEQ ADD ACK", " 1 ACK"])
	assert_array(_terminal.history.value).contains_exactly(["SEQ ADD ACK"])
	assert_str(_terminal.screen.text).contains(" 1 ACK")

func test_unknown_command() -> void:
	_terminal.submit("foo")
	assert_array(_terminal.lines).contains_exactly(["LP4> FOO", "UNKNOWN COMMAND"])

func test_blank_lines_do_nothing() -> void:
	_terminal.submit("   ")
	assert_array(_terminal.lines).is_empty()
	assert_array(_terminal.history.value).is_empty()

func test_history_is_capped() -> void:
	_terminal.submit("seq")
	_terminal.submit("seq clr")
	_terminal.submit("seq add ack")
	assert_array(_terminal.history.value).contains_exactly(["SEQ CLR", "SEQ ADD ACK"])

func test_typing_goes_to_the_editor() -> void:
	_terminal.handle_key(KEY_S, 115)
	_terminal.handle_key(KEY_E, 101)
	_terminal.handle_key(KEY_BACKSPACE, 0)
	assert_str(_terminal.editor.text).is_equal("S")

func test_enter_submits_and_control_keys_do_not_type() -> void:
	_terminal.handle_key(KEY_TAB, 9)
	for character: String in "seq":
		_terminal.handle_key(KEY_A, character.unicode_at(0))
	_terminal.handle_key(KEY_ENTER, 0)
	assert_array(_terminal.lines).contains_exactly(["LP4> SEQ", "SEQUENCE EMPTY"])

func test_only_keys_the_terminal_uses_are_consumed() -> void:
	assert_bool(_terminal.handle_key(KEY_A, 97)).is_true()
	assert_bool(_terminal.handle_key(KEY_ENTER, 0)).is_true()
	assert_bool(_terminal.handle_key(KEY_ESCAPE, 0)).is_false()
	assert_bool(_terminal.handle_key(KEY_F1, 0)).is_false()

func test_greets_when_the_pass_starts() -> void:
	assert_array(_out.calls).contains_exactly([Terminal.GREETING])
	_terminal.focused.value = true
	assert_array(_out.calls).contains_exactly([Terminal.GREETING])

func test_clear_empties_the_screen_but_keeps_the_history() -> void:
	_terminal.submit("seq add ack")
	_terminal.clear.raise()
	assert_array(_terminal.lines).is_empty()
	assert_str(_terminal.screen.text).not_contains("ACK")
	assert_array(_terminal.history.value).contains_exactly(["SEQ ADD ACK"])

func test_escape_closes_the_popup_before_leaving() -> void:
	_terminal.focused.value = true
	_terminal.viewing.value = "USR:/ODA/NOTES"
	_terminal.leave_pressed()
	assert_str(_terminal.viewing.value).is_empty()
	assert_bool(_terminal.focused.value).is_true()
	_terminal.leave_pressed()
	assert_bool(_terminal.focused.value).is_false()

func test_the_wheel_scrolls_three_lines() -> void:
	for n: int in 30:
		_terminal.out.raise("LINE %d" % n)
	assert_bool(_terminal.handle_wheel(MOUSE_BUTTON_WHEEL_UP)).is_true()
	assert_int(_terminal.editor.scroll).is_equal(3)
	assert_str(_terminal.scroll_rule.text).contains(" +3 BELOW ")
	assert_bool(_terminal.handle_wheel(MOUSE_BUTTON_WHEEL_DOWN)).is_true()
	assert_int(_terminal.editor.scroll).is_equal(0)
	assert_bool(_terminal.handle_wheel(MOUSE_BUTTON_LEFT)).is_false()

func test_the_wheel_scrolls_only_fully_leaned_in() -> void:
	for n: int in 30:
		_terminal.out.raise("LINE %d" % n)
	_terminal.focused.value = false
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel.pressed = true
	get_viewport().push_input(wheel)
	assert_int(_terminal.editor.scroll).is_equal(0)
	_terminal.focused.value = true
	_terminal.lean_amount.value = 0.8
	get_viewport().push_input(wheel)
	assert_int(_terminal.editor.scroll).is_equal(0)
	_terminal.lean_amount.value = 1.0
	get_viewport().push_input(wheel)
	assert_int(_terminal.editor.scroll).is_equal(3)
