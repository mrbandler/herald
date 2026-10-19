class_name ProgressLabel
extends Label

## The terminal's progress row under the status bar: the running transfer, or `idle_text` in a
## dimmer colour while none runs.

## Read. The progress line, empty while nothing runs.
@export var progress_line: StringValue

## Shown while nothing runs.
@export var idle_text := "NO TRANSFER"

## Text colour while a transfer runs.
@export var active_color := Color(1, 0.72, 0.25)

## Text colour of `idle_text`.
@export var idle_color := Color(0.6, 0.42, 0.14)

## Listens for progress changes and draws the current one.
func _ready() -> void:
	progress_line.updated.connect(_on_progress)
	refresh()

## Draws the progress line, or the idle text while it is empty.
func refresh() -> void:
	var idle := progress_line.value.is_empty()
	text = idle_text if idle else progress_line.value
	add_theme_color_override("font_color", idle_color if idle else active_color)

## Redraws when the progress line changes.
func _on_progress(_previous: Variant, _current: Variant) -> void:
	refresh()
