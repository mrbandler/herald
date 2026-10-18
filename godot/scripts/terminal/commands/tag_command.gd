class_name TagCommand
extends Command

## TAG <ID> [TEXT] labels a stored item for the player; TAG <ID> alone clears the label. The tag
## carries across windows with the item.

## Looks the item up in storage.
@export var downlink_model: DownlinkModel

## Read and written. Local storage: StoredItem resources.
@export var storage: ResourceListValue

## Longest tag allowed, in characters.
@export var max_length := 16

## Sets or clears the tag of the stored item named first.
func run(args: PackedStringArray) -> void:
	if args.is_empty():
		write("USAGE: TAG <ID> [TEXT]")
		return

	var token := args[0]
	var stored := downlink_model.stored(storage.value, token)
	if stored == null:
		write("%s UNKNOWN ITEM" % token)
		return

	var text := " ".join(args.slice(1))
	if text.length() > max_length:
		write("TAG TOO LONG. %d MAX" % max_length)
		return

	storage.replace(stored, _tagged(stored, text))
	write(("%s TAGGED" % token) if not text.is_empty() else ("%s TAG CLEARED" % token))

## A copy of `stored` with `text` as its tag, so storage changes by assignment, never in place.
func _tagged(stored: StoredItem, text: String) -> StoredItem:
	var copy := StoredItem.new()
	copy.item = stored.item
	copy.grades = stored.grades.duplicate()
	copy.tag = text
	return copy
