class_name LampChain
extends Interactable

## The desk lamp's pull chain. Pulling it ends the shift, but only once the pass is over.

## Read. True between LOS and the end of the shift.
@export var unlocked: BoolValue

## Raised on a pull while unlocked. Usually the morning bell.
@export var pull: Event

## Usable only once the pass is over, so the crosshair shows a lock before LOS.
func is_usable() -> bool:
	return unlocked.value

## Ends the shift if the chain is unlocked; does nothing during the pass.
func grab() -> void:
	if unlocked.value:
		pull.raise()
