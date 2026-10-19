class_name DeskPaper
extends Interactable

## A paper lying on the desk or in the tube's tray. Clicking it lifts it into the player's hand,
## or swaps it with the paper already in hand.

## Thickness of the click box in metres.
const THICKNESS := 0.004

## Metres a swapped-in paper lies in front of the one it replaced, so the two never share a spot.
const SWAP_LIFT := 0.001

## The paper it shows.
@export var paper: Paper

## Read. Fills the paper's fields.
@export var current_pass: ResourceValue

## The paper in hand, null when none. Written on grab.
@export var reading: ResourceValue

## Moves the paper in hand to a transform. Raised on a swap, followed while its paper is in hand.
@export var put_down: Event

## The click box, off while its paper is in hand.
var _shape := CollisionShape3D.new()

## The paper's look, laid face up.
var _sheet := PaperSheet.new()

## Attaches the click box and the sheet, so they are freed with this node even outside a tree.
func _init() -> void:
	add_child(_shape)
	_sheet.rotation_degrees.x = -90.0
	add_child(_sheet)

## Sizes the click box and the sheet to `paper`, and listens for reading and putting down.
func _ready() -> void:
	var box := BoxShape3D.new()
	box.size = Vector3(paper.size.x, THICKNESS, paper.size.y)
	_shape.shape = box
	_sheet.show_paper(paper.size, paper.text_for(current_pass.value as PassWindow))

	reading.updated.connect(_on_reading)
	put_down.raised.connect(_on_put_down)

## Lifts its paper into the hand. A paper already in hand takes its place first.
func grab() -> void:
	if reading.value != null and reading.value != paper:
		put_down.raise(global_transform.translated_local(Vector3.UP * SWAP_LIFT))

	reading.value = paper

## Hides while its paper is in hand, and shows again once it is not.
func _on_reading(_previous: Variant, _current: Variant) -> void:
	var in_hand := reading.value == paper
	visible = not in_hand
	_shape.set_deferred("disabled", in_hand)

## Takes the transform it is put down at, while its paper is the one in hand.
func _on_put_down(at: Variant) -> void:
	if reading.value != paper:
		return

	var placed: Transform3D = at
	global_transform = placed
