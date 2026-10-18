class_name ValueLabel
extends Label3D

## A Label3D that shows a FloatValue through a format string.

## Only read. The label redraws whenever this atom emits `updated`.
@export var source: FloatValue

## Format string with exactly one float specifier, e.g. `AZ %05.1f`.
@export var format := "%.1f"

## Watches `source` and draws the first value.
func _ready() -> void:
	source.updated.connect(_on_updated)
	_refresh()

## Redraws on every change of `source`.
func _on_updated(_previous: Variant, _current: Variant) -> void:
	_refresh()

## Formats `source` into the label text.
func _refresh() -> void:
	text = format % source.value
