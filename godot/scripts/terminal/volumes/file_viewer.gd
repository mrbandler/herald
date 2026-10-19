class_name FileViewer
extends Node

## The file popup on the CRT: shows the file `viewing` names over the dimmed text area and
## scrolls it. The popup carries its own keybindings bar. Esc stays with the Terminal, which
## clears `viewing` before it leaves.

## Supplies the wheel step.
@export var terminal_model: TerminalModel

## Body lines on one page. Matches the Body label's height in the scene.
@export var page_lines := 11

## Turns `viewing` back into a file.
@export var volume_model: VolumeModel

## Read. The open file's path, empty while closed. Written by READ and the Terminal's Esc.
@export var viewing: StringValue

## Read. Keys count only while the terminal is focused.
@export var focused: BoolValue

## Read. The wheel scrolls only at 1, fully leaned in.
@export var lean_amount: FloatValue

## Read. A file whose module is locked does not open.
@export var unlocked_modules: StringListValue

## The popup, shown while a file is open.
@export var panel: Control

## Shows the open file's path.
@export var title: Label

## Shows the lines on show and the total, e.g. `1-15/24`.
@export var counter: Label

## Renders the visible lines of the file as Markdown.
@export var body: MarkdownLabel

## The open file's lines, empty while closed.
var _lines := PackedStringArray()

## Index of the first line on show.
var _top := 0

## Listens for files opening and closing, and draws the start state.
func _ready() -> void:
	viewing.updated.connect(_on_viewing)
	refresh()

## Feeds key presses to `handle_key` while the terminal is focused.
func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or not focused.value:
		return

	if handle_key(key.keycode):
		get_viewport().set_input_as_handled()

## Feeds wheel steps to `handle_wheel` while fully leaned in.
func _unhandled_input(event: InputEvent) -> void:
	var button := event as InputEventMouseButton
	var leaned_in := focused.value and lean_amount.value >= 1.0
	if button == null or not button.pressed or not leaned_in:
		return

	if handle_wheel(button.button_index):
		get_viewport().set_input_as_handled()

## Up and Down move one line, Page Up and Page Down one page. Returns false while closed and
## for any other key, Esc included.
func handle_key(keycode: Key) -> bool:
	if not panel.visible:
		return false

	match keycode:
		KEY_UP:
			scroll_by(-1)
		KEY_DOWN:
			scroll_by(1)
		KEY_PAGEUP:
			scroll_by(-_page())
		KEY_PAGEDOWN:
			scroll_by(_page())
		_:
			return false

	return true

## The wheel moves `wheel_lines`. Returns false while closed and for other buttons.
func handle_wheel(button: MouseButton) -> bool:
	if not panel.visible:
		return false

	match button:
		MOUSE_BUTTON_WHEEL_UP:
			scroll_by(-terminal_model.wheel_lines)
		MOUSE_BUTTON_WHEEL_DOWN:
			scroll_by(terminal_model.wheel_lines)
		_:
			return false

	return true

## Moves the first line on show by `lines`, positive toward the end, within the file.
func scroll_by(lines: int) -> void:
	_top = clampi(_top + lines, 0, maxi(_lines.size() - _page(), 0))
	_draw()

## Opens the file `viewing` names from its first line, or closes the popup when none is found.
func refresh() -> void:
	var file := volume_model.find(viewing.value, unlocked_modules.value)
	var open := file != null

	panel.visible = open
	title.text = file.path if open else ""
	_lines = volume_model.lines(file) if open else PackedStringArray()
	_top = 0

	_draw()

## Body lines per page.
func _page() -> int:
	return page_lines

## Shows the page from `_top` and its line counter.
func _draw() -> void:
	var last := mini(_top + _page(), _lines.size())
	body.markdown_text = TextGlyphs.patch("\n".join(_lines.slice(_top, last)))
	counter.text = "%d-%d/%d" % [mini(_top + 1, last), last, _lines.size()]

## Redraws when a file opens or closes.
func _on_viewing(_previous: Variant, _current: Variant) -> void:
	refresh()
