class_name Command
extends Resource

## A terminal command (Strategy). Commands are instant: anything that takes time raises an
## event that a Node handles. Output goes to `out` (stdout).

## What the player types.
@export var name := ""

## Shown by HELP <NAME>, one output line per line break.
@export_multiline var help := ""

## Left out of HELP, and HELP <NAME> treats it as unknown. For commands players find.
@export var hidden := false

## The window from which it works. Before it, HELP shows it blacked out as LOCKED and typing it
## answers LOCKED: the station holds more than the Listener may use yet.
@export var unlocked_in := 1

## Written. Usually stdout.
@export var out: StringEvent

## True while `window` comes before the one that unlocks it.
func locked_in(window: PassWindow) -> bool:
	return window.number < unlocked_in

## The text HELP <NAME> prints. Subclasses append what changes per window.
func help_text() -> String:
	return help

## Executes with the words after the command name. Subclasses override.
func run(_args: PackedStringArray) -> void:
	pass

## Writes one line to `out` (stdout).
func write(line: String) -> void:
	out.raise(line)
