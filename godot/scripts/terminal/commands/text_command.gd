class_name TextCommand
extends Command

## A command that only prints its text, one output line per line break. For easter eggs.

## What it prints.
@export_multiline var text := ""

## Prints the text, whatever follows the command.
func run(_args: PackedStringArray) -> void:
	for line: String in text.split("\n"):
		write(line)
