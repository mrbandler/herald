class_name AlertPopup
extends Node

## The alert box on the CRT: shows `alert` over the dimmed screen until the Listener acknowledges
## it with Enter. Every other key but Esc is swallowed while it is up.

## Read and cleared. The alert text, empty while no alert is up.
@export var alert: StringValue

## Read. Keys count only while the terminal is focused.
@export var focused: BoolValue

## The box, shown while an alert is up.
@export var panel: Control

## Shows the alert text.
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
	if alert.value.is_empty() or keycode == KEY_ESCAPE:
		return false

	if keycode == KEY_ENTER or keycode == KEY_KP_ENTER:
		alert.value = ""

	return true

## Redraws when an alert comes or goes.
func _on_alert(_previous: Variant, _current: Variant) -> void:
	_draw()

## Shows the box with the alert text, or hides it.
func _draw() -> void:
	panel.visible = not alert.value.is_empty()
	body.text = alert.value
