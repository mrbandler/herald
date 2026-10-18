class_name ClrCommand
extends Command

## CLR clears the terminal screen. The command history is kept.

## Raised to empty the screen. The terminal listens.
@export var cleared: Event

## Clears the screen, or writes the usage when given arguments.
func run(args: PackedStringArray) -> void:
	if not args.is_empty():
		write("USAGE: CLR")
		return

	cleared.raise()
