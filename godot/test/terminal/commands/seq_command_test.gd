extends GdUnitTestSuite

var _seq: SeqCommand
var _spy: AtomSpy

func before_test() -> void:
	_seq = TerminalFixture.seq(StringEvent.new())
	_spy = AtomSpy.events(_seq.out)

func test_add_appends_an_allowed_command() -> void:
	_seq.run(PackedStringArray(["ADD", "ACK"]))
	assert_array(_seq.sequence.value).contains_exactly(["ACK"])
	assert_array(_spy.calls).is_equal([" 1 ACK"])

func test_lists_numbered_entries() -> void:
	_seq.run(PackedStringArray(["ADD", "ACK"]))
	_seq.run(PackedStringArray(["ADD", "ACK"]))
	_spy.calls.clear()
	_seq.run(PackedStringArray())
	assert_array(_spy.calls).is_equal([" 1 ACK", " 2 ACK"])

func test_empty_sequence() -> void:
	_seq.run(PackedStringArray())
	assert_array(_spy.calls).is_equal(["SEQUENCE EMPTY"])

func test_rejects_unknown_herald_commands() -> void:
	_seq.run(PackedStringArray(["ADD", "FOO"]))
	assert_array(_seq.sequence.value).is_empty()
	assert_array(_spy.calls).is_equal(["UNKNOWN HERALD COMMAND"])

func test_a_command_waits_for_its_module() -> void:
	_seq.run(PackedStringArray(["ADD", "IMG", "4"]))
	_seq.unlocked_modules.value = PackedStringArray(["IMG"])
	_seq.run(PackedStringArray(["ADD", "IMG", "4"]))
	assert_array(_seq.sequence.value).contains_exactly(["IMG 4"])
	assert_array(_spy.calls).is_equal(["IMG LOCKED", " 1 IMG 4"])

func test_a_hidden_command_stays_unknown_and_blacked_out_until_unlocked() -> void:
	var descend := TerminalFixture.herald("DESCEND", "DESCEND", "DESCEND")
	descend.hidden = true
	_seq.herald_commands.append(descend)
	_seq.run(PackedStringArray(["ADD", "DESCEND"]))
	assert_array(_spy.calls).is_equal(["UNKNOWN HERALD COMMAND"])
	assert_str(_seq.help_text()).ends_with("▒▒▒▒▒▒▒           ▒▒▒▒▒▒▒▒▒▒▒▒")
	_seq.unlocked_modules.value = PackedStringArray(["DESCEND"])
	assert_str(_seq.help_text()).ends_with("DESCEND           DOES DESCEND")

func test_help_shows_an_unlocked_command_whole() -> void:
	_seq.unlocked_modules.value = PackedStringArray(["IMG"])
	assert_str(_seq.help_text()).ends_with("IMG <N>           DOES IMG")

func test_add_without_a_command_shows_usage() -> void:
	_seq.run(PackedStringArray(["ADD"]))
	assert_array(_spy.calls).is_equal(["USAGE: SEQ ADD <CMD>"])

func test_clear() -> void:
	_seq.run(PackedStringArray(["ADD", "ACK"]))
	_spy.calls.clear()
	_seq.run(PackedStringArray(["CLR"]))
	assert_array(_seq.sequence.value).is_empty()
	assert_array(_spy.calls).is_equal(["SEQUENCE CLEARED"])

func test_other_subcommands_show_usage() -> void:
	_seq.run(PackedStringArray(["DROP"]))
	assert_array(_spy.calls).is_equal(["USAGE: SEQ [ADD <CMD> | CLR]"])

func test_locked_while_transmitting() -> void:
	_seq.transmitting.value = true
	_seq.run(PackedStringArray(["ADD", "ACK"]))
	_seq.run(PackedStringArray(["CLR"]))
	assert_array(_seq.sequence.value).is_empty()
	assert_array(_spy.calls).is_equal(["TRANSMISSION IN PROGRESS", "TRANSMISSION IN PROGRESS"])
