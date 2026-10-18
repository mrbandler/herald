class_name ShiftEnd
extends Node

## At the morning bell (or a pull of the lamp chain): reports the ACK, ends the shift, dims the
## lamp, lets the Listener fall asleep and reloads the room. Greybox stand-in for the tube
## report and the next window.

## Collection of global tunables.
@export var tunables: Tunables

## Starts the end of the shift.
@export var morning_bell: Event

## Raised right after the report, so the clock stops.
@export var shift_ended: Event

## Read. True once the heartbeat ACK was uplinked.
@export var acked: BoolValue

## Receives the ACK report. Usually stdout.
@export var out: StringEvent

## Optional. Falls asleep before the reload. Tests leave it unset.
@export var sleep: Sleep

## Optional. Dimmed to dark while the Listener falls asleep.
@export var lamp: Light3D

## True once the shift has ended, so a second bell or pull does nothing.
var _ended := false

## Listens for the morning bell.
func _ready() -> void:
	morning_bell.raised.connect(_on_bell)

## Reports, ends the shift, then falls asleep and reloads the room.
func _on_bell(_payload: Variant) -> void:
	# The chain and the bell can both fire; the shift ends once.
	if _ended:
		return

	_ended = true

	out.raise("HEARTBEAT ACKNOWLEDGED" if acked.value else "NO ACK SENT")
	shift_ended.raise()

	if sleep == null:
		return

	var tween := create_tween()
	tween.tween_method(sleep.fall, 0.0, 1.0, tunables.shift_fade_seconds)

	if lamp != null:
		tween.parallel().tween_property(lamp, "light_energy", 0.0, tunables.shift_fade_seconds)

	tween.tween_callback(get_tree().reload_current_scene)
