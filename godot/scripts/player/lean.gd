class_name Lean
extends Node

## Blends the pivot from the seat toward the terminal while it is focused.
## Looking away pulls back so the console stays visible; looking back leans in again.

## Model to use.
@export var model: PlayerModel

## Moved between its seated position and the leaned one.
@export var pivot: Node3D

## Read. The lean is only wanted while true.
@export var focused: BoolValue

## Read. World position to lean toward.
@export var focus_point: Vector3Value

## Current lean blend, 0 seated to 1 fully leaned.
var amount := 0.0

## The pivot's position at ready, in its parent's space: where the lean starts from.
var _seated := Vector3.ZERO

## Remembers the seated position.
func _ready() -> void:
	_seated = pivot.position

## Leans every frame.
func _process(delta: float) -> void:
	tick(delta)

## Moves the lean amount toward its goal and places the pivot.
func tick(delta: float) -> void:
	var goal := 0.0
	if focused.value:
		var view := -pivot.global_basis.z
		var to_focus := (focus_point.value - pivot.global_position).normalized()
		goal = model.lean_amount(rad_to_deg(view.angle_to(to_focus)))

	amount = move_toward(amount, goal, model.lean_speed * delta)

	var leaned := pivot.get_parent_node_3d().to_local(focus_point.value + model.lean_offset)
	pivot.position = _seated.lerp(leaned, amount)
