extends GdUnitTestSuite

var _terminal: Terminal
var _seq: SeqCommand


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
	_seq = SeqCommand.new()
	_seq.name = "SEQ"
	_seq.out = _terminal.out
	_seq.sequence = StringListValue.new()
	_seq.transmitting = BoolValue.new()
	_terminal.current_pass = TerminalFixture.pass_with([_seq])
	add_child(_terminal)


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


func test_greets_once_on_first_focus() -> void:
	_terminal.focused.value = true
	_terminal.focused.value = false
	_terminal.focused.value = true
	assert_array(_terminal.lines).contains_exactly([Terminal.GREETING])


func test_escape_closes_the_popup_before_leaving() -> void:
	_terminal.focused.value = true
	_terminal.viewing.value = "USR:/ODA/NOTES"
	_terminal.leave_pressed()
	assert_str(_terminal.viewing.value).is_empty()
	assert_bool(_terminal.focused.value).is_true()
	_terminal.leave_pressed()
	assert_bool(_terminal.focused.value).is_false()
