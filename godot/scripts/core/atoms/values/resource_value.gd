class_name ResourceValue
extends Value

## The reference atom: a pointer many systems hold and one system switches.
## Readers downcast once, e.g. `current_pass.value as PassWindow`.
## Keep it out of `SaveGame.atoms`: a pointer is not saved.

## The value a freshly loaded atom holds, and what `reset()` returns to.
@export var default: Resource:
	set(v):
		default = v
		_value = v

## The current target. Assigning a different one emits `updated`.
var value: Resource:
	get:
		return _value
	set(v):
		_store(v)

## The value `reset()` stores: `default`.
func _default() -> Variant:
	return default
