extends GdUnitTestSuite


func test_samples_stay_in_range() -> void:
	var model := ToneModel.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	# 2.5 s in 1.25 ms steps: many warble cycles.
	for i: int in range(2000):
		var t := i * 0.00125
		var s := model.sample(t, rng.randf(), rng.randf(), rng.randf_range(-1.0, 1.0))
		assert_float(absf(s)).is_less_equal(1.0)


func test_no_signal_is_hiss_only() -> void:
	var model := ToneModel.new()
	assert_float(model.sample(0.0123, 0.0, 1.0, 0.0)).is_equal(0.0)
	assert_float(model.sample(0.0123, 0.0, 1.0, 1.0)).is_equal(model.hiss_level)


func test_a_locked_carrier_is_a_steady_tone() -> void:
	var model := ToneModel.new()
	var full := model.carrier_level * sin(TAU * model.carrier_pitch * 0.0123)
	assert_float(model.sample(0.0123, 1.0, 1.0, 0.0)).is_equal_approx(full, 0.0001)


func test_hiss_filter_sweeps_once_per_dial_unit() -> void:
	var model := ToneModel.new()
	var a := model.hiss_alpha(52.0)
	assert_float(model.hiss_alpha(53.0)).is_equal_approx(a, 0.0001)
	assert_bool(absf(model.hiss_alpha(52.25) - a) > 0.01).is_true()
	for i: int in range(40):
		var alpha := model.hiss_alpha(i * 0.05)
		assert_float(alpha).is_between(model.hiss_alpha_min, model.hiss_alpha_max)


func test_hiss_gain_keeps_filtered_noise_as_loud_as_white_noise() -> void:
	var model := ToneModel.new()
	assert_float(model.hiss_gain(1.0)).is_equal_approx(1.0, 0.0001)
	assert_float(model.hiss_gain(0.1)).is_greater(1.0)
