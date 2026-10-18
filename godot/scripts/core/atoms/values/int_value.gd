class_name IntValue
extends Value

## An int atom. JSON decodes numbers as floats, so `_coerce` turns them back into ints.

## The value a freshly loaded atom holds, and what `reset()` returns to.
@export var default: int:
	set(v):
		default = v
		_value = v

## The current value. Assigning a different value emits `updated`.
var value: int:
	get:
		return _value
	set(v):
		_store(v)

## Seeds the backing store with 0.
func _init() -> void:
	# Seed: an unchanged default is not stored in the .tres, so its setter never runs.
	_value = 0

## The value `reset()` stores: `default`.
func _default() -> Variant:
	return default

## Turns a JSON number back into an int.
func _coerce(v: Variant) -> Variant:
	# JSON decodes every number as a float.
	var number: float = v
	return int(number)
