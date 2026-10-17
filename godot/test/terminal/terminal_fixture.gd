class_name TerminalFixture
extends RefCounted

## A current pass whose command set holds the given commands.


static func pass_with(commands: Array[Command]) -> ResourceValue:
	var window := PassFixture.window_one()
	window.command_set = CommandSet.new()
	window.command_set.commands = commands
	var current := ResourceValue.new()
	current.value = window
	return current


static func command(command_name: String, help: String) -> Command:
	var stub := Command.new()
	stub.name = command_name
	stub.help = help
	return stub
