class_name CarrierTone
extends AudioStreamPlayer3D

## Streams the procedural carrier from the receiver's atoms. Hiss only when nothing is heard.

## Model to use.
@export var model: ToneModel

## Read. 0..1, carrier against hiss.
@export var signal_strength: FloatValue

## Read. 0..1, the higher the less warble.
@export var lock_quality: FloatValue

## Read. Dial position; sweeps the colour of the hiss.
@export var tuning: FloatValue

## Read. 0..1 output volume, set by the volume knob.
@export var volume: FloatValue

## The generator playback frames are pushed into. Null until `_ready` starts the stream.
var _playback: AudioStreamGeneratorPlayback

## Seconds of audio generated so far; the carrier and warble phase run on it.
var _time := 0.0

## Noise source for the hiss.
var _rng := RandomNumberGenerator.new()

## Low-pass state of the hiss.
var _hiss := 0.0

## Builds the generator stream and starts it.
func _ready() -> void:
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = model.mix_rate
	generator.buffer_length = 0.1
	stream = generator

	play()

	_playback = get_stream_playback() as AudioStreamGeneratorPlayback

## Sets the volume and fills the free buffer with samples for the current atoms.
func _process(_delta: float) -> void:
	if _playback == null:
		return

	# Cubed so the knob feels even: loudness follows amplitude roughly logarithmically.
	volume_linear = pow(volume.value, 3.0)

	var strength := signal_strength.value
	var alpha := model.hiss_alpha(tuning.value)
	var gain := model.hiss_gain(alpha)
	var quality := lock_quality.value
	var step := 1.0 / model.mix_rate

	for _i: int in range(_playback.get_frames_available()):
		_hiss += alpha * (_rng.randf_range(-1.0, 1.0) - _hiss)

		var noise := clampf(_hiss * gain, -1.0, 1.0)
		var s := model.sample(_time, strength, quality, noise)

		_playback.push_frame(Vector2(s, s))
		_time += step
