class_name DebugCommands
extends Node

## Debug builds only: LimboConsole commands `skip <seconds>`, `lock` and `window <n>`
## (open the console with `).

## Advanced by `skip`.
@export var pass_time: FloatValue

## Flipped by `lock`.
@export var force_lock: BoolValue

## Set by `window`. The room load picks the window by it.
@export var window_number: IntValue

## Registers the console commands, or removes itself outside debug builds.
func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return

	LimboConsole.register_command(skip, "skip", "advance pass time by seconds")
	LimboConsole.register_command(toggle_lock, "lock", "toggle the forced lock")
	LimboConsole.register_command(window_command, "window", "jump to window n (reloads the room)")

## Unregisters the console commands.
func _exit_tree() -> void:
	# The room reloads every pass; drop the old registrations so the new room can add its own.
	if LimboConsole.has_command("skip"):
		LimboConsole.unregister_command("skip")

	if LimboConsole.has_command("lock"):
		LimboConsole.unregister_command("lock")

	if LimboConsole.has_command("window"):
		LimboConsole.unregister_command("window")

## Console command: advances pass time by `seconds`.
func skip(seconds: float) -> void:
	pass_time.value += seconds

## Console command: flips the forced lock.
func toggle_lock() -> void:
	force_lock.value = not force_lock.value

## Sets the window to load next. Refuses numbers below 1 and returns whether it changed it.
func jump_to_window(n: int) -> bool:
	if n < 1:
		return false

	window_number.value = n
	return true

## Console command: jumps to window `n` and reloads the room. The only command that reloads.
func window_command(n: int) -> void:
	if not jump_to_window(n):
		LimboConsole.error("WINDOW MUST BE 1 OR MORE")
		return

	get_tree().reload_current_scene()
