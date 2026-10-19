class_name ShowCommand
extends Command

## SHOW <ID> puts a decoded image back on the monitor, drawn with the tuning it was committed
## with.

## Tells images from other types through their decoder.
@export var module_model: ModuleModel

## Looks the item up in storage.
@export var downlink_model: DownlinkModel

## Read. Local storage: StoredItem resources.
@export var storage: ResourceListValue

## Read. The modules unlocked so far; SHOW needs IMG.
@export var unlocked_modules: StringListValue

## Written. The image on the monitor.
@export var shown_item: ResourceValue

## Read and written. SHOW once shown; a STREAM refuses.
@export var monitor_mode: IntValue

## Shows the named decoded image, or writes why not.
func run(args: PackedStringArray) -> void:
	if args.size() != 1:
		write("USAGE: SHOW <ID>")
		return

	var token := args[0]
	var stored := downlink_model.stored(storage.value, token)
	if stored == null:
		write("%s UNKNOWN ITEM" % token)
		return

	if module_model.decoder_for(stored.item.type) != "IMG":
		write("%s IS NOT AN IMAGE" % token)
		return

	if not unlocked_modules.value.has("IMG"):
		write("IMG MODULE LOCKED")
		return

	if monitor_mode.value == MonitorModel.Mode.STREAM:
		write("MONITOR BUSY")
		return

	if not stored.decoded:
		write("%s NOT DECODED. DECODE %s" % [token, token])
		return

	shown_item.value = stored
	monitor_mode.value = MonitorModel.Mode.SHOW
	write("%s ON THE MONITOR" % token)
