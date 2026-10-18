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
