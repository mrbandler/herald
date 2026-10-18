class_name FloatValue
extends Value

## A float atom, e.g. dish angles, signal strength or pass time.

## The value a freshly loaded atom holds, and what `reset()` returns to.
@export var default: float:
	set(v):
		default = v
		_value = v

## The current value. Assigning a different value emits `updated`.
var value: float:
	get:
		return _value
	set(v):
		_store(v)

## Seeds the backing store with 0.0.
func _init() -> void:
	# Zero seed: a default of 0 is not stored in the .tres, so its setter never runs.
	_value = 0.0

## The value `reset()` stores: `default`.
func _default() -> Variant:
	return default
