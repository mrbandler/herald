class_name MouseLook
extends Node

## Captures the mouse, enables the room input context and turns the pivot from mouse motion.

## Model to use.
@export var model: PlayerModel

## Rotated by the look: yaw around Y, pitch around X.
@export var pivot: Node3D

## 2D axis action carrying mouse motion in pixels.
@export var look: GUIDEAction

## Action that toggles mouse capture.
@export var release_mouse: GUIDEAction

## GUIDE context enabled on ready.
@export var room_context: GUIDEMappingContext

## Read. While true, mouse motion drives the held knob instead of the look.
@export var grabbing: BoolValue

## Read. How sleepy the Listener is, 0..1. Slows the look.
@export var drowsiness: FloatValue

## Current yaw (x) and pitch (y) in degrees.
var angles := Vector2.ZERO

## Enables the room context, captures the mouse and listens for the release toggle.
func _ready() -> void:
	GUIDE.enable_mapping_context(room_context)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	release_mouse.just_triggered.connect(_on_release_mouse)

## Turns by this frame's mouse motion, slowed by drowsiness, unless a knob is held.
func _process(_delta: float) -> void:
	if not grabbing.value:
		turn_by(look.value_axis_2d * model.look_scale(drowsiness.value))

## Turns the pivot by a mouse motion in pixels, within the model's limits.
func turn_by(motion: Vector2) -> void:
	angles = model.turn(angles, motion)
	pivot.rotation_degrees = Vector3(angles.y, angles.x, 0.0)

## Toggles the mouse between captured and visible.
func _on_release_mouse() -> void:
	var captured := Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if captured else Input.MOUSE_MODE_CAPTURED
