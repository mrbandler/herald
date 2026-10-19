@tool
class_name ChimeStream
extends AudioStreamWAV

## A console chime, generated from its settings: one short sine peep per note, each followed by
## a gap of silence. With `square`, a harsh buzz instead of a peep, e.g. for an alarm.

## Samples per second.
@export var rate := 22050:
	set(value):
		rate = value
		_build()

## Pitch of each peep in Hz, in play order.
@export var notes := PackedFloat32Array([1568.0, 2093.0]):
	set(value):
		notes = value
		_build()

## Length of each peep in seconds.
@export var note_seconds := 0.08:
	set(value):
		note_seconds = value
		_build()

## Silence after each peep in seconds.
@export var gap_seconds := 0.06:
	set(value):
		gap_seconds = value
		_build()

## Peak amplitude, 0..1.
@export var level := 0.35:
	set(value):
		level = value
		_build()

## Silence before the first peep in seconds, e.g. so a bell rings after another sound.
@export var lead_seconds := 0.0:
	set(value):
		lead_seconds = value
		_build()

## Buzzes with a square wave instead of a sine.
@export var square := false:
	set(value):
		square = value
		_build()

## Builds the samples from the defaults.
func _init() -> void:
	_build()

## Renders the samples as 16-bit mono and stores them in the stream.
func _build() -> void:
	var note_frames := int(rate * note_seconds)
	var step_frames := int(rate * (note_seconds + gap_seconds))
	var lead_frames := int(rate * lead_seconds)

	var bytes := PackedByteArray()
	bytes.resize((lead_frames + notes.size() * step_frames) * 2)

	for n: int in range(notes.size()):
		for i: int in range(note_frames):
			var t := float(i) / rate
			# Fast attack and a fade to the end, so the peep starts and stops without a click.
			var envelope := minf(t / 0.004, 1.0) * (1.0 - float(i) / note_frames)
			var wave := sin(TAU * notes[n] * t)
			var s := (signf(wave) if square else wave) * envelope * level

			bytes.encode_s16(
				(lead_frames + n * step_frames + i) * 2,
				int(clampf(s, -1.0, 1.0) * 32767.0),
			)

	format = AudioStreamWAV.FORMAT_16_BITS
	mix_rate = rate
	stereo = false
	data = bytes
