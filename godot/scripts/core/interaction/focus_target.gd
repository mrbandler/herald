class_name FocusTarget
extends Interactable

## Grabbing it focuses something (the terminal). Publishes where the lean should move to.

## Set true when grabbed.
@export var focused: BoolValue

## Written on ready: the world position of `anchor`.
@export var focus_point: Vector3Value

## Usually a child at the centre of the screen.
@export var anchor: Node3D

## Publishes the anchor's world position as the focus point.
func _ready() -> void:
	focus_point.value = anchor.global_position

## Marks the target as focused.
func grab() -> void:
	focused.value = true
