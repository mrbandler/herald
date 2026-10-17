class_name DebugCommands
extends Node

## Debug builds only: LimboConsole commands `skip <seconds>` and `lock` (open the console with `).

## Advanced by `skip`.
@export var pass_time: FloatValue
## Flipped by `lock`.
@export var force_lock: BoolValue


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	LimboConsole.register_command(skip, "skip", "advance pass time by seconds")
	LimboConsole.register_command(toggle_lock, "lock", "toggle the forced lock")


func _exit_tree() -> void:
	# The room reloads every pass; drop the old registrations so the new room can add its own.
	if LimboConsole.has_command("skip"):
		LimboConsole.unregister_command("skip")
	if LimboConsole.has_command("lock"):
		LimboConsole.unregister_command("lock")


## Console command: advances pass time by `seconds`.
func skip(seconds: float) -> void:
	pass_time.value += seconds


## Console command: flips the forced lock.
func toggle_lock() -> void:
	force_lock.value = not force_lock.value
