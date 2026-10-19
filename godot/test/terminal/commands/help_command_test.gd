extends GdUnitTestSuite

var _help: HelpCommand
var _spy: AtomSpy

func before_test() -> void:
	_help = HelpCommand.new()
	_help.name = "HELP"
	_help.out = StringEvent.new()
	_spy = AtomSpy.events(_help.out)
	var seq := TerminalFixture.command("SEQ", "SEQ ADD <CMD>\nSEQ CLR")
	_help.current_pass = TerminalFixture.pass_with([_help, seq])

func test_lists_the_commands() -> void:
	_help.run(PackedStringArray())
	assert_array(_spy.calls).is_equal(["COMMANDS: HELP SEQ", "HELP <COMMAND> FOR DETAILS"])

func test_prints_one_commands_help_line_by_line() -> void:
	_help.run(PackedStringArray(["SEQ"]))
	assert_array(_spy.calls).is_equal(["SEQ ADD <CMD>", "SEQ CLR"])

func test_prints_what_a_command_adds_to_its_help() -> void:
	var seq := SeqCommand.new()
	seq.name = "SEQ"
	seq.help = "SEQ CLR"
	seq.allowed = PackedStringArray(["ACK", "RETX"])
	_help.current_pass = TerminalFixture.pass_with([_help, seq])
	_help.run(PackedStringArray(["SEQ"]))
	assert_array(_spy.calls).is_equal(["SEQ CLR", "PROBE COMMANDS: ACK RETX"])

func test_unknown_command() -> void:
	_help.run(PackedStringArray(["FOO"]))
	assert_array(_spy.calls).is_equal(["UNKNOWN COMMAND"])
