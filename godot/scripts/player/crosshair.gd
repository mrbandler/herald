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

## Read. At 1, fully leaned in, the crosshair hides so it does not cover the screen's text.
@export var lean_amount: FloatValue

## Picks the icon every frame, and hides it while fully leaned in.
func _process(_delta: float) -> void:
	texture = pick_icon(hovering.value, grabbing.value)
	visible = shown(lean_amount.value)

## False at a full lean, so the crosshair stays off the terminal's text.
func shown(lean: float) -> bool:
	return lean < 1.0

## Grabbing wins over hovering, hovering over idle.
func pick_icon(is_hovering: bool, is_grabbing: bool) -> Texture2D:
	if is_grabbing:
		return grab_icon

	return hover_icon if is_hovering else idle_icon
