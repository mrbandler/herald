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

static func herald(command_name: String, usage: String, unlocked_by: String = "") -> HeraldCommand:
	var herald_command := HeraldCommand.new()
	herald_command.name = command_name
	herald_command.usage = usage
	herald_command.description = "DOES " + command_name
	herald_command.unlocked_by = unlocked_by
	return herald_command

static func seq(out: StringEvent) -> SeqCommand:
	var seq_command := SeqCommand.new()
	seq_command.name = "SEQ"
	seq_command.out = out
	seq_command.sequence = StringListValue.new()
	seq_command.transmitting = BoolValue.new()
	seq_command.unlocked_modules = StringListValue.new()
	seq_command.last_sent = StringListValue.new()
	seq_command.herald_commands = [herald("ACK", "ACK"), herald("IMG", "IMG <N>", "IMG")]
	return seq_command

static func command(command_name: String, help: String) -> Command:
	var stub := Command.new()
	stub.name = command_name
	stub.help = help
	return stub
