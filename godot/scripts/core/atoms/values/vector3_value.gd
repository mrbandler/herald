class_name Vector3Value
extends Value

## A Vector3 atom. Saved as `[x, y, z]`, since JSON has no vector type.

## The value a freshly loaded atom holds, and what `reset()` returns to.
@export var default: Vector3:
	set(v):
		default = v
		_value = v

## The current value. Assigning a different value emits `updated`.
var value: Vector3:
	get:
		return _value
	set(v):
		_store(v)

## Seeds the backing store with Vector3.ZERO.
func _init() -> void:
	# Seed: an unchanged default is not stored in the .tres, so its setter never runs.
	_value = Vector3.ZERO

## The value `reset()` stores: `default`.
func _default() -> Variant:
	return default

## Saved as [x, y, z], since JSON has no Vector3.
func snapshot() -> Variant:
	return [value.x, value.y, value.z]

## Turns a saved `[x, y, z]` back into a Vector3.
func _coerce(v: Variant) -> Variant:
	var items: Array = v

	var x: float = items[0]
	var y: float = items[1]
	var z: float = items[2]

	return Vector3(x, y, z)
