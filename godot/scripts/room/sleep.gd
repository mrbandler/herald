class_name Sleep
extends Node

## The Listener nods off: before the morning bell the eyelids blink shut, longer and more often,
## and the head sags. `fall` shuts the eyes and drops the head to the desk; `ShiftEnd` drives it.

## Sleep model.
@export var model: SleepModel

## Its local pitch and offset are the head. MouseLook and Lean move its parent, so they don't fight.
@export var camera: Camera3D

## Grows down from the top edge as the eyes close.
@export var top_lid: Control

## Grows up from the bottom edge as the eyes close.
@export var bottom_lid: Control

## Read. Seconds since pass start.
@export var pass_time: FloatValue

## Read. Supplies the bell time.
@export var current_pass: ResourceValue

## Stops the blinking so the fall takes over.
@export var shift_ended: Event

## Blink cycles since the warning started; the fraction is the place in the current blink.
var _cycle := 0.0

## False once the shift has ended and the fall has taken over.
var _awake := true

## Listens for the end of the shift.
func _ready() -> void:
	shift_ended.raised.connect(_on_shift_ended)

## Blinks every frame.
func _process(delta: float) -> void:
	tick(delta)

## Advances the blinking by `delta` seconds and poses the lids and the head.
func tick(delta: float) -> void:
	var window := current_pass.value as PassWindow
	if not _awake or window == null:
		return

	var drowsy := model.drowsiness(pass_time.value, window.bell)
	if drowsy <= 0.0:
		_cycle = 0.0
		_pose(0.0, 0.0, Vector3.ZERO)

		return

	_cycle += delta / model.blink_period(drowsy)
	var closure := model.lid_closure(fposmod(_cycle, 1.0), drowsy)

	_pose(closure, model.sag_degrees * closure * drowsy, Vector3.ZERO)

## Poses the lids and the head at `amount` 0..1 through falling asleep.
func fall(amount: float) -> void:
	var drop := model.asleep_drop(amount)

	_pose(model.asleep_closure(amount), model.drop_degrees * drop, model.drop_offset * drop)

## Sets the lids to `closure` 0..1 and the head to `pitch_down` degrees and `offset` metres.
func _pose(closure: float, pitch_down: float, offset: Vector3) -> void:
	# Slightly past half, so the lids overlap when shut.
	top_lid.anchor_bottom = 0.52 * closure
	bottom_lid.anchor_top = 1.0 - 0.52 * closure
	camera.rotation_degrees.x = -pitch_down
	camera.position = offset

## Stops the blinking.
func _on_shift_ended(_payload: Variant) -> void:
	_awake = false
