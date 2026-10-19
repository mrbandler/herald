class_name MusicModel
extends Resource

## The background music: its notes, how the antenna knob sets the layers, and how the countdown
## to each pass mark sets stress. Pure data plus math.

## Audio samples per second.
@export var mix_rate := 22050.0

## Overall loudness against the antenna, 0..1.
@export var music_level := 0.5

## Seconds the synth takes to follow a change of knob or stress, so nothing clicks.
@export var glide_seconds := 0.3

@export_group("Notes")
## Pad notes in Hz, each played as a detuned pair: E2, E3, B3, E4.
@export var pad_notes := PackedFloat32Array([82.41, 164.81, 246.94, 329.63])

## Colour notes in Hz, softer than the pad: D4, F#4, G4.
@export var color_notes := PackedFloat32Array([293.66, 369.99, 392.0])

## Bass note in Hz: E2.
@export var bass_note := 82.41

## Pluck notes in Hz, picked at random: G4, B4.
@export var pluck_notes := PackedFloat32Array([392.0, 493.88])

## Motif notes in Hz, in play order: D5, E5.
@export var motif_notes := PackedFloat32Array([587.33, 659.26])

## Tension note in Hz: F3, a half step above the E.
@export var tension_note := 174.61

## Seconds from one motif to the next, measured from the reference.
@export var cycle_seconds := 5.75

@export_group("Voices")
## Detune of each pad pair, in cents either way.
@export var detune_cents := 6.0

## Pad wobble speed in Hz.
@export var wobble_rate := 0.15

## How far the wobble dips the pad, 0..1.
@export var wobble_depth := 0.25

## Pad loudness, 0..1.
@export var pad_level := 0.3

## Colour note loudness, 0..1.
@export var color_level := 0.1

## Bass loudness, 0..1.
@export var bass_level := 0.25

## Seconds the bass takes to come back after each motif start.
@export var bass_duck_seconds := 0.8

## Pluck loudness, 0..1.
@export var pluck_level := 0.15

## Seconds a pluck takes to reach full loudness.
@export var pluck_attack := 0.01

## Seconds for a pluck to fade to about a third.
@export var pluck_decay := 0.5

## Motif loudness, 0..1.
@export var motif_level := 0.15

## Seconds each motif note lasts.
@export var motif_note_seconds := 0.75

## Seconds each motif note takes to swell in and to fade out.
@export var motif_fade_seconds := 0.2

## Loudness of the motif's second (x) and third (y) harmonic against its fundamental.
@export var motif_overtones := Vector2(0.5, 0.33)

## Breath noise on the motif, 0..1 of the motif's loudness.
@export var breath_level := 0.3

## Tension loudness at full tension, 0..1.
@export var tension_level := 0.12

@export_group("Stress")
## Stress at the start (x) and the end (y) of the time before AOS.
@export var pre_aos_stress := Vector2(0.0, 0.2)

## Stress at AOS (x) and at the UPLINK mark (y).
@export var downlink_stress := Vector2(0.3, 0.6)

## Stress at the UPLINK mark (x) and at LOS (y).
@export var uplink_stress := Vector2(0.8, 1.0)

## Shapes the rise inside a phase: above 1, most of it lands near the mark.
@export var build_curve := 2.0

## Seconds after LOS for stress to fall back to 0.
@export var settle_seconds := 20.0

@export_group("Knob")
## Bed loudness at full knob, 0..1. The bed is never silent.
@export var bed_floor := 0.25

## Shapes how the melody comes in as the knob goes down: above 1, it waits for a low knob.
@export var melody_curve := 1.5

@export_group("Layers")
## Pluck gap range in seconds, min (x) to max (y), at stress 0.
@export var pluck_gap_relaxed := Vector2(1.2, 2.0)

## Pluck gap range in seconds, min (x) to max (y), at stress 1.
@export var pluck_gap_tense := Vector2(0.25, 0.4)

## Seconds before the first pluck.
@export var pluck_gap_first := 0.5

## Low-pass cutoff in Hz at stress 0.
@export var cutoff_min := 900.0

## Low-pass cutoff in Hz at stress 1, never passed.
@export var cutoff_max := 2000.0

## Stress where the bass starts to pulse.
@export var bass_pulse_start := 0.3

## How far the bass dips on each pulse at stress 1, 0..1.
@export var bass_pulse_max := 0.6

## Stress from which the motif plays every cycle instead of every other one.
@export var motif_dense_from := 0.4

## Stress where the tension starts to fade in.
@export var tension_start := 0.7

## Stress 0..1 at `t` seconds into `window`. Rises toward each mark, falls to 0 after LOS.
## A mark belongs to the phase it starts. A null window gives 0.
func stress_at(window: PassWindow, t: float) -> float:
	if window == null:
		return 0.0

	if t >= window.los:
		var settled := 1.0
		if settle_seconds > 0.0:
			settled = clampf((t - window.los) / settle_seconds, 0.0, 1.0)

		return lerpf(uplink_stress.y, 0.0, settled)

	if t >= window.speak:
		return _build(uplink_stress, window.speak, window.los, t)

	if t >= window.aos:
		return _build(downlink_stress, window.aos, window.speak, t)

	return _build(pre_aos_stress, 0.0, window.aos, t)

## Pad and bass loudness 0..1 at antenna knob `knob`: `bed_floor` at full knob, 1 at zero.
func bed_level(knob: float) -> float:
	return lerpf(bed_floor, 1.0, 1.0 - clampf(knob, 0.0, 1.0))

## Plucks and motif loudness 0..1 at antenna knob `knob`: silent at full knob, 1 at zero.
func melody_level(knob: float) -> float:
	return pow(1.0 - clampf(knob, 0.0, 1.0), melody_curve)

## Seconds to the next pluck at stress `level`. `roll` 0..1 picks inside the range.
func pluck_gap(level: float, roll: float) -> float:
	var gaps := pluck_gap_relaxed.lerp(pluck_gap_tense, clampf(level, 0.0, 1.0))
	return lerpf(gaps.x, gaps.y, roll)

## Low-pass cutoff in Hz at stress `level`, from `cutoff_min` to `cutoff_max`.
func cutoff(level: float) -> float:
	return lerpf(cutoff_min, cutoff_max, clampf(level, 0.0, 1.0))

## One-pole low-pass coefficient 0..1 for `cutoff_hz` at `mix_rate`.
func low_pass_alpha(cutoff_hz: float) -> float:
	return 1.0 - exp(-TAU * cutoff_hz / mix_rate)

## Per-sample step 0..1 that glides a level to its target in about `glide_seconds`.
func glide() -> float:
	return 1.0 - exp(-1.0 / (mix_rate * glide_seconds))

## How far the bass dips on each pulse at stress `level`, 0..`bass_pulse_max`.
func bass_pulse(level: float) -> float:
	if level <= bass_pulse_start:
		return 0.0

	return bass_pulse_max * clampf((level - bass_pulse_start) / (1.0 - bass_pulse_start), 0.0, 1.0)

## Seconds per bass pulse: eight per motif cycle, so the pulse stays locked to the motif.
func pulse_seconds() -> float:
	return cycle_seconds / 8.0

## True when the motif plays every cycle at stress `level`, false for every other cycle.
func motif_every_cycle(level: float) -> bool:
	return level >= motif_dense_from

## Tension amount 0..1 at stress `level`: silent up to `tension_start`, full at 1.
func tension(level: float) -> float:
	return clampf((level - tension_start) / (1.0 - tension_start), 0.0, 1.0)

## Stress inside one phase from `start` to `mark`: `levels.x` at its start, `levels.y` at the
## mark. A phase of zero length gives `levels.y`.
func _build(levels: Vector2, start: float, mark: float, t: float) -> float:
	var span := mark - start
	var p := 1.0 if span <= 0.0 else clampf((t - start) / span, 0.0, 1.0)

	return lerpf(levels.x, levels.y, pow(p, build_curve))
