class_name SeqCommand
extends Command

## SEQ lists the probe sequence, SEQ ADD <CMD> queues a probe command, SEQ CLR clears it.

## The queued probe commands. Written by SEQ ADD and SEQ CLR.
@export var sequence: StringListValue

## Read. SEQ ADD and SEQ CLR are refused while true.
@export var transmitting: BoolValue

## Probe commands SEQ ADD accepts in this window.
@export var allowed := PackedStringArray(["ACK"])

## The help, then the probe commands SEQ ADD accepts in this window.
func help_text() -> String:
	return help + "\nPROBE COMMANDS: " + " ".join(allowed)

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

## Appends `words` as one entry, if the probe command is allowed in this window.
func _add(words: PackedStringArray) -> void:
	if words.is_empty():
		write("USAGE: SEQ ADD <CMD>")
		return

	if not allowed.has(words[0]):
		write("UNKNOWN PROBE COMMAND")
		return

	var entry := " ".join(words)
	sequence.value = sequence.value + PackedStringArray([entry])
	write(" %d %s" % [sequence.value.size(), entry])
