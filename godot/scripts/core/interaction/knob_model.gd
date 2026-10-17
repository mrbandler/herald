class_name KnobModel
extends Resource

## How a knob turns: horizontal drag in pixels to value units, like a DAW knob.

## Value units per pixel of horizontal drag.
@export var units_per_pixel := 0.05
## Drag multiplier while the fine modifier is held.
@export var fine_factor := 0.1
## Lowest value, in units.
@export var minimum := 0.0
## Highest value, in units. When wrapping, reaching it lands back on `minimum`.
@export var maximum := 360.0
## Wrap around (azimuth) instead of stopping at the ends.
@export var wraps := false
## Visual rotation per value unit. Handwheels use 36, so one full turn is 10 units.
## A wrapping knob only turns smoothly across the wrap if range times this is a multiple of 360.
@export var visual_degrees_per_unit := 36.0


## The new value after dragging `dx` pixels, wrapped or clamped to the range.
func apply(current: float, dx: float, fine: bool) -> float:
	var next := current + dx * units_per_pixel * (fine_factor if fine else 1.0)
	return wrapf(next, minimum, maximum) if wraps else clampf(next, minimum, maximum)
