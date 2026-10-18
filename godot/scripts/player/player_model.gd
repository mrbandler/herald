class_name PlayerModel
extends Resource

## The seated player: look limits, reach and the terminal lean.

@export_group("Look")
## Degrees per pixel of mouse motion.
@export var sensitivity := 0.12

## Furthest yaw either side of forward, in degrees.
@export var yaw_limit := 100.0

## Lowest pitch in degrees. Negative looks down.
@export var pitch_min := -45.0

## Highest pitch in degrees.
@export var pitch_max := 35.0

@export_group("Reach")
## Metres the crosshair ray reaches.
@export var reach := 2.5

@export_group("Lean")
## Leaned-in camera position relative to the terminal focus point.
@export var lean_offset := Vector3(0.0, 0.0, 0.45)

## Lean blend per second.
@export var lean_speed := 4.0

## Look-away angle in degrees below which the lean is full.
@export var lean_start := 15.0

## Look-away angle in degrees beyond which the player sits back.
@export var lean_full := 45.0

## Yaw and pitch in degrees after a mouse motion in pixels.
func turn(angles: Vector2, motion: Vector2) -> Vector2:
	var yaw := clampf(angles.x - motion.x * sensitivity, -yaw_limit, yaw_limit)
	var pitch := clampf(angles.y - motion.y * sensitivity, pitch_min, pitch_max)

	return Vector2(yaw, pitch)

## Lean blend 0..1 for the angle in degrees between the view and the terminal.
func lean_amount(look_away_degrees: float) -> float:
	return 1.0 - smoothstep(lean_start, lean_full, look_away_degrees)
