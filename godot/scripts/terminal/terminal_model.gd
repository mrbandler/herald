class_name TerminalModel
extends Resource

## The CRT's character grid and how lines fill it.

## Characters per row.
@export var columns := 48

## Rows on screen, including the prompt line and the reserved bottom line.
@export var rows := 18

## Shown before the input line and before each echoed command.
@export var prompt := "LP4> "

## Commands kept in the history.
@export var history_cap := 50

## Lines kept in scrollback.
@export var scrollback := 300

## The longest input that fits beside the prompt and the cursor.
func max_input() -> int:
	return columns - prompt.length() - 1

## How far back `line_count` lines can scroll. The screen shows `rows - 2` of them.
func max_scroll(line_count: int) -> int:
	return maxi(line_count - (rows - 2), 0)

## Splits a line into chunks that fit the screen width.
func wrap_line(line: String) -> PackedStringArray:
	if line.is_empty():
		return PackedStringArray([""])

	var chunks := PackedStringArray()
	for start: int in range(0, line.length(), columns):
		chunks.append(line.substr(start, columns))

	return chunks

## The screen: scrollback above, the prompt line, and the progress line at the bottom.
func compose(lines: PackedStringArray, input: String, scroll: int, progress := "") -> String:
	var end := maxi(lines.size() - scroll, 0)
	var shown := lines.slice(maxi(end - (rows - 2), 0), end)

	shown.append(prompt + input + "_")
	shown.append(progress)

	return "\n".join(shown)
