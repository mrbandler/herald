class_name ProgressLabel
extends Label

## The terminal's progress row under the status bar: the running transfer, or `idle_text` in a
## dimmer colour while none runs. The storage in use sits on the right of the row.

## Read. The progress line, empty while nothing runs.
@export var progress_line: StringValue

## Read. What is stored, counted in units on the right.
@export var storage: ResourceListValue

## Supplies the unit count and the capacity.
@export var downlink_model: DownlinkModel

## Shows the storage in use on the right, e.g. "STORAGE 3/8", in the row's colour. Optional.
@export var storage_readout: Label

## Shown while nothing runs.
@export var idle_text := "NO TRANSFER"

## Filled with the units in use and the capacity.
@export var storage_format := "STORAGE %d/%d"

## Text colour while a transfer runs.
@export var active_color := Color(1, 0.72, 0.25)

## Text colour while nothing runs.
@export var idle_color := Color(0.6, 0.42, 0.14)

## Listens for progress and storage changes and draws the current row.
func _ready() -> void:
	progress_line.updated.connect(_on_changed)
	storage.updated.connect(_on_changed)
	refresh()

## Draws the progress line, or the idle text while it is empty, and the storage in use.
func refresh() -> void:
	var idle := progress_line.value.is_empty()
	var color := idle_color if idle else active_color
	text = idle_text if idle else progress_line.value
	add_theme_color_override("font_color", color)

	if storage_readout != null:
		var used := downlink_model.units(storage.value)
		storage_readout.text = storage_format % [used, downlink_model.storage_capacity]
		storage_readout.add_theme_color_override("font_color", color)

## Redraws when the progress line or the storage changes.
func _on_changed(_previous: Variant, _current: Variant) -> void:
	refresh()
