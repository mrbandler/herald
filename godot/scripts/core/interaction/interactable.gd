class_name Interactable
extends Area3D

## Something the player can grab. Picker calls these; subclasses override what they need.


## Called when the player grabs it.
func grab() -> void:
	pass

## Called every frame while held. `_dx` is horizontal mouse motion in pixels,
## `_fine` is true while the fine modifier is held.
func drag(_dx: float, _fine: bool) -> void:
	pass

## Called when the player lets go.
func release() -> void:
	pass

## True for a spot that puts down what is in hand, so the crosshair shows the place icon.
func is_placement() -> bool:
	return false

## False while it cannot be used yet, so the crosshair shows a lock instead of a hand.
func is_usable() -> bool:
	return true

## True for something pressed with a click, so the crosshair shows the pointer.
func is_button() -> bool:
	return false
