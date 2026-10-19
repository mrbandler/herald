class_name MonitorCommit
extends Node

## Keeps a tuned image when COMMIT is pressed: the stored copy is replaced by one that is decoded
## and carries the knobs' values.

## Raised by the COMMIT button.
@export var commit_pressed: Event

## Read and written. The image being tuned, then the decoded copy.
@export var shown_item: ResourceValue

## Read and written. Only TUNE commits; SHOW after, SNOW if the image is gone.
@export var monitor_mode: IntValue

## Read. The LINE knob.
@export var knob_line: FloatValue

## Read. The OFFSET knob.
@export var knob_offset: FloatValue

## Read. The CONTRAST knob.
@export var knob_contrast: FloatValue

## Local storage: StoredItem resources. The decoded copy replaces the stored one.
@export var storage: ResourceListValue

## Looks the image up in storage at commit time.
@export var downlink_model: DownlinkModel

## Receives the result. Usually stdout.
@export var out: StringEvent

## Listens for COMMIT.
func _ready() -> void:
	commit_pressed.raised.connect(_on_commit)

## Stores the tuning while tuning. The image is looked up by id now, because TAG and re-fetches
## replace the stored copy while the player turns the knobs.
func _on_commit(_payload: Variant) -> void:
	if monitor_mode.value != MonitorModel.Mode.TUNE:
		return

	var tuned := shown_item.value as StoredItem
	var current := downlink_model.stored(storage.value, str(tuned.item.id))
	if current == null:
		out.raise("%d UNKNOWN ITEM" % tuned.item.id)
		shown_item.value = null
		monitor_mode.value = MonitorModel.Mode.SNOW
		return

	var decoded := current.duplicate() as StoredItem
	decoded.decoded = true
	decoded.tuning = Vector3(knob_line.value, knob_offset.value, knob_contrast.value)
	storage.replace(current, decoded)
	shown_item.value = decoded
	monitor_mode.value = MonitorModel.Mode.SHOW
	out.raise("%d DECODED" % tuned.item.id)
