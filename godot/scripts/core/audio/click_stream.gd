@tool
class_name ClickStream
extends AudioStreamWAV

## A short mechanical tick, generated from its settings: a decaying noise burst over a ping.

## Samples per second.
@export var rate := 22050:
	set(value):
		rate = value
		_build()
## Length of the tick in seconds.
@export var duration := 0.025:
	set(value):
		duration = value
		_build()
## Pitch of the ping in Hz.
@export var pitch := 2400.0:
	set(value):
		pitch = value
		_build()
## Peak amplitude, 0..1.
@export var level := 0.5:
	set(value):
		level = value
		_build()


func _init() -> void:
	_build()


func _build() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var frames := int(rate * duration)
	var bytes := PackedByteArray()
	bytes.resize(frames * 2)
	for i: int in range(frames):
		var t := float(i) / rate
		var envelope := exp(-t / (duration * 0.2))
		var s := (0.6 * rng.randf_range(-1.0, 1.0) + 0.4 * sin(TAU * pitch * t)) * envelope
		bytes.encode_s16(i * 2, int(clampf(s * level, -1.0, 1.0) * 32767.0))
	format = AudioStreamWAV.FORMAT_16_BITS
	mix_rate = rate
	stereo = false
	data = bytes
