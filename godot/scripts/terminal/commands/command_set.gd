class_name CommandSet
extends Resource

## The commands available in one window.

## The commands, in the order HELP lists them.
@export var commands: Array[Command] = []

## The command with this name, or null.
func find(command_name: String) -> Command:
	for command: Command in commands:
		if command.name == command_name:
			return command

	return null

## All command names, in order.
func names() -> PackedStringArray:
	var result := PackedStringArray()
	for command: Command in commands:
		result.append(command.name)

	return result
