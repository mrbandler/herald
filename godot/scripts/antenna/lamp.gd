class_name Lamp
extends MeshInstance3D

## A console lamp driven by a BoolValue, optionally blinking by a FloatValue.

## Model to use.
@export var model: LampModel

## Steady on while true.
@export var source: BoolValue

## Optional: the lamp blinks while this is above zero and `source` is off.
@export var blink_source: FloatValue

## Lit colour. Unlit, the lamp shows it darkened.
@export var color := Color(0.3, 1.0, 0.4)

## The lamp's own material; its emission energy is the light.
var _material := StandardMaterial3D.new()

## Sets up the material in the lamp's colour and applies it.
func _ready() -> void:
	_material.albedo_color = color.darkened(0.7)
	_material.emission_enabled = true
	_material.emission = color

	material_override = _material

## Lights the lamp for the current source, blink source and time.
func _process(_delta: float) -> void:
	var blink_level := blink_source.value if blink_source != null else 0.0
	var lamp_state := model.state(source.value, blink_level)

	_material.emission_energy_multiplier = model.energy(lamp_state, Time.get_ticks_msec() / 1000.0)
