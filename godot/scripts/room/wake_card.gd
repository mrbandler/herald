class_name WakeCard
extends CanvasLayer

## The station leaving standby before each window: a CRT card with the mission clock and the
## station's power coming back, while the room waits paused behind it. Then it switches off like an
## old set: the picture collapses into a bright line, the line into a dot, and the room shows.

## Seconds the power takes to come back.
@export var warm_seconds := 4.0

## Seconds the picture takes to collapse into a line, and the line into a dot.
@export var zap_seconds := 0.35

## The bright line the picture collapses into.
@export var zap_color := Color(1.0, 0.8, 0.45)

## Characters inside the power bar's brackets.
@export var bar_width := 30

## Shown over everything while the station wakes.
@export var panel: ColorRect

## Shows the mission clock.
@export var clock: Label

## Shows the power bar.
@export var bar: Label

## The wall's mission clock. The card counts up to its time as the room fades in.
@export var wall_clock: WallClock

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

## Fills the bar by `delta` seconds; once full, switches off into the room and lets it run.
func tick(delta: float) -> void:
	if not panel.visible:
		return

	var was_warm := _elapsed >= warm_seconds
	_elapsed += delta
	var lead := warm_seconds - minf(_elapsed, warm_seconds)
	var seconds := wall_clock.mission_seconds() - lead if wall_clock != null else 0.0
	clock.text = WallClock.format_mission(seconds) if wall_clock != null else ""
	bar.text = DownlinkModel.draw_bar(_elapsed / warm_seconds, bar_width)
	if was_warm or _elapsed < warm_seconds:
		return

	get_tree().paused = false
	_switch_off()

## Collapses the picture into a bright line, the line into a dot, and hides the card.
func _switch_off() -> void:
	panel.pivot_offset = panel.size / 2.0
	var half := zap_seconds / 2.0
	var tween := create_tween()
	tween.tween_property(panel, "scale:y", 0.004, half).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(panel, "color", zap_color, half)
	tween.tween_property(panel, "scale:x", 0.0, half).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(panel.hide)
