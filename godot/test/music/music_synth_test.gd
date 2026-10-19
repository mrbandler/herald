extends GdUnitTestSuite

var _model: MusicModel

func before_test() -> void:
	_model = MusicModel.new()

func _peak(frames: PackedVector2Array) -> float:
	var peak := 0.0
	for frame: Vector2 in frames:
		peak = maxf(peak, maxf(absf(frame.x), absf(frame.y)))

	return peak

func _crossings(frames: PackedVector2Array) -> int:
	var count := 0
	for i: int in range(1, frames.size()):
		if signf(frames[i].x) != signf(frames[i - 1].x):
			count += 1

	return count

func test_samples_keep_headroom() -> void:
	for bed: float in [0.0, 1.0]:
		for melody: float in [0.0, 1.0]:
			for stress: float in [0.0, 1.0]:
				var synth := MusicSynth.new(_model, 1)
				var peak := _peak(synth.render(22050, bed, melody, stress))
				# The output is clamped to 1; staying under 0.9 shows it never needs to be.
				assert_float(peak).is_less(0.9)

func test_the_same_seed_renders_the_same_samples() -> void:
	var a := MusicSynth.new(_model, 7).render(22050, 1.0, 1.0, 1.0)
	var b := MusicSynth.new(_model, 7).render(22050, 1.0, 1.0, 1.0)
	assert_bool(a == b).is_true()

func test_no_bed_and_no_melody_is_silence() -> void:
	var synth := MusicSynth.new(_model, 1)
	assert_float(_peak(synth.render(22050, 0.0, 0.0, 0.0))).is_equal(0.0)

func test_the_melody_alone_is_heard() -> void:
	# The motif plays from cycle 0, so 2 s already hold it.
	var quiet := MusicSynth.new(_model, 1).render(44100, 0.0, 0.0, 0.0)
	var melody := MusicSynth.new(_model, 1).render(44100, 0.0, 1.0, 0.0)
	assert_float(_peak(quiet)).is_equal(0.0)
	assert_float(_peak(melody)).is_greater(0.01)

func test_each_played_motif_takes_the_next_phrase() -> void:
	# One low and one high single-note phrase, no plucks and no bed: only the bells sound.
	_model.motif_phrases = [PackedFloat32Array([200.0]), PackedFloat32Array([600.0])]
	_model.pluck_level = 0.0
	var cycle := int(_model.cycle_seconds * _model.mix_rate)
	# Stress 1 plays the motif every cycle.
	var frames := MusicSynth.new(_model, 1).render(cycle + 11025, 0.0, 1.0, 1.0)
	var low := _crossings(frames.slice(5512, 11025))
	var high := _crossings(frames.slice(cycle + 5512, cycle + 11025))
	assert_int(high).is_greater(low * 2)

func test_the_bass_duck_does_not_click() -> void:
	# Only the bass sounds; the melody makes it duck at the motif start of cycle 2.
	_model.pad_level = 0.0
	_model.color_level = 0.0
	_model.pluck_level = 0.0
	_model.motif_level = 0.0
	var cycle := int(_model.cycle_seconds * _model.mix_rate)
	var frames := MusicSynth.new(_model, 1).render(cycle * 2 + 2205, 1.0, 1.0, 0.0)
	var jump := 0.0
	for i: int in range(cycle * 2 - 2205, frames.size()):
		jump = maxf(jump, absf(frames[i].x - frames[i - 1].x))
	assert_float(jump).is_less(0.01)

func test_the_bed_alone_is_heard() -> void:
	var synth := MusicSynth.new(_model, 1)
	assert_float(_peak(synth.render(22050, 1.0, 0.0, 0.0))).is_greater(0.01)

func test_no_frames_renders_nothing() -> void:
	var synth := MusicSynth.new(_model, 1)
	assert_int(synth.render(0, 1.0, 1.0, 1.0).size()).is_equal(0)
