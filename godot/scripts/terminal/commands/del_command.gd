class_name DelCommand
extends Command

## DEL <ID> deletes a stored item for good and reports the free space.

## Supplies the storage capacity and the lookups.
@export var model: DownlinkModel

## Read and written. Local storage: StoredItem resources.
@export var storage: ResourceListValue

## Deletes the stored item named by the one argument.
func run(args: PackedStringArray) -> void:
	if args.size() != 1:
		write("USAGE: DEL <ID>")
		return

	var stored := model.stored(storage.value, args[0])
	if stored == null:
		write("%s UNKNOWN ITEM" % args[0])
		return

	storage.remove(stored)
	var free := model.storage_capacity - model.units(storage.value)
	write("%s DELETED. FREE %d." % [args[0], free])
