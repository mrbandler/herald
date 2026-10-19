class_name Paper
extends Resource

## A sheet of paper in a window: what it says, how big it is, and when it reaches the desk.

## The text when written inline, e.g. the prayer card's format. Empty reads the Markdown file
## next to this resource instead. With `fields`, a format string filled from the window.
@export_multiline var text := ""

## `PassWindow` property names that fill `text`, in order. Empty for plain text. The default is
## typed: with `[]`, the export's text-to-binary conversion drops the value.
@export var fields := PackedStringArray()

## Width and height in metres. A letter is 0.148 x 0.21, the prayer card 0.105 x 0.074.
@export var size := Vector2(0.148, 0.21)

## Seconds into the pass it arrives by tube. 0 lies on the desk from the start.
@export var arrives_at := 0.0

## The paper's text: `text`, or the sibling `.md` of a saved resource, e.g. `letter.md` next to
## `letter.tres`.
func body() -> String:
	if not text.is_empty() or resource_path.is_empty():
		return text

	return FileAccess.get_file_as_string(resource_path.get_basename() + ".md")

## The text as the player reads it: filled from `window` when `fields` are set, with damage
## placeholders turned into glyphs.
func text_for(window: PassWindow) -> String:
	var written := body()
	if fields.is_empty() or window == null:
		return TextGlyphs.patch(written)

	var values: Array = []
	for field: String in fields:
		values.append(window.get(field))

	return TextGlyphs.patch(written % values)
