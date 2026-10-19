extends GdUnitTestSuite

var _help: HelpCommand
var _spy: AtomSpy

func before_test() -> void:
	_help = HelpCommand.new()
	_help.name = "HELP"
	_help.help = "HELP     LIST THE COMMANDS\nHELP <C> DESCRIBE ONE"
	_help.out = StringEvent.new()
	_spy = AtomSpy.events(_help.out)
	var seq := TerminalFixture.command("SEQ", "SEQ ADD <CMD>\nSEQ CLR")
	_help.current_pass = TerminalFixture.pass_with([_help, seq])

func test_lists_each_command_by_its_first_help_line() -> void:
	_help.run(PackedStringArray())
	var expected := ["HELP     LIST THE COMMANDS", "SEQ ADD <CMD>", "HELP <COMMAND> FOR DETAILS"]
	assert_array(_spy.calls).is_equal(expected)

func test_prints_one_commands_help_line_by_line() -> void:
	_help.run(PackedStringArray(["SEQ"]))
	assert_array(_spy.calls).is_equal(["SEQ ADD <CMD>", "SEQ CLR"])

func test_prints_what_a_command_adds_to_its_help() -> void:
	var seq := TerminalFixture.seq(_help.out)
	seq.help = "SEQ CLR"
	_help.current_pass = TerminalFixture.pass_with([_help, seq])
	_help.run(PackedStringArray(["SEQ"]))
	var expected := [
		"SEQ CLR",
		"HERALD COMMANDS:",
		"ACK               DOES ACK",
		"IMG <N>           ▒▒▒▒▒▒▒▒",
	]
	assert_array(_spy.calls).is_equal(expected)

func test_unknown_command() -> void:
	_help.run(PackedStringArray(["FOO"]))
	assert_array(_spy.calls).is_equal(["UNKNOWN COMMAND"])
