class_name HelpCommand
extends Command

## HELP lists the window's commands, one line each with what it does, and the ones a later window
## unlocks blacked out as LOCKED; HELP <CMD> prints that command's help.
## Reads the set through current_pass, so no .tres references the set that contains it.

## Read. The window whose commands HELP lists.
@export var current_pass: ResourceValue

## With no args lists each command by the first line of its help, with a name prints that
## command's help.
func run(args: PackedStringArray) -> void:
	var window := current_pass.value as PassWindow
	var commands := window.command_set

	if args.is_empty():
		for listed: Command in commands.commands:
			if not listed.hidden:
				write(_line(listed, window))

		write("HELP <COMMAND> FOR DETAILS")

		return

	var command := commands.find(args[0])
	if command == null or command.hidden:
		write("UNKNOWN COMMAND")

		return

	if command.locked_in(window):
		write("%s LOCKED" % command.name)

		return

	for line: String in command.help_text().split("\n"):
		write(line)

## `command`'s first help line, or its name blacked out as LOCKED before its window.
func _line(command: Command, window: PassWindow) -> String:
	if command.locked_in(window):
		return "%-18s%s" % [SeqCommand.BLOCK.repeat(command.name.length()), "LOCKED"]

	return command.help.get_slice("\n", 0)
