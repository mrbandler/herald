extends GdUnitTestSuite

var _model: MusicModel

func before_test() -> void:
	_model = MusicModel.new()

func _peak(frames: PackedVector2Array) -> float:
	var peak := 0.0
	for frame: Vector2 in frames:
		peak = maxf(peak, maxf(absf(frame.x), absf(frame.y)))

	return peak

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

func test_the_bed_alone_is_heard() -> void:
	var synth := MusicSynth.new(_model, 1)
	assert_float(_peak(synth.render(22050, 1.0, 0.0, 0.0))).is_greater(0.01)

func test_no_frames_renders_nothing() -> void:
	var synth := MusicSynth.new(_model, 1)
	assert_int(synth.render(0, 1.0, 1.0, 1.0).size()).is_equal(0)
