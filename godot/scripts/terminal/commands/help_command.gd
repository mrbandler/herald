class_name HelpCommand
extends Command

## HELP lists the window's commands, one line each with what it does; HELP <CMD> prints that
## command's help.
## Reads the set through current_pass, so no .tres references the set that contains it.

## Read. The window whose commands HELP lists.
@export var current_pass: ResourceValue

## With no args lists each command by the first line of its help, with a name prints that
## command's help.
func run(args: PackedStringArray) -> void:
	var commands := (current_pass.value as PassWindow).command_set

	if args.is_empty():
		for listed: Command in commands.commands:
			write(listed.help.get_slice("\n", 0))

		write("HELP <COMMAND> FOR DETAILS")

		return

	var command := commands.find(args[0])
	if command == null:
		write("UNKNOWN COMMAND")

		return

	for line: String in command.help_text().split("\n"):
		write(line)
