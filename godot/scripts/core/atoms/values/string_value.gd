class_name StringValue
extends Value

## A string atom, e.g. the path of the open file.

## The value a freshly loaded atom holds, and what `reset()` returns to.
@export var default: String:
	set(v):
		default = v
		_value = v

## The current value. Assigning a different value emits `updated`.
var value: String:
	get:
		return _value
	set(v):
		_store(v)

## Seeds the backing store with an empty string.
func _init() -> void:
	# Seed: an unchanged default is not stored in the .tres, so its setter never runs.
	_value = ""

## The value `reset()` stores: `default`.
func _default() -> Variant:
	return default
