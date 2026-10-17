class_name ToneModel
extends Resource

## The carrier sound: hiss against tone by strength, warble by poor lock, pulse while listening.

## Audio samples per second.
@export var mix_rate := 22050.0
## Carrier frequency in Hz.
@export var carrier_pitch := 880.0
## Hiss amplitude with no signal, 0..1.
@export var hiss_level := 0.25
## Carrier amplitude at full strength, 0..1.
@export var carrier_level := 0.6
## Phase wobble in radians at zero lock quality.
@export var warble_depth := 6.0
## Warble speed in Hz.
@export var warble_rate := 5.0
## Listening pulses per second during the Turn.
@export var pulse_rate := 0.8


## One mono sample at `t` seconds, within -1..1 for `strength` and `quality` in 0..1.
## `noise` is a random value in -1..1. `strength` mixes hiss against carrier, `quality` calms
## the warble. `listening_for` is the seconds since the Turn began, negative when not listening;
## the pulse starts at full volume, so the Turn begins without a click.
func sample(t: float, strength: float, quality: float, listening_for: float, noise: float) -> float:
	var warble := warble_depth * (1.0 - quality) * sin(TAU * warble_rate * t)
	var carrier := sin(TAU * carrier_pitch * t + warble)
	if listening_for >= 0.0:
		var pulse := 0.5 + 0.5 * cos(TAU * pulse_rate * listening_for)
		carrier *= pulse * pulse
	return noise * hiss_level * (1.0 - 0.6 * strength) + carrier * carrier_level * strength
