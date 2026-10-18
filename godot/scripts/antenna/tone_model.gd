class_name ToneModel
extends Resource

## The carrier sound: hiss against tone by strength, warble by poor lock.

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

## Dial units per full sweep of the hiss colour, so every turn of the dial is heard.
@export var hiss_sweep_units := 1.0

## Darkest hiss: low-pass coefficient 0..1, lower is duller.
@export var hiss_alpha_min := 0.08

## Brightest hiss: low-pass coefficient 0..1, 1 is white noise.
@export var hiss_alpha_max := 0.9

## Low-pass coefficient for the hiss at dial position `tuning`, cycling every `hiss_sweep_units`.
func hiss_alpha(tuning: float) -> float:
	var phase := 0.5 + 0.5 * sin(TAU * tuning / hiss_sweep_units)

	return lerpf(hiss_alpha_min, hiss_alpha_max, phase)

## Gain that brings noise low-passed with `alpha` back to the loudness of white noise.
func hiss_gain(alpha: float) -> float:
	return sqrt((2.0 - alpha) / alpha)

## One mono sample at `t` seconds, within -1..1 for `strength` and `quality` in 0..1.
## `noise` is a random value in -1..1. `strength` mixes hiss against carrier, `quality` calms
## the warble, so a locked carrier is a steady tone.
func sample(t: float, strength: float, quality: float, noise: float) -> float:
	var warble := warble_depth * (1.0 - quality) * sin(TAU * warble_rate * t)
	var carrier := sin(TAU * carrier_pitch * t + warble)

	return noise * hiss_level * (1.0 - 0.6 * strength) + carrier * carrier_level * strength
