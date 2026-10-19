class_name LineEditor
extends RefCounted

## The terminal's input line: typing at a movable cursor, backspace and delete, history and
## scrollback. Upper case only.

## The line being typed.
var text := ""

## Characters before the cursor, 0 to the line's length. Typing goes in here.
var cursor := 0

## Lines scrolled back from the newest output. 0 shows the latest.
var scroll := 0

## Position in the history while browsing it with Up and Down, -1 when not browsing.
var _history_index := -1

## Inserts the character in upper case at the cursor, unless the line is already `max_length`
## long.
func insert(character: String, max_length: int) -> void:
	if text.length() >= max_length:
		return

	text = text.left(cursor) + character.to_upper() + text.substr(cursor)
	cursor += 1

## Removes the character before the cursor.
func backspace() -> void:
	if cursor == 0:
		return

	text = text.left(cursor - 1) + text.substr(cursor)
	cursor -= 1

## Removes the character under the cursor.
func delete() -> void:
	text = text.left(cursor) + text.substr(cursor + 1)

## Moves the cursor by `by` characters, within the line.
func move(by: int) -> void:
	cursor = clampi(cursor + by, 0, text.length())

## Moves the cursor a word at a time: back to the start of the word before it, or forward past
## the next word and its spaces, like Ctrl and the arrow keys in a shell.
func move_word(direction: int) -> void:
	var at := cursor
	if direction < 0:
		while at > 0 and text[at - 1] == " ":
			at -= 1
		while at > 0 and text[at - 1] != " ":
			at -= 1
	else:
		while at < text.length() and text[at] != " ":
			at += 1
		while at < text.length() and text[at] == " ":
			at += 1

	cursor = at

## The part of the current word before the cursor, back to the last space.
func word_before_cursor() -> String:
	var before := text.left(cursor)
	return before.substr(before.rfind(" ") + 1)

## Replaces the part of the current word before the cursor with `word`, in upper case, unless the
## line would grow past `max_length`.
func replace_word(word: String, max_length: int) -> void:
	var start := cursor - word_before_cursor().length()
	var replaced := text.left(start) + word.to_upper() + text.substr(cursor)
	if replaced.length() > max_length:
		return

	text = replaced
	cursor = start + word.length()

## Puts the cursor at the start of the line.
func home() -> void:
	cursor = 0

## Puts the cursor at the end of the line.
func end() -> void:
	cursor = text.length()

## Returns the line, then clears it and resets the scroll and the history position.
func submit() -> String:
	var line := text

	text = ""
	cursor = 0
	scroll = 0
	_history_index = -1

	return line

## Recalls the previous history entry. Stops at the oldest.
func history_up(history: PackedStringArray) -> void:
	if history.is_empty():
		return

	_history_index = history.size() - 1 if _history_index == -1 else maxi(_history_index - 1, 0)
	text = history[_history_index]
	end()

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

	end()

## Scrolls back by `lines` (negative scrolls forward), clamped to 0..`max_scroll`.
func scroll_by(lines: int, max_scroll: int) -> void:
	scroll = clampi(scroll + lines, 0, max_scroll)
