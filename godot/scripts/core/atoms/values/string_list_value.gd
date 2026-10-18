class_name StringListValue
extends Value

## A PackedStringArray atom, e.g. the probe sequence or the command history.
## Packed arrays are shared by reference: never mutate an array you read from or assigned to
## `value`. Build a new one and assign it: `atom.value = atom.value + PackedStringArray([x])`.

## The value a freshly loaded atom holds, and what `reset()` returns to.
@export var default: PackedStringArray:
	set(v):
		default = v
		_value = v.duplicate()

## The current list. Assigning a different list emits `updated`; never mutate it in place.
var value: PackedStringArray:
	get:
		return _value
	set(v):
		_store(v)

## Seeds the backing store with an empty list.
func _init() -> void:
	# Seed: an unchanged default is not stored in the .tres, so its setter never runs.
	_value = PackedStringArray()

## The value `reset()` stores: `default`.
func _default() -> Variant:
	# Copy, so the stored value never aliases the exported default.
	return default.duplicate()

## Turns a JSON array back into a PackedStringArray.
func _coerce(v: Variant) -> Variant:
	var items: Array = v
	return PackedStringArray(items)
