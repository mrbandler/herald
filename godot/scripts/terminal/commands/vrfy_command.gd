class_name VrfyCommand
extends Command

## VRFY <ID> prints a stored item's integrity: its rows by grade, whether an AUTH key is valid,
## and its tag. "Count" in the liturgy.

## Decides whether an AUTH key is valid.
@export var module_model: ModuleModel

## Looks the item up in storage.
@export var downlink_model: DownlinkModel

## Read. Local storage: StoredItem resources.
@export var storage: ResourceListValue

## Prints the report for the one stored item named.
func run(args: PackedStringArray) -> void:
	if args.size() != 1:
		write("USAGE: VRFY <ID>")
		return

	var stored := downlink_model.stored(storage.value, args[0])
	if stored == null:
		write("%s UNKNOWN ITEM" % args[0])
		return

	var item := stored.item
	var rows := [item.id, item.type, stored.arrived(), item.rows]
	var grades := [stored.clean(), stored.noisy(), stored.lost()]
	write(" %d %s  ROWS %d/%d  CLEAN %d NOISY %d LOST %d" % (rows + grades))

	if item.type == "AUTH":
		var invalid := "INVALID. %d ROWS MISSING" % stored.missing()
		var verdict := "VALID" if module_model.is_valid_key(stored) else invalid
		write(" KEY FOR %s. %s" % [item.key_for, verdict])

	if not stored.tag.is_empty():
		write(" TAG: %s" % stored.tag)
