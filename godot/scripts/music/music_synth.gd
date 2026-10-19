class_name MusicSynth
extends RefCounted

## Renders the music sample by sample from a MusicModel. Holds every clock, envelope and filter,
## so one instance belongs to one thread.

## Supplies notes, levels and the stress curves.
var _model: MusicModel

## Draws pluck notes and pluck gaps, whatever the levels are, so the same seed gives the same
## timing at any knob setting.
var _rng := RandomNumberGenerator.new()

## Seconds per sample.
var _step := 0.0

## Seconds rendered so far; every oscillator runs on it.
var _time := 0.0

## Pad frequencies in radians per second: each pad note detuned up and down.
var _pad := PackedFloat64Array()

## Colour frequencies in radians per second.
var _color := PackedFloat64Array()

## Seconds since each of the two pluck voices started. Negative: the voice is silent.
var _pluck_age := PackedFloat64Array([-1.0, -1.0])

## Frequency of each pluck voice in radians per second.
var _pluck_freq := PackedFloat64Array([0.0, 0.0])

## The pluck voice the next pluck takes. Two voices let a tail ring under the next pluck.
var _pluck_next := 0

## Seconds until the next pluck.
var _pluck_wait := 0.0

## The motif cycle being rendered. -1 before the first sample.
var _cycle := -1

## True when the current cycle plays the motif. Decided once at the cycle's start, so a stress
## change never cuts a phrase in half.
var _motif_on := false

## How many motifs have started, minus one: picks the phrase. -1 before the first.
var _phrase := -1

## Low-pass filter state.
var _filter := 0.0

## Bed level, gliding toward the target given to `render`.
var _bed := 0.0

## Melody level, gliding toward the target given to `render`.
var _melody := 0.0

## Stress, gliding toward the target given to `render`.
var _stress := 0.0

## A synth for `p_model` whose random draws start from `p_seed`.
func _init(p_model: MusicModel, p_seed: int) -> void:
	_model = p_model
	_rng.seed = p_seed
	_step = 1.0 / p_model.mix_rate
	_pluck_wait = p_model.pluck_gap_first

	var spread := pow(2.0, p_model.detune_cents / 1200.0)
	for note: float in p_model.pad_notes:
		_pad.append(TAU * note * spread)
		_pad.append(TAU * note / spread)

	for note: float in p_model.color_notes:
		_color.append(TAU * note)

## Renders `frames` stereo frames within -1..1, gliding toward the target `bed` and `melody`
## levels and `stress`, all 0..1.
func render(frames: int, bed: float, melody: float, stress: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	if frames <= 0:
		return out

	out.resize(frames)
	var glide := _model.glide()
	# Stress moves slowly; one filter coefficient per call is enough.
	var alpha := _model.low_pass_alpha(_model.cutoff(_stress))

	for i: int in range(frames):
		_bed += glide * (bed - _bed)
		_melody += glide * (melody - _melody)
		_stress += glide * (stress - _stress)

		var s := _sample(alpha)
		out[i] = Vector2(s, s)
		_time += _step

	return out

## One mono sample at `_time` from the smoothed levels, low-passed with `alpha`.
func _sample(alpha: float) -> float:
	var t := _time
	var cycle := floori(t / _model.cycle_seconds)
	if cycle != _cycle:
		_start_cycle(cycle)

	var in_cycle := t - cycle * _model.cycle_seconds

	_pluck_wait -= _step
	if _pluck_wait <= 0.0:
		_start_pluck()

	var bed_part := (_pad_voice(t) + _bass_voice(t, in_cycle)) * _bed
	var motif := _motif_voice(in_cycle) if _motif_on else 0.0
	var melody_part := (_pluck_voice() + motif) * _melody
	var tension_part := _tension_voice(t) * _bed

	_filter += alpha * (bed_part + melody_part + tension_part - _filter)

	return clampf(_filter * _model.music_level, -1.0, 1.0)

## Enters motif cycle `cycle`: decides whether it plays the motif and, if so, takes the next
## phrase. Every other cycle plays below `motif_dense_from`, every cycle from it.
func _start_cycle(cycle: int) -> void:
	_cycle = cycle
	_motif_on = cycle % 2 == 0 or _model.motif_every_cycle(_stress)
	if _motif_on:
		_phrase += 1

## The detuned pad pairs and the colour notes at `t`, with the slow wobble.
func _pad_voice(t: float) -> float:
	var pad := 0.0
	for w: float in _pad:
		pad += sin(w * t)

	var color := 0.0
	for w: float in _color:
		color += sin(w * t)

	var wobble := 1.0 - _model.wobble_depth * (0.5 + 0.5 * sin(TAU * _model.wobble_rate * t))
	var mix := pad / maxi(_pad.size(), 1) * _model.pad_level
	mix += color / maxi(_color.size(), 1) * _model.color_level

	return mix * wobble

## The bass at `t`: ducks after a motif start `in_cycle` seconds ago when this cycle plays the
## motif, more the louder the melody, and pulses by stress.
func _bass_voice(t: float, in_cycle: float) -> float:
	var duck := 1.0
	if _motif_on:
		duck = lerpf(1.0, smoothstep(0.0, _model.bass_duck_seconds, in_cycle), _melody)

	var dip := _model.bass_pulse(_stress)
	var pulse := 1.0 - dip * (0.5 + 0.5 * cos(TAU * t / _model.pulse_seconds()))

	return sin(TAU * _model.bass_note * t) * duck * pulse * _model.bass_level

## Starts the next pluck on the free voice and draws the gap to the one after.
func _start_pluck() -> void:
	_pluck_wait = _model.pluck_gap(_stress, _rng.randf())

	var notes := _model.pluck_notes
	if notes.is_empty():
		return

	_pluck_freq[_pluck_next] = TAU * notes[_rng.randi_range(0, notes.size() - 1)]
	_pluck_age[_pluck_next] = 0.0
	_pluck_next = 1 - _pluck_next

## Both pluck voices, each a sine with a short attack and an exponential tail.
func _pluck_voice() -> float:
	var sum := 0.0
	for v: int in range(_pluck_age.size()):
		var age := _pluck_age[v]
		if age < 0.0:
			continue

		var envelope := minf(age / _model.pluck_attack, 1.0) * exp(-age / _model.pluck_decay)
		sum += sin(_pluck_freq[v] * age) * envelope

		# Ten decays in, the tail is inaudible: free the voice.
		_pluck_age[v] = -1.0 if age > _model.pluck_decay * 10.0 else age + _step

	return sum * _model.pluck_level

## The current phrase's bells `in_cycle` seconds into the cycle. Each note rings on under the
## next one; after the last note, its tail fades out.
func _motif_voice(in_cycle: float) -> float:
	var notes := _model.phrase(_phrase)
	if notes.is_empty():
		return 0.0

	var length := _model.motif_note_seconds
	var current := mini(floori(in_cycle / length), notes.size() - 1)
	var sum := 0.0
	for note: int in range(maxi(current - 1, 0), current + 1):
		sum += _bell(notes[note], in_cycle - note * length)

	return sum * _model.motif_level

## One bell note of `freq` Hz, `age` seconds after its strike: a sine with a short, brighter
## partial on top, both fading out.
func _bell(freq: float, age: float) -> float:
	var envelope := minf(age / _model.bell_attack, 1.0) * exp(-age / _model.bell_decay)
	var phase := TAU * freq * age
	var bright := exp(-age / _model.bell_partial_decay)
	var partial := _model.bell_partial_level * sin(_model.bell_partial_ratio * phase) * bright

	return (sin(phase) + partial) * envelope / (1.0 + _model.bell_partial_level)

## The F against the E and the low throb on E2 at `t`, by the tension of the current stress.
func _tension_voice(t: float) -> float:
	var amount := _model.tension(_stress)
	if amount <= 0.0:
		return 0.0

	var throb := 0.5 + 0.5 * cos(TAU * t / _model.pulse_seconds())
	var rub := sin(TAU * _model.tension_note * t)
	var low := sin(TAU * _model.bass_note * t) * throb

	return (rub + low) * 0.5 * amount * _model.tension_level
