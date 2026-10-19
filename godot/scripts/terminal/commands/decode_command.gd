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

## Supplies the knobs' start for an image never decoded.
@export var monitor_model: MonitorModel

## Written. The image put on the monitor to tune.
@export var shown_item: ResourceValue

## Read and written. TUNE while tuning; a STREAM refuses.
@export var monitor_mode: IntValue

## Written. The LINE knob, preset from the image.
@export var knob_line: FloatValue

## Written. The OFFSET knob, preset from the image.
@export var knob_offset: FloatValue

## Written. The CONTRAST knob, preset from the image.
@export var knob_contrast: FloatValue

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

	if module == "IMG":
		_tune(stored)
		return

	var lines := module_model.decode_lines(stored)
	if lines.is_empty():
		write("%s NO TEXT" % token)
		return

	for line: String in lines:
		write(" " + line)

## Puts an image on the monitor to tune, the knobs at its stored tuning or at the start.
func _tune(stored: StoredItem) -> void:
	if monitor_mode.value == MonitorModel.Mode.STREAM:
		write("MONITOR BUSY")
		return

	var start := stored.tuning if stored.decoded else monitor_model.start_tuning
	knob_line.value = start.x
	knob_offset.value = start.y
	knob_contrast.value = start.z
	shown_item.value = stored
	monitor_mode.value = MonitorModel.Mode.TUNE
	write("TUNE THE MONITOR. COMMIT TO DECODE")
