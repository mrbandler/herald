@tool
class_name SwitchStream
extends AudioStreamWAV

## A mechanical key switch, generated from its settings: a short click of the leaf as the key
## goes down, then the deeper thock of the keycap bottoming out on the plate.

## Samples per second.
@export var rate := 22050:
	set(value):
		rate = value
		_build()

## Length of the whole press in seconds.
@export var duration := 0.07:
	set(value):
		duration = value
		_build()

## Seconds the click's noise burst rings.
@export var click_seconds := 0.003:
	set(value):
		click_seconds = value
		_build()

## Seconds after the click that the key bottoms out.
@export var bottom_delay := 0.008:
	set(value):
		bottom_delay = value
		_build()

## Body pitch of the bottom-out in Hz; it sags a little as it rings.
@export var thock_pitch := 420.0:
	set(value):
		thock_pitch = value
		_build()

## Seconds the thock takes to fall to a third.
@export var thock_seconds := 0.018:
	set(value):
		thock_seconds = value
		_build()

## Click loudness against the thock, 0..1.
@export var click_level := 0.45:
	set(value):
		click_level = value
		_build()

## Peak amplitude, 0..1.
@export var level := 0.8:
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
	var bytes := PackedByteArray()
	bytes.resize(frames * 2)

	var previous := 0.0
	for i: int in range(frames):
		var t := float(i) / rate
		# A first difference of noise is a crude high-pass: the click is bright but brief.
		var noise := rng.randf_range(-1.0, 1.0)
		var click := (noise - previous) * 0.5 * exp(-t / click_seconds) * click_level
		previous = noise

		var since := t - bottom_delay
		var thock := 0.0
		if since >= 0.0:
			var sag := 1.0 - 0.15 * minf(since / (thock_seconds * 3.0), 1.0)
			var body := sin(TAU * thock_pitch * sag * since)
			var knock := rng.randf_range(-1.0, 1.0) * exp(-since / 0.002) * 0.4
			thock = (body * 0.8 + knock) * exp(-since / thock_seconds)

		var sample := clampf((click + thock) * level, -1.0, 1.0)
		bytes.encode_s16(i * 2, int(sample * 32767.0))

	format = AudioStreamWAV.FORMAT_16_BITS
	mix_rate = rate
	stereo = false
	data = bytes
