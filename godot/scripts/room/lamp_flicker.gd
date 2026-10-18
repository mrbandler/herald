class_name LampFlicker
extends Node

## Flickers the desk lamp in the last seconds before the morning bell: the Listener is nodding off.

## Seconds a flicker state is held, so the lamp stutters instead of strobing.
const HOLD := 0.08

## Dimmed while flickering. Its energy at ready is the steady level.
@export var light: Light3D
## Read. Seconds since pass start.
@export var pass_time: FloatValue
## Read. Supplies the bell time.
@export var current_pass: ResourceValue
## Supplies `sleep_warning_seconds`.
@export var tunables: Tunables
## Stops the flicker so the shift end can dim the lamp.
@export var shift_ended: Event

var _steady := 0.0
var _running := true
var _held := 0.0
var _rng := RandomNumberGenerator.new()
var _noise := 1.0


func _ready() -> void:
	_steady = light.light_energy
	shift_ended.raised.connect(_on_shift_ended)


func _process(delta: float) -> void:
	_held += delta
	if _held >= HOLD:
		_held = 0.0
		_noise = _rng.randf()
	tick(_noise)


## Lamp level 0..1 at `progress` (0 when the warning starts, 1 at the bell) for a `noise` roll
## in 0..1. Dips get more likely as sleep nears.
static func level(progress: float, noise: float) -> float:
	if progress <= 0.0:
		return 1.0
	return 0.25 if noise < 0.5 * progress else 1.0


## Sets the lamp for the current time and a `noise` roll in 0..1.
func tick(noise: float) -> void:
	var window := current_pass.value as PassWindow
	if not _running or window == null:
		return
	var warning := tunables.sleep_warning_seconds
	var progress := clampf((pass_time.value - (window.bell - warning)) / warning, 0.0, 1.0)
	light.light_energy = _steady * LampFlicker.level(progress, noise)


func _on_shift_ended(_payload: Variant) -> void:
	_running = false
