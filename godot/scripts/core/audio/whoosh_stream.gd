@tool
class_name WhooshStream
extends AudioStreamWAV

## A pneumatic delivery, generated from its settings: rushing air that swells through the tube,
## then the capsule's thunk as it lands.

## Samples per second.
@export var rate := 22050:
	set(value):
		rate = value
		_build()

## Length of the whole sound in seconds.
@export var duration := 1.3:
	set(value):
		duration = value
		_build()

## Share of `duration` the air rushes before the thunk.
@export var rush := 0.7:
	set(value):
		rush = value
		_build()

## How much of each new noise sample passes the low-pass, 0..1. Lower sounds deeper.
@export var air := 0.12:
	set(value):
		air = value
		_build()

## Pitch of the thunk in Hz.
@export var thunk_pitch := 70.0:
	set(value):
		thunk_pitch = value
		_build()

## Peak amplitude, 0..1.
@export var level := 0.9:
	set(value):
		level = value
		_build()

## Builds the samples from the defaults.
func _init() -> void:
	_build()

## Renders the samples as 16-bit mono and stores them in the stream.
func _build() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 11

	var frames := int(rate * duration)
	var landing := duration * rush
	var bytes := PackedByteArray()
	bytes.resize(frames * 2)

	var rushing := 0.0
	for i: int in range(frames):
		var t := float(i) / rate
		rushing += air * (rng.randf_range(-1.0, 1.0) - rushing)
		var swell := pow(sin(PI * clampf(t / landing, 0.0, 1.0)), 2.0)
		var s := rushing * 3.0 * swell

		var since := t - landing
		if since >= 0.0:
			var knock := 0.7 * sin(TAU * thunk_pitch * since) + 0.3 * rng.randf_range(-1.0, 1.0)
			s += knock * exp(-since / 0.07)

		bytes.encode_s16(i * 2, int(clampf(s * level, -1.0, 1.0) * 32767.0))

	format = AudioStreamWAV.FORMAT_16_BITS
	mix_rate = rate
	stereo = false
	data = bytes
