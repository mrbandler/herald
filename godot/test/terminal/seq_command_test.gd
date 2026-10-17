extends GdUnitTestSuite

var _seq: SeqCommand
var _spy: AtomSpy


func before_test() -> void:
	_seq = SeqCommand.new()
	_seq.out = StringEvent.new()
	_seq.sequence = StringListValue.new()
	_seq.transmitting = BoolValue.new()
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


func test_rejects_unknown_probe_commands() -> void:
	_seq.run(PackedStringArray(["ADD", "FOO"]))
	assert_array(_seq.sequence.value).is_empty()
	assert_array(_spy.calls).is_equal(["UNKNOWN PROBE COMMAND"])


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
