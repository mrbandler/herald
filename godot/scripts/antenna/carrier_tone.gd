class_name CarrierTone
extends AudioStreamPlayer3D

## Streams the procedural carrier from the receiver's atoms. Hiss only when nothing is heard.

@export var model: ToneModel
## Read. 0..1, carrier against hiss.
@export var signal_strength: FloatValue
## Read. 0..1, the higher the less warble.
@export var lock_quality: FloatValue
## Read. While true the carrier pulses (the station is listening).
@export var turn_active: BoolValue

var _playback: AudioStreamGeneratorPlayback
var _time := 0.0
# Seconds since the Turn began; negative while not listening.
var _listening_for := -1.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = model.mix_rate
	generator.buffer_length = 0.1
	stream = generator
	play()
	_playback = get_stream_playback() as AudioStreamGeneratorPlayback


func _process(_delta: float) -> void:
	if _playback == null:
		return
	var strength := signal_strength.value
	var quality := lock_quality.value
	if not turn_active.value:
		_listening_for = -1.0
	elif _listening_for < 0.0:
		_listening_for = 0.0
	var step := 1.0 / model.mix_rate
	for _i: int in range(_playback.get_frames_available()):
		var noise := _rng.randf_range(-1.0, 1.0)
		var s := model.sample(_time, strength, quality, _listening_for, noise)
		_playback.push_frame(Vector2(s, s))
		_time += step
		if _listening_for >= 0.0:
			_listening_for += step
