class_name NeedleModel
extends Resource

## The needle's spring: it lags, and overshoots when damping is low.

## Spring pull per unit of distance to the goal.
@export var stiffness := 60.0

## Drag on the velocity. Low values overshoot.
@export var damping := 8.0

## Needle rotation in degrees at zero signal.
@export var angle_at_zero := 50.0

## Needle rotation in degrees at full signal.
@export var angle_at_full := -50.0

## One semi-implicit Euler step of a damped spring. Returns (position, velocity).
func step(position: float, velocity: float, goal: float, delta: float) -> Vector2:
	var force := stiffness * (goal - position) - damping * velocity
	var next_velocity := velocity + force * delta

	return Vector2(position + next_velocity * delta, next_velocity)

## Needle rotation in degrees for a position from 0 to 1.
func angle(position: float) -> float:
	return lerpf(angle_at_zero, angle_at_full, position)
