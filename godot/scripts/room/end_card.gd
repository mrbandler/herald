class_name EndCard
extends CanvasLayer

## Covers the screen when the game ends: a title, what happened, and the way back in. R retries
## the window from its checkpoint where that is offered; after an ending, C rolls the credits;
## N starts over from window 1.

## Shown over everything once the game ends.
@export var panel: Control

## The card's heading.
@export var title: Label

## What happened.
@export var body: Label

## Which keys lead back in.
@export var keys: Label

## The credits, shown in place of the body after an ending.
@export var credits: Label

## The credits' text file.
@export_file("*.md") var credits_path := "res://game/data/credits.md"

## Restores the window's start, or resets the campaign.
@export var checkpoint: Checkpoint

## Shown on the keys line when the window can be retried.
@export var retry_keys := "R  TRY THIS WINDOW AGAIN        N  START OVER"

## Shown on the keys line when only starting over is left.
@export var start_over_keys := "N  START OVER"

## Shown on the keys line after an ending.
@export var ending_keys := "C  CREDITS        N  START OVER"

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
	keys.text = retry_keys if can_retry else ending_keys
	body.visible = true
	credits.visible = false
	panel.visible = true

## Swaps the ending for the credits.
func show_credits() -> void:
	title.text = "CREDITS"
	credits.text = FileAccess.get_file_as_string(credits_path).strip_edges()
	body.visible = false
	credits.visible = true
	keys.text = start_over_keys

## R retries, N starts over, while the card is up.
func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if not panel.visible or key == null or not key.pressed:
		return

	if key.keycode == KEY_C and not _can_retry and not credits.visible:
		show_credits()
		get_viewport().set_input_as_handled()
		return

	if key.keycode == KEY_R and _can_retry:
		checkpoint.retry()
	elif key.keycode == KEY_N:
		checkpoint.start_over()
	else:
		return

	get_viewport().set_input_as_handled()
	get_tree().reload_current_scene()
