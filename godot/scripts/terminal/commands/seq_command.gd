class_name SeqCommand
extends Command

## SEQ lists the HERALD sequence, SEQ ADD <CMD> queues a HERALD command, SEQ CLR clears it.

## Blacks out the hidden part of a locked command in HELP SEQ.
const BLOCK := "▒"

## The queued HERALD commands. Written by SEQ ADD and SEQ CLR.
@export var sequence: StringListValue

## Read. SEQ ADD and SEQ CLR are refused while true.
@export var transmitting: BoolValue

## Every command HERALD accepts, in the order HELP SEQ lists them.
@export var herald_commands: Array[HeraldCommand] = []

## Read. Modules unlocked so far. A HERALD command unlocked by one waits for it.
@export var unlocked_modules: StringListValue

## The help, then every HERALD command: whole once unlocked, without its description while
## locked, and blacked out entirely while hidden.
func help_text() -> String:
	var lines := PackedStringArray([help, "HERALD COMMANDS:"])
	for command: HeraldCommand in herald_commands:
		lines.append(_help_line(command))

	return "\n".join(lines)

## Lists the sequence, or adds to it or clears it by subcommand.
func run(args: PackedStringArray) -> void:
	if args.is_empty():
		_list()
		return

	if args[0] != "ADD" and args[0] != "CLR":
		write("USAGE: SEQ [ADD <CMD> | CLR]")
		return

	if transmitting.value:
		write("TRANSMISSION IN PROGRESS")
		return

	if args[0] == "CLR":
		sequence.value = PackedStringArray()
		write("SEQUENCE CLEARED")
		return

	_add(args.slice(1))

## Writes the numbered sequence, or SEQUENCE EMPTY.
func _list() -> void:
	if sequence.value.is_empty():
		write("SEQUENCE EMPTY")
		return

	for i: int in range(sequence.value.size()):
		write(" %d %s" % [i + 1, sequence.value[i]])

## Appends `words` as one entry, if HERALD knows the command and it is unlocked.
func _add(words: PackedStringArray) -> void:
	if words.is_empty():
		write("USAGE: SEQ ADD <CMD>")
		return

	var command := _find(words[0])
	if command == null or (command.hidden and not _unlocked(command)):
		write("UNKNOWN HERALD COMMAND")
		return

	if not _unlocked(command):
		write("%s LOCKED" % command.name)
		return

	var entry := " ".join(words)
	sequence.value = sequence.value + PackedStringArray([entry])
	write(" %d %s" % [sequence.value.size(), entry])

## The HERALD command called `command_name`, or null.
func _find(command_name: String) -> HeraldCommand:
	for command: HeraldCommand in herald_commands:
		if command.name == command_name:
			return command

	return null

## True when nothing unlocks `command` or what unlocks it has been unlocked.
func _unlocked(command: HeraldCommand) -> bool:
	return command.unlocked_by.is_empty() or unlocked_modules.value.has(command.unlocked_by)

## `command`'s usage and description, its usage alone while locked, or blocks while hidden.
func _help_line(command: HeraldCommand) -> String:
	var blocked := BLOCK.repeat(command.description.length())
	if _unlocked(command):
		return "%-18s%s" % [command.usage, command.description]

	if command.hidden:
		return "%-18s%s" % [BLOCK.repeat(command.usage.length()), blocked]

	return "%-18s%s" % [command.usage, blocked]
