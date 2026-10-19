class_name Terminal
extends Node

## The CRT's keyboard side: line editing, command dispatch, and drawing stdout on the screen.
## Keyboard, plus the mouse wheel for scrolling. Owns Esc: the first press closes a file popup,
## the next one leaves the terminal.

## Printed when the pass starts.
const GREETING := "LISTENING POST 4 - HTB MODULE - TYPE HELP"

## Model to use.
@export var model: TerminalModel

## Shows the composed screen text.
@export var screen: Label

## stdout. Every line raised here is drawn. Also gets the echo and errors.
@export var out: StringEvent

## Submitted lines for the Up and Down keys, capped by the model.
@export var history: StringListValue

## Keys are handled only while true. Leaving the terminal sets it false.
@export var focused: BoolValue

## Open file path, empty when no popup. Esc closes it first.
@export var viewing: StringValue

## Read. Its window's command set resolves what is typed.
@export var current_pass: ResourceValue

## Fires on Esc while the terminal context is on.
@export var leave: GUIDEAction

## GUIDE context enabled while focused.
@export var terminal_context: GUIDEMappingContext

## Raised by CLR. Empties the screen; the history is kept.
@export var clear: Event

## Read. The wheel scrolls only at 1, fully leaned in, not while looking around.
@export var lean_amount: FloatValue

## Wrapped stdout lines, oldest first, capped at the model's scrollback.
var lines := PackedStringArray()

## The input line, its history position and its scroll.
var editor := LineEditor.new()

## Connects stdout, focus, Esc and CLR, then greets.
func _ready() -> void:
	out.raised.connect(_on_out)
	focused.updated.connect(_on_focused)
	leave.just_triggered.connect(leave_pressed)
	clear.raised.connect(_on_clear)

	out.raise(GREETING)

## Drops the terminal input context when the room unloads.
func _exit_tree() -> void:
	# `focused` outlives this node across a reload, and the next room resets it before its own
	# Terminal listens, so the context would stay enabled. Drop it here.
	GUIDE.disable_mapping_context(terminal_context)

## Feeds key presses to `handle_key` while focused, and consumes only the keys it uses.
func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if not focused.value or key == null or not key.pressed:
		return

	# While a file popup is open, its keys belong to the FileViewer (built with the volumes).
	# Modifier chords (Ctrl, Alt, Meta) never type: Alt+letter would otherwise insert the letter.
	# Keys left unused stay unhandled: GUIDE reads unhandled input, so Esc still reaches `leave`.
	var chord := key.ctrl_pressed or key.alt_pressed or key.meta_pressed
	if viewing.value.is_empty() and not chord and handle_key(key.keycode, key.unicode):
		get_viewport().set_input_as_handled()

## Feeds wheel steps to `handle_wheel` while fully leaned in and no file popup is open.
func _unhandled_input(event: InputEvent) -> void:
	var button := event as InputEventMouseButton
	var leaned_in := focused.value and lean_amount.value >= 1.0
	if not leaned_in or button == null or not button.pressed or not viewing.value.is_empty():
		return

	if handle_wheel(button.button_index):
		get_viewport().set_input_as_handled()

## Scrolls `wheel_lines` back on wheel up and forward on wheel down.
## Returns false for other buttons.
func handle_wheel(button: MouseButton) -> bool:
	match button:
		MOUSE_BUTTON_WHEEL_UP:
			editor.scroll_by(model.wheel_lines, model.max_scroll(lines.size()))
		MOUSE_BUTTON_WHEEL_DOWN:
			editor.scroll_by(-model.wheel_lines, model.max_scroll(lines.size()))
		_:
			return false

	_refresh()

	return true

## Applies one key press: Enter submits, Up and Down recall history,
## Page keys scroll, printable keys are typed. Returns false for keys it does not use.
func handle_key(keycode: Key, unicode: int) -> bool:
	match keycode:
		KEY_ENTER, KEY_KP_ENTER:
			submit(editor.submit())
		KEY_BACKSPACE:
			editor.backspace()
		KEY_UP:
			editor.history_up(history.value)
		KEY_DOWN:
			editor.history_down(history.value)
		KEY_PAGEUP:
			editor.scroll_by(model.rows - 1, model.max_scroll(lines.size()))
		KEY_PAGEDOWN:
			editor.scroll_by(1 - model.rows, model.max_scroll(lines.size()))
		_:
			if unicode < 32 or unicode >= 127:
				return false

			editor.insert(char(unicode), model.max_input())

	_refresh()

	return true

## Echoes the line and remembers it, then runs its command or writes UNKNOWN COMMAND.
func submit(line: String) -> void:
	var words := CommandParser.parse(line)
	if words.is_empty():
		return

	var echo := line.to_upper().strip_edges()
	out.raise(model.prompt + echo)

	_remember(echo)

	var command := (current_pass.value as PassWindow).command_set.find(words[0])
	if command == null:
		out.raise("UNKNOWN COMMAND")

		return

	command.run(words.slice(1))

## Esc: closes the file popup first, then leaves the terminal.
func leave_pressed() -> void:
	if not focused.value:
		return

	if viewing.value.is_empty():
		focused.value = false
	else:
		viewing.value = ""

## Appends a submitted line to the history, dropping the oldest past the model's cap.
func _remember(line: String) -> void:
	var next := history.value + PackedStringArray([line])
	history.value = next.slice(maxi(next.size() - model.history_cap, 0))

## Wraps a stdout line onto the screen, keeping at most the model's scrollback.
func _on_out(line: String) -> void:
	lines.append_array(model.wrap_line(line))
	if lines.size() > model.scrollback:
		lines = lines.slice(lines.size() - model.scrollback)

	_refresh()

## Empties the screen and scrolls back to the newest line. The history is kept.
func _on_clear(_payload: Variant) -> void:
	lines = PackedStringArray()
	editor.scroll = 0

	_refresh()

## Enables the terminal input context while focused, disables it otherwise.
func _on_focused(_previous: bool, current: bool) -> void:
	if current:
		# GUIDE gives lower numbers precedence, so -1 puts the terminal context above the room's 0.
		GUIDE.enable_mapping_context(terminal_context, false, -1)
	else:
		GUIDE.disable_mapping_context(terminal_context)

## Redraws the screen from the lines, the input line and the scroll.
func _refresh() -> void:
	if screen == null:
		return

	screen.text = model.compose(lines, editor.text, editor.scroll)
