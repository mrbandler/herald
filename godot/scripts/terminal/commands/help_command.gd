class_name HelpCommand
extends Command

## HELP lists the window's commands, one line each with what it does, and the ones a later window
## unlocks blacked out as LOCKED; HELP <CMD> prints that command's help. Locked commands come
## first, the latest to unlock on top; the open ones follow, the newest last, right above the
## prompt. Within a window the set's order ranks them by importance.
## Reads the set through current_pass, so no .tres references the set that contains it.

## Read. The window whose commands HELP lists.
@export var current_pass: ResourceValue

## With no args lists each command by the first line of its help, with a name prints that
## command's help.
func run(args: PackedStringArray) -> void:
	var window := current_pass.value as PassWindow
	var commands := window.command_set

	if args.is_empty():
		for listed: Command in listing(commands.commands, window):
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

## The commands HELP lists for `window`, in order: locked ones by their unlock window, latest
## first, then open ones by their unlock window, earliest first; ties keep the set's order.
func listing(commands: Array[Command], window: PassWindow) -> Array[Command]:
	var shown: Array[Command] = []
	for command: Command in commands:
		if not command.hidden:
			shown.append(command)

	var rank := func(command: Command) -> Vector3i:
		var locked := command.locked_in(window)
		var when := -command.unlocked_in if locked else command.unlocked_in
		return Vector3i(0 if locked else 1, when, shown.find(command))

	shown.sort_custom(
		func(a: Command, b: Command) -> bool:
			return rank.call(a) < rank.call(b),
	)
	return shown
