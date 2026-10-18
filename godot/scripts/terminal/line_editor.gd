class_name LineEditor
extends RefCounted

## The terminal's input line: typing, backspace, history and scrollback. Upper case only.

## The line being typed.
var text := ""

## Lines scrolled back from the newest output. 0 shows the latest.
var scroll := 0

## Position in the history while browsing it with Up and Down, -1 when not browsing.
var _history_index := -1

## Appends the character in upper case, unless the line is already `max_length` long.
func insert(character: String, max_length: int) -> void:
	if text.length() < max_length:
		text += character.to_upper()

## Removes the last character.
func backspace() -> void:
	text = text.left(-1)

## Returns the line, then clears it and resets the scroll and the history position.
func submit() -> String:
	var line := text

	text = ""
	scroll = 0
	_history_index = -1

	return line

## Recalls the previous history entry. Stops at the oldest.
func history_up(history: PackedStringArray) -> void:
	if history.is_empty():
		return

	_history_index = history.size() - 1 if _history_index == -1 else maxi(_history_index - 1, 0)
	text = history[_history_index]

## Moves toward newer entries. Past the newest it clears the line.
func history_down(history: PackedStringArray) -> void:
	if _history_index == -1:
		return

	_history_index += 1
	if _history_index >= history.size():
		_history_index = -1
		text = ""
	else:
		text = history[_history_index]

## Scrolls back by `lines` (negative scrolls forward), clamped to 0..`max_scroll`.
func scroll_by(lines: int, max_scroll: int) -> void:
	scroll = clampi(scroll + lines, 0, max_scroll)
