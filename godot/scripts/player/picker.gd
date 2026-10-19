class_name Picker
extends Node

## Casts the crosshair ray, sets hovering, and grabs, drags and releases Interactables.

## Gives the ray's reach.
@export var model: PlayerModel

## The ray starts here and points forward for `model.reach` metres.
@export var camera: Camera3D

## Pressing grabs what is aimed at, releasing lets go.
@export var grab_action: GUIDEAction

## Its horizontal axis (pixels) is the drag.
@export var look: GUIDEAction

## While held, drags are slow and fine.
@export var fine: GUIDEAction

## Written. True while something is aimed at and nothing is held.
@export var hovering: BoolValue

## Written. True while holding something.
@export var grabbing: BoolValue

## Written. True while aiming at a spot that puts down what is in hand. Optional.
@export var placing: BoolValue

## Written. True while aiming at a button with nothing held. Optional.
@export var pointing: BoolValue

## Written. Where the crosshair ray last hit something it can use, in world space. Optional.
@export var aim_point: Vector3Value

## What is being dragged, or null. shortcut: not guarded against the held node being freed
## mid-drag; the room is static, so add is_instance_valid checks once Interactables can despawn.
var held: Interactable

## What the crosshair points at this physics frame, or null.
var _aimed: Interactable

## Connects grab and release to the grab action.
func _ready() -> void:
	grab_action.just_triggered.connect(_on_grab)
	grab_action.completed.connect(release)

## Casts the ray and updates `hovering`.
func _physics_process(_delta: float) -> void:
	_aimed = cast()
	hovering.value = held == null and _aimed != null
	if placing != null:
		placing.value = hovering.value and _aimed.is_placement()
	if pointing != null:
		pointing.value = hovering.value and _aimed.is_button()

## Passes this frame's drag to what is held.
func _process(_delta: float) -> void:
	if held != null:
		held.drag(look.value_axis_2d.x, fine.value_bool)

## Grabs `target` and starts passing it the drag.
func hold(target: Interactable) -> void:
	held = target
	grabbing.value = true
	target.grab()

## Lets go of what is held, if anything.
func release() -> void:
	if held == null:
		return

	held.release()
	held = null
	grabbing.value = false

## Grabs what is aimed at, if anything.
func _on_grab() -> void:
	if _aimed != null:
		hold(_aimed)

## The Interactable the crosshair ray hits within reach, or null.
func cast() -> Interactable:
	var from := camera.global_position
	var query := PhysicsRayQueryParameters3D.create(
		from,
		from - camera.global_basis.z * model.reach,
	)
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var hit := camera.get_world_3d().direct_space_state.intersect_ray(query)
	var collider: Object = hit.get("collider")
	if collider != null and aim_point != null:
		var point: Vector3 = hit.get("position")
		aim_point.value = point

	return collider as Interactable
