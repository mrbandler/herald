class_name Value
extends Resource

## Shared base of every value atom. Typed subclasses add a typed `value` and `default`.

## Emitted after a real change, with the old and the new value.
signal updated(previous: Variant, current: Variant)

## Backing store. Typed subclasses expose it as `value`.
var _value: Variant

## Stores the default. Emits `updated` if that changes the value.
func reset() -> void:
	_store(_default())

## The value in a JSON-friendly form, for saving.
func snapshot() -> Variant:
	return _value

## Loads a snapshot (e.g. parsed from JSON). Emits `updated` on a real change.
func restore(v: Variant) -> void:
	_store(_coerce(v))

## What `reset()` stores. Typed subclasses return their `default`.
func _default() -> Variant:
	return null

## Turns a JSON-decoded value back into this atom's type.
func _coerce(v: Variant) -> Variant:
	return v

## The single write path: stores, and emits only when the value really changed.
func _store(v: Variant) -> void:
	if v == _value:
		return

	var previous: Variant = _value
	_value = v
	updated.emit(previous, v)
