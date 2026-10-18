class_name PassLabel
extends Label3D

## A desk text drawn from the current window: its `fields` filled into `format`. Hidden when
## there is no window or the text comes out empty.

## Read. The window the text comes from.
@export var current_pass: ResourceValue

## `PassWindow` property names that fill `format`, in order.
@export var fields: PackedStringArray = []

## One specifier per field, e.g. `AZ %05.1f`. A mismatch with `fields` is a developer error.
@export var format := "%s"

## Listens for window changes and draws the current window.
func _ready() -> void:
	current_pass.updated.connect(_on_pass_changed)
	refresh()

## Fills `format` from the current window, or hides the label without one.
func refresh() -> void:
	var window := current_pass.value as PassWindow
	if window == null:
		text = ""
		visible = false
		return

	var values: Array = []
	for field: String in fields:
		values.append(window.get(field))

	text = format % values
	visible = not text.is_empty()

## Redraws when `current_pass` points at another window.
func _on_pass_changed(_previous: Variant, _current: Variant) -> void:
	refresh()
