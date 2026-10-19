class_name PlayerModel
extends Resource

## The seated player: look limits, reach and the terminal lean.

@export_group("Look")
## Degrees per pixel of mouse motion.
@export var sensitivity := 0.12

## Share of the look speed lost at full drowsiness, so a sleepy Listener turns slowly.
@export var drowsy_slowdown := 0.6

## Metres in front of the camera a raised paper floats.
@export var paper_distance := 0.3

## Camera pitch in degrees where a held paper starts to sink while the player looks down.
@export var paper_lower_start := -5.0

## Camera pitch in degrees where a held paper is fully lowered, so the controls stay usable.
@export var paper_lower_full := -20.0

## Camera pitch in degrees where a held paper starts to dip straight down while the player
## looks up, e.g. at the pin board.
@export var paper_dip_start := 0.0

## Camera pitch in degrees where a held paper has dipped all the way.
@export var paper_dip_full := 6.0

## Metres a fully dipped paper sinks, so the crosshair shows above it where it would be pinned.
@export var paper_dip_drop := 0.14

## How quickly a held paper follows the look, per second. Lower trails more.
@export var paper_follow_rate := 8.0

## Where a lowered paper hangs, in camera space: the bottom right of the view.
@export var paper_lowered_offset := Vector3(0.1, -0.18, -0.3)

## Degrees a lowered paper tilts back.
@export var paper_lowered_tilt := 30.0

## Furthest yaw either side of forward, in degrees.
@export var yaw_limit := 100.0

## Lowest pitch in degrees. Negative looks down.
@export var pitch_min := -65.0

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

## How fast the look turns at `drowsy` 0..1: full speed awake, slower as sleep comes.
func look_scale(drowsy: float) -> float:
	return 1.0 - drowsy_slowdown * drowsy

## How far a held paper is lowered at camera `pitch` in degrees: 0 looking ahead, easing to 1
## between `paper_lower_start` and `paper_lower_full`.
func paper_lowering(pitch: float) -> float:
	return smoothstep(-paper_lower_start, -paper_lower_full, -pitch)

## How far a held paper dips at camera `pitch` in degrees: 0 looking ahead, easing to 1 between
## `paper_dip_start` and `paper_dip_full` looking up.
func paper_dipping(pitch: float) -> float:
	return smoothstep(paper_dip_start, paper_dip_full, pitch)
