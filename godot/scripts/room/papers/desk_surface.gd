class_name DeskSurface
extends Interactable

## The desk top, or the pin wall behind it, while a paper is in hand: a click puts the paper down
## there, turned toward the chair or hung upright. Without a paper in hand it takes no clicks.

## Metres a put-down paper lies above the aim point, so it does not sink into the desk.
const LIFT := 0.002

## The paper in hand, null when none. Cleared on put-down.
@export var reading: ResourceValue

## Read. Where the crosshair ray hits.
@export var aim_point: Vector3Value

## Raised with where the paper in hand goes.
@export var put_down: Event

## Where the player sits. Put-down papers turn toward it.
@export var chair := Vector3.ZERO

## Hangs papers upright facing the room (+Z), for the pin wall. Off lays them flat.
@export var upright := false

## The click box over the desk, on only while a paper is in hand.
@export var shape: CollisionShape3D

## Listens for papers coming into and leaving the hand.
func _ready() -> void:
	reading.updated.connect(_on_reading)
	shape.disabled = reading.value == null

## The desk is where papers go down.
func is_placement() -> bool:
	return true

## Puts the paper in hand down at the aim point.
func grab() -> void:
	if reading.value == null:
		return

	put_down.raise(placement(aim_point.value))
	reading.value = null

## A transform at `point`, lifted a little and turned so the paper's foot faces the chair, or
## hung upright with its foot down when `upright`.
func placement(point: Vector3) -> Transform3D:
	if upright:
		return Transform3D(Basis(Vector3.RIGHT, PI / 2.0), point + Vector3.BACK * LIFT)

	var spot := point + Vector3.UP * LIFT
	var toward := chair - spot
	var yaw := atan2(toward.x, toward.z)
	return Transform3D(Basis(Vector3.UP, yaw), spot)

## Takes clicks only while a paper is in hand.
func _on_reading(_previous: Variant, _current: Variant) -> void:
	shape.set_deferred("disabled", reading.value == null)
