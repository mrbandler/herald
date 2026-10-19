class_name TextGlyphs
extends RefCounted

## Placeholders authors type into text files for damage, and the glyphs they become: `{{###}}`
## blacks out and `{{~~~}}` marks a lost segment, one glyph per character.

## A blacked-out character.
const BLOCKED := "█"

## A character lost in transfer.
const LOST := "▒"

## `text` with every placeholder replaced by its glyphs.
static func patch(text: String) -> String:
	var placeholder := RegEx.create_from_string("\\{\\{(#+|~+)\\}\\}")
	var patched := ""
	var last := 0
	for found: RegExMatch in placeholder.search_all(text):
		var marks := found.get_string(1)
		var glyph := BLOCKED if marks.begins_with("#") else LOST
		patched += text.substr(last, found.get_start() - last) + glyph.repeat(marks.length())
		last = found.get_end()

	return patched + text.substr(last)
