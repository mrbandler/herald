class_name DelCommand
extends Command

## DEL <ID>[, <ID>] deletes stored items for good and reports the free space after each.

## Supplies the storage capacity and the lookups.
@export var model: DownlinkModel

## Read and written. Local storage: StoredItem resources.
@export var storage: ResourceListValue

## Deletes each named stored item in order, or writes the usage without an id.
func run(args: PackedStringArray) -> void:
	if args.is_empty():
		write("USAGE: DEL <ID>[, <ID>]")
		return

	for token: String in args:
		_delete(token)

## Deletes one stored item, or writes that it is unknown.
func _delete(token: String) -> void:
	var stored := model.stored(storage.value, token)
	if stored == null:
		write("%s UNKNOWN ITEM" % token)
		return

	storage.remove(stored)
	var free := model.storage_capacity - model.units(storage.value)
	write("%s DELETED. FREE %d." % [token, free])
