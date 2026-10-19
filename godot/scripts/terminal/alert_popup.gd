class_name AlertPopup
extends Node

## The alert box on the CRT: shows the `Alert` in `alert` under a warning triangle, over the
## dimmed screen, until the Listener acknowledges it with Enter. Every other key but Esc is
## swallowed while it is up.

## The warning triangle over every alert. The label centres each row on its own, so every row
## is two characters wider than the one above.
const TRIANGLE := (
	"/\\\n/  \\\n/ !! \\\n/  !!  \\\n/        \\\n/    !!    \\\n" + "/____________\\"
)

## Read and cleared. The `Alert` on show, null while none is up.
@export var alert: ResourceValue

## Read. Keys count only while the terminal is focused.
@export var focused: BoolValue

## The box, shown while an alert is up.
@export var panel: Control

## Shows the triangle, the title and the explainer.
@export var body: Label

## Listens for alerts and draws the start state.
func _ready() -> void:
	alert.updated.connect(_on_alert)
	_draw()

## Feeds key presses to `handle_key` while the terminal is focused.
func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or not focused.value:
		return

	if handle_key(key.keycode):
		get_viewport().set_input_as_handled()

## Enter acknowledges the alert. Returns true for every key it swallows: all but Esc while an
## alert is up, so Esc can still leave the terminal.
func handle_key(keycode: Key) -> bool:
	if alert.value == null or keycode == KEY_ESCAPE:
		return false

	if keycode == KEY_ENTER or keycode == KEY_KP_ENTER:
		alert.value = null

	return true

## The box's text for `shown`: the triangle, the title between exclamation marks, the explainer.
static func text_for(shown: Alert) -> String:
	return "%s\n\n!! %s !!\n\n%s" % [TRIANGLE, shown.title, shown.explainer]

## Redraws when an alert comes or goes.
func _on_alert(_previous: Variant, _current: Variant) -> void:
	_draw()

## Shows the box with the alert, or hides it.
func _draw() -> void:
	var shown := alert.value as Alert
	panel.visible = shown != null
	body.text = AlertPopup.text_for(shown) if shown != null else ""
