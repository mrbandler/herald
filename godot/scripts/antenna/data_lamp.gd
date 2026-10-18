class_name DataLamp
extends MeshInstance3D

## The console's data lamp: a short flash for every row that arrives. Readable from the corner
## of the eye while tracking.

## Lit and dark emission energies.
@export var model: LampModel

## Flashes the lamp.
@export var row_received: Event

## Seconds each flash lasts.
@export var pulse_seconds := 0.06

## Lit colour. Unlit, the lamp shows it darkened.
@export var color := Color(1.0, 0.85, 0.3)

## Seconds left on the current flash.
var _left := 0.0

## The lamp's own material.
var _material := StandardMaterial3D.new()

## Builds the material and listens for rows.
func _ready() -> void:
	_material.albedo_color = color.darkened(0.7)
	_material.emission_enabled = true
	_material.emission = color
	material_override = _material
	row_received.raised.connect(_on_row)

## Counts the flash down each frame.
func _process(delta: float) -> void:
	tick(delta)

## Counts the flash down by `delta` seconds and sets the emission.
func tick(delta: float) -> void:
	_left = maxf(_left - delta, 0.0)
	_material.emission_energy_multiplier = energy()

## The current emission energy: lit during a flash.
func energy() -> float:
	return model.on_energy if _left > 0.0 else model.off_energy

## Starts a flash.
func _on_row(_payload: Variant) -> void:
	_left = pulse_seconds
