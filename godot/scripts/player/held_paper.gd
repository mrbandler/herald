class_name HeldPaper
extends Node3D

## The paper in the player's hand, hanging from the camera: raised in front to read, lowered to
## the bottom of the view while looking down or leaning in, so the controls stay usable. It
## takes no clicks: the player puts it down by clicking a spot on the desk.

## Supplies the distance, the lowering pitches, the follow rate and the lowered pose.
@export var model: PlayerModel

## Read. The paper in hand, null when none.
@export var reading: ResourceValue

## Read. Fills the paper's fields.
@export var current_pass: ResourceValue

## Read. Any lean lowers the paper, so the terminal stays visible.
@export var lean_amount: FloatValue

## Written. True while a paper is raised in front of the eye, so the crosshair can hide.
@export var raised: BoolValue

## 0 raised in front, 1 lowered to the bottom of the view.
var lowered := 0.0

## 0 raised in front, 1 dipped straight down while looking up.
var dipped := 0.0

## The paper's look, upright toward the camera.
var _sheet := PaperSheet.new()

## Attaches the sheet, so it is freed with this node even outside a tree.
func _init() -> void:
	_sheet.unlit()
	add_child(_sheet)

## Starts hidden and listens for papers coming into hand.
func _ready() -> void:
	visible = false
	reading.updated.connect(_on_reading)

## Follows the look every frame.
func _process(delta: float) -> void:
	tick(delta)

## Eases the paper down as the camera looks down, fully while the player leans, straight down a
## little while looking up, and back up when looking ahead. It trails the look a little, so the
## change never snaps.
func tick(delta: float) -> void:
	if reading.value == null:
		raised.value = false
		return

	var pitch := rad_to_deg(asin(clampf(-get_parent_node_3d().global_basis.z.y, -1.0, 1.0)))
	var goal := 1.0 if lean_amount.value > 0.0 else model.paper_lowering(pitch)
	var follow := 1.0 - exp(-model.paper_follow_rate * delta)
	lowered = lerpf(lowered, goal, follow)
	dipped = lerpf(dipped, model.paper_dipping(pitch), follow)

	var centre := Vector3(0.0, 0.0, -model.paper_distance)
	var drop := Vector3.DOWN * model.paper_dip_drop * dipped
	position = centre.lerp(model.paper_lowered_offset, lowered) + drop
	rotation_degrees.x = -model.paper_lowered_tilt * lowered
	raised.value = lowered < 0.5 and dipped < 0.5

## Shows the paper that came into hand, rising from below the view, or hides when none.
func _on_reading(_previous: Variant, _current: Variant) -> void:
	var paper := reading.value as Paper
	visible = paper != null
	if paper == null:
		raised.value = false
		return

	_sheet.show_paper(paper.size, paper.text_for(current_pass.value as PassWindow))

	# A picked-up paper comes up from below the view, then follows the look.
	lowered = 1.0
	tick(0.0)
