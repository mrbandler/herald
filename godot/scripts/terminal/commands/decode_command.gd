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

## Supplies the rough tuning a CAL presets.
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

## Prints the decoded lines of the one stored item named, or why it can't. An image goes on the
## monitor instead, preset from a CAL when one is named.
func run(args: PackedStringArray) -> void:
	var with_cal := args.size() == 3 and args[1] == "CAL"
	if args.size() != 1 and not with_cal:
		write("USAGE: DECODE <ID> [CAL <ID>]")
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
		_tune(stored, args[2] if with_cal else "")
		return

	if with_cal:
		write("%s IS NOT AN IMAGE" % token)
		return

	var lines := module_model.decode_lines(stored)
	if lines.is_empty():
		write("%s NO TEXT" % token)
		return

	for line: String in lines:
		write(" " + line)

## Puts an image on the monitor to tune. A CAL named by `cal_token` presets LINE and OFFSET
## roughly; otherwise a decoded image sets the knobs to its tuning and a raw one keeps them where
## they are, e.g. at a LINE found on a CAL by hand.
func _tune(stored: StoredItem, cal_token: String) -> void:
	if monitor_mode.value == MonitorModel.Mode.STREAM:
		write("MONITOR BUSY")
		return

	if not cal_token.is_empty():
		var cal := downlink_model.stored(storage.value, cal_token)
		if cal == null:
			write("%s UNKNOWN ITEM" % cal_token)
			return

		if cal.item.type != "CAL":
			write("%s IS NOT A CAL" % cal_token)
			return

		var preset := monitor_model.from_cal(stored.item, cal.item)
		knob_line.value = preset.x
		knob_offset.value = preset.y
	elif stored.decoded:
		knob_line.value = stored.tuning.x
		knob_offset.value = stored.tuning.y
		knob_contrast.value = stored.tuning.z

	shown_item.value = stored
	monitor_mode.value = MonitorModel.Mode.TUNE
	write("TUNE THE MONITOR. COMMIT TO DECODE")
