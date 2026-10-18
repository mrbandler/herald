class_name DecodeCommand
extends Command

## DECODE <ID> reads a stored item through its module and prints it. Works any time, also after
## LOS. Lost and noisy rows show in the text.

## Picks the decoder and damages the text by the item's rows.
@export var module_model: ModuleModel

## Looks the item up in storage.
@export var downlink_model: DownlinkModel

## Read. Local storage: StoredItem resources.
@export var storage: ResourceListValue

## Read. The modules unlocked so far.
@export var unlocked_modules: StringListValue

## Prints the decoded lines of the one stored item named, or why it can't.
func run(args: PackedStringArray) -> void:
	if args.size() != 1:
		write("USAGE: DECODE <ID>")
		return

	var token := args[0]
	var stored := downlink_model.stored(storage.value, token)
	if stored == null:
		write("%s UNKNOWN ITEM" % token)
		return

	var type := stored.item.type
	if type == "AUTH":
		write("%s IS AN AUTH BLOCK. USE UNLOCK" % token)
		return

	var module := module_model.decoder_for(type)
	if module.is_empty():
		write("NO DECODER FOR %s" % type)
		return

	if not unlocked_modules.value.has(module):
		write("%s MODULE LOCKED" % module)
		return

	var lines := module_model.decode_lines(stored)
	if lines.is_empty():
		write("%s NO TEXT" % token)
		return

	for line: String in lines:
		write(" " + line)
