class_name ShiftEnd
extends Node

## At the morning bell: reports the ACK, ends the shift, fades out and reloads the room.
## Greybox stand-in for the tube report and the next window.

@export var tunables: Tunables
## Starts the end of the shift.
@export var morning_bell: Event
## Raised right after the report, so the clock stops.
@export var shift_ended: Event
## Read. True once the heartbeat ACK was uplinked.
@export var acked: BoolValue
@export var out: StringEvent
## Optional. Faded to black before the reload. Tests leave it unset.
@export var fade: ColorRect


func _ready() -> void:
	morning_bell.raised.connect(_on_bell)


func _on_bell(_payload: Variant) -> void:
	out.raise("HEARTBEAT ACKNOWLEDGED" if acked.value else "NO ACK SENT")
	shift_ended.raise()
	if fade == null:
		return
	var tween := create_tween()
	tween.tween_property(fade, "color:a", 1.0, tunables.shift_fade_seconds)
	tween.tween_callback(get_tree().reload_current_scene)
