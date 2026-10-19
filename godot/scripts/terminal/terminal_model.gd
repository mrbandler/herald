class_name TerminalModel
extends Resource

## The CRT's character grid and how lines fill it.

## Characters per row.
@export var columns := 48

## Rows in the text area, the prompt line included.
@export var rows := 18

## Shown before the input line and before each echoed command at the top directory. Its first
## word, the station name, marks command lines.
@export var prompt := "LP4> "

## Commands kept in the history.
@export var history_cap := 50

## Lines kept in scrollback.
@export var scrollback := 300

## Colour of command lines, echoed and typed: full amber, against the dimmer output.
@export var command_color := Color(1, 0.72, 0.25)

## Lines one mouse wheel step scrolls.
@export var wheel_lines := 3

## The prompt in `directory`: `LP4> ` at the top, `LP4 USR:OKONJO> ` inside a directory.
func prompt_in(directory: String) -> String:
	if directory.is_empty():
		return prompt

	return "%s %s> " % [_station(), directory.trim_suffix("/")]

## The longest input that fits beside the prompt in `directory` and the cursor.
func max_input(directory := "") -> int:
	return columns - prompt_in(directory).length() - 1

## How far back `line_count` lines can scroll. The screen shows `rows - 1` of them.
func max_scroll(line_count: int) -> int:
	return maxi(line_count - (rows - 1), 0)

## The rule under the text area: a plain line, or ` +12 BELOW ` in its middle while scrolled
## `scroll` lines back.
func rule_below(scroll: int) -> String:
	return _rule(" +%d BELOW " % scroll if scroll > 0 else "")

## The rule over the text area: a plain line, or ` +40 ABOVE ` in its middle while `above`
## lines sit above the screen.
func rule_above(above: int) -> String:
	return _rule(" +%d ABOVE " % above if above > 0 else "")

## Lines above the screen when `line_count` lines are scrolled `scroll` back.
func lines_above(line_count: int, scroll: int) -> int:
	return maxi(line_count - scroll - (rows - 1), 0)

## A line `columns` wide with `marker` set into its middle.
func _rule(marker: String) -> String:
	var line := "─".repeat(columns)
	var start := floori((columns - marker.length()) / 2.0)
	return line.left(start) + marker + line.substr(start + marker.length())

## The station name: the prompt's first word, e.g. `LP4`.
func _station() -> String:
	return prompt.get_slice(" ", 0).trim_suffix(">")

## Splits a line into chunks that fit the screen width.
func wrap_line(line: String) -> PackedStringArray:
	if line.is_empty():
		return PackedStringArray([""])

	var chunks := PackedStringArray()
	for start: int in range(0, line.length(), columns):
		chunks.append(line.substr(start, columns))

	return chunks

## The text area as BBCode: scrollback above, the prompt line last, commands in
## `command_color`.
func compose(lines: PackedStringArray, input: String, scroll: int, directory := "") -> String:
	var end := maxi(lines.size() - scroll, 0)
	var shown := lines.slice(maxi(end - (rows - 1), 0), end)
	shown.append(prompt_in(directory) + input + "_")

	var marked := PackedStringArray()
	for line: String in shown:
		marked.append(_marked(line))

	return "\n".join(marked)

## `line` with its brackets escaped, coloured when it is a command. A command always fits one
## row, so only command rows start with the station name.
func _marked(line: String) -> String:
	var escaped := line.replace("[", "[lb]")
	if not line.begins_with(_station()):
		return escaped

	return "[color=#%s]%s[/color]" % [command_color.to_html(false), escaped]
