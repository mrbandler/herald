class_name BoolValue
extends Value

## A bool atom, e.g. `locked` or `speak_open`.

## The value a freshly loaded atom holds, and what `reset()` returns to.
@export var default: bool:
	set(v):
		default = v
		_value = v

## The current value. Assigning a different value emits `updated`.
var value: bool:
	get:
		return _value
	set(v):
		_store(v)


func _init() -> void:
	# Seed: an unchanged default is not stored in the .tres, so its setter never runs.
	_value = false


func _default() -> Variant:
	return default
