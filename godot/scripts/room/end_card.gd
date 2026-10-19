class_name EndCard
extends CanvasLayer

## Covers the screen when the game ends: a title, what happened, and the way back in. R retries
## the window from its checkpoint where that is offered; N starts over from window 1.

## Shown over everything once the game ends.
@export var panel: Control

## The card's heading.
@export var title: Label

## What happened.
@export var body: Label

## Which keys lead back in.
@export var keys: Label

## Restores the window's start, or resets the campaign.
@export var checkpoint: Checkpoint

## Shown on the keys line when the window can be retried.
@export var retry_keys := "R  TRY THIS WINDOW AGAIN        N  START OVER"

## Shown on the keys line when only starting over is left.
@export var start_over_keys := "N  START OVER"

## True when R retries the window.
var _can_retry := false

## Starts hidden.
func _ready() -> void:
	panel.visible = false

## Shows the card with `heading` and `text`. `can_retry` offers the window's checkpoint.
func show_card(heading: String, text: String, can_retry: bool) -> void:
	_can_retry = can_retry
	title.text = heading
	body.text = text
	keys.text = retry_keys if can_retry else start_over_keys
	panel.visible = true

## R retries, N starts over, while the card is up.
func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if not panel.visible or key == null or not key.pressed:
		return

	if key.keycode == KEY_R and _can_retry:
		checkpoint.retry()
	elif key.keycode == KEY_N:
		checkpoint.start_over()
	else:
		return

	get_viewport().set_input_as_handled()
	get_tree().reload_current_scene()
