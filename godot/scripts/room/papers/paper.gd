class_name Paper
extends Resource

## A sheet of paper in a window: what it says, how big it is, and when it reaches the desk.

## The text. With `fields`, a format string filled from the window, e.g. `AZ %05.1f`.
@export_multiline var text := ""

## `PassWindow` property names that fill `text`, in order. Empty for plain text.
@export var fields: PackedStringArray = []

## Width and height in metres. A letter is 0.148 x 0.21, the prayer card 0.105 x 0.074.
@export var size := Vector2(0.148, 0.21)

## Seconds into the pass it arrives by tube. 0 lies on the desk from the start.
@export var arrives_at := 0.0

## The text as the player reads it, filled from `window` when `fields` are set.
func text_for(window: PassWindow) -> String:
	if fields.is_empty() or window == null:
		return text

	var values: Array = []
	for field: String in fields:
		values.append(window.get(field))

	return text % values
