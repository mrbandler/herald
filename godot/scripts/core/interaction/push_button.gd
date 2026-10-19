class_name PushButton
extends Interactable

## A button pressed with a click: it raises its event once per press.

## Raised on every press.
@export var pressed: Event

## Raises `pressed`.
func grab() -> void:
	pressed.raise()
