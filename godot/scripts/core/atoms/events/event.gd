class_name Event
extends Resource

## Shared base of every event atom: a moment that fires, with an optional payload.

## Emitted by `raise()` with the payload (null when none). Every handler must take it, even
## unused: `func _on_x(_payload: Variant) -> void`. A zero-argument handler fails at runtime.
signal raised(payload: Variant)

## Emits `raised`.
func raise(payload: Variant = null) -> void:
	raised.emit(payload)
