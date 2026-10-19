class_name ResourceListValue
extends Value
## A list-of-resources atom, e.g. the manifest, the download queue or local storage. Each atom's
## doc names its element type; readers cast every element (`as ManifestItem`). Never mutate an
## array you read from `value`: use `add`, `remove` and `clear`, or assign a new typed array.
## Not saveable: resources are not JSON-safe, so keep it out of `SaveGame.atoms`.

## The value a freshly loaded atom holds, and what `reset()` returns to.
@export var default: Array[Resource] = []:
	set(v):
		default = v
		_value = v.duplicate()

## The current list. Assigning a different list emits `updated`; never mutate it in place.
var value: Array[Resource]:
	get:
		return _value
	set(v):
		_store(v)

## Seeds the backing store with an empty typed list.
func _init() -> void:
	# Seed: an unchanged default is not stored in the .tres, so its setter never runs.
	var empty: Array[Resource] = []
	_value = empty

## Assigns a copy of the list with `item` appended.
func add(item: Resource) -> void:
	var next := value.duplicate()
	next.append(item)
	value = next

## Assigns a copy of the list without `item`.
func remove(item: Resource) -> void:
	var next := value.duplicate()
	next.erase(item)
	value = next

## Assigns a copy of the list with `old` swapped for `replacement` at the same place. Does nothing
## when `old` is not in the list. Lets an item change without mutating the array in place.
func replace(old: Resource, replacement: Resource) -> void:
	var index := value.find(old)
	if index == -1:
		return

	var next := value.duplicate()
	next[index] = replacement
	value = next

## Assigns an empty list.
func clear() -> void:
	var empty: Array[Resource] = []
	value = empty

## The value `reset()` stores: a copy of `default`.
func _default() -> Variant:
	# Copy, so the stored value never aliases the exported default.
	return default.duplicate()
