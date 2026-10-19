class_name Command
extends Resource

## A terminal command (Strategy). Commands are instant: anything that takes time raises an
## event that a Node handles. Output goes to `out` (stdout).

## What the player types.
@export var name := ""

## Shown by HELP <NAME>, one output line per line break.
@export_multiline var help := ""

## Written. Usually stdout.
@export var out: StringEvent

## The text HELP <NAME> prints. Subclasses append what changes per window.
func help_text() -> String:
	return help

## Executes with the words after the command name. Subclasses override.
func run(_args: PackedStringArray) -> void:
	pass

## Writes one line to `out` (stdout).
func write(line: String) -> void:
	out.raise(line)
