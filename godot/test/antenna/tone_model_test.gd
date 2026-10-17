extends GdUnitTestSuite


func test_samples_stay_in_range() -> void:
	var model := ToneModel.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	# 2.5 s in 1.25 ms steps: two full listening pulses at the default rate.
	for i: int in range(2000):
		var t := i * 0.00125
		var s := model.sample(
			t,
			rng.randf(),
			rng.randf(),
			t if rng.randf() > 0.5 else -1.0,
			rng.randf_range(-1.0, 1.0),
		)
		assert_float(absf(s)).is_less_equal(1.0)


func test_no_signal_is_hiss_only() -> void:
	var model := ToneModel.new()
	assert_float(model.sample(0.0123, 0.0, 1.0, -1.0, 0.0)).is_equal(0.0)
	assert_float(model.sample(0.0123, 0.0, 1.0, -1.0, 1.0)).is_equal(model.hiss_level)


func test_listening_starts_at_full_volume() -> void:
	var model := ToneModel.new()
	var full := model.carrier_level * sin(TAU * model.carrier_pitch * 0.0123)
	assert_float(model.sample(0.0123, 1.0, 1.0, 0.0, 0.0)).is_equal_approx(full, 0.0001)


func test_listening_pulse_silences_the_carrier_between_pulses() -> void:
	var model := ToneModel.new()
	# Half a pulse period after the Turn began, the envelope is at zero.
	var half := 0.5 / model.pulse_rate
	assert_float(model.sample(0.0123, 1.0, 1.0, half, 0.0)).is_equal_approx(0.0, 0.0001)
