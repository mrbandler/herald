class_name StoreCommand
extends Command

## STORE shows local storage: the units used and every stored item with its rows by grade.

## Supplies the storage capacity and the unit count.
@export var model: DownlinkModel

## Read. Local storage: StoredItem resources.
@export var storage: ResourceListValue

## Prints the fill, then one line per stored item.
func run(_args: PackedStringArray) -> void:
	write("STORAGE %d/%d" % [model.units(storage.value), model.storage_capacity])
	if storage.value.is_empty():
		return

	write(" ID   TYPE  SIZE  ROWS   CLEAN NOISY LOST")

	for resource: Resource in storage.value:
		var stored := resource as StoredItem
		var item := stored.item
		var rows := "%d/%d" % [stored.arrived(), item.rows]
		var columns := [item.id, item.type, item.size, rows]
		var grades := [stored.clean(), stored.noisy(), stored.lost()]
		write(" %-4d %-5s %-5d %-6s %-5d %-5d %d" % (columns + grades))
