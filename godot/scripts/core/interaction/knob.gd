class_name Knob
extends Interactable

## A grabbable knob or handwheel that writes a FloatValue.

## The value this knob writes.
@export var target: FloatValue
@export var model: KnobModel
## Spins around its local Y axis to show the value.
@export var visual: Node3D
## Played on each detent the drag passes. Optional.
@export var click: AudioStreamPlayer3D


func _ready() -> void:
	target.updated.connect(_on_updated)
	_refresh()


## Moves the target by the drag, via the model.
func drag(dx: float, fine: bool) -> void:
	var previous := target.value
	target.value = model.apply(previous, dx, fine)
	if click != null and model.crossed_detent(previous, target.value):
		click.play()


func _on_updated(_previous: Variant, _current: Variant) -> void:
	_refresh()


func _refresh() -> void:
	if visual != null:
		# Negative so a rightward drag turns the wheel clockwise as seen from the chair.
		visual.rotation_degrees.y = -target.value * model.visual_degrees_per_unit
