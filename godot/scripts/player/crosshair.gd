class_name Crosshair
extends TextureRect

## The one non-diegetic hint: the crosshair changes over things that can be used.

## Read. Shows the hover icon.
@export var hovering: BoolValue

## Read. Shows the grab icon.
@export var grabbing: BoolValue

## Shown while nothing usable is aimed at.
@export var idle_icon: Texture2D

## Shown over something that can be grabbed.
@export var hover_icon: Texture2D

## Shown while holding something.
@export var grab_icon: Texture2D

## Shown over a spot where the paper in hand would go down.
@export var place_icon: Texture2D

## Read. Shows the place icon.
@export var placing: BoolValue

## Shown over something that cannot be used yet.
@export var lock_icon: Texture2D

## Read. Shows the lock icon.
@export var blocked: BoolValue

## Shown over a button.
@export var point_icon: Texture2D

## Read. Shows the point icon.
@export var pointing: BoolValue

## Read. At 1, fully leaned in, the crosshair hides so it does not cover the screen's text.
@export var lean_amount: FloatValue

## Read. True while a paper is raised in front of the eye; the crosshair hides over it.
@export var paper_raised: BoolValue

## Picks the icon every frame, and hides it while fully leaned in or reading a raised paper.
func _process(_delta: float) -> void:
	var locked := blocked != null and blocked.value
	var icon := pick_icon(hovering.value, grabbing.value, placing.value, pointing.value)
	texture = lock_icon if locked else icon
	visible = shown(lean_amount.value, paper_raised.value)

## False at a full lean or over a raised paper, so the crosshair stays off text.
func shown(lean: float, reading_paper: bool) -> bool:
	return lean < 1.0 and not reading_paper

## Grabbing wins over placing, placing over pointing, pointing over hovering, hovering over idle.
func pick_icon(
	is_hovering: bool,
	is_grabbing: bool,
	is_placing := false,
	is_pointing := false,
) -> Texture2D:
	if is_grabbing:
		return grab_icon

	if is_placing:
		return place_icon

	if is_pointing:
		return point_icon

	return hover_icon if is_hovering else idle_icon
