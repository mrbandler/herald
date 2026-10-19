class_name WakeCard
extends CanvasLayer

## The station leaving standby before each window: a CRT card with the mission clock and the
## station's power coming back, while the room waits paused behind it. Then it fades into the room.

## Seconds the power takes to come back.
@export var warm_seconds := 4.0

## Seconds the card takes to fade into the room.
@export var fade_seconds := 0.6

## Characters inside the power bar's brackets.
@export var bar_width := 30

## Shown over everything while the station wakes.
@export var panel: Control

## Shows the mission clock.
@export var clock: Label

## Shows the power bar.
@export var bar: Label

## The wall's mission clock, read for its text.
@export var wall_clock: Label3D

## Seconds since the card came up.
var _elapsed := 0.0

## Pauses the room and shows the card.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	panel.visible = true
	tick(0.0)

## Brings the power back every frame.
func _process(delta: float) -> void:
	tick(delta)

## Fills the bar by `delta` seconds; once full, fades into the room and lets it run.
func tick(delta: float) -> void:
	if not panel.visible:
		return

	var was_warm := _elapsed >= warm_seconds
	_elapsed += delta
	clock.text = wall_clock.text if wall_clock != null else ""
	bar.text = DownlinkModel.draw_bar(_elapsed / warm_seconds, bar_width)
	if was_warm or _elapsed < warm_seconds:
		return

	get_tree().paused = false
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, fade_seconds)
	tween.tween_callback(panel.hide)
