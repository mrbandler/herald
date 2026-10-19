extends GdUnitTestSuite

var _model: MusicModel
var _window: PassWindow

func before_test() -> void:
	_model = MusicModel.new()
	# AOS 30, UPLINK 95, LOS 115, BELL 175.
	_window = PassFixture.window_one()

func test_each_phase_starts_at_its_start_stress() -> void:
	assert_float(_model.stress_at(_window, 0.0)).is_equal_approx(_model.pre_aos_stress.x, 0.0001)
	assert_float(_model.stress_at(_window, 30.0)).is_equal_approx(_model.downlink_stress.x, 0.0001)
	assert_float(_model.stress_at(_window, 95.0)).is_equal_approx(_model.uplink_stress.x, 0.0001)

func test_each_phase_ends_near_its_end_stress() -> void:
	assert_float(_model.stress_at(_window, 29.999)).is_equal_approx(_model.pre_aos_stress.y, 0.001)
	assert_float(_model.stress_at(_window, 94.999)).is_equal_approx(_model.downlink_stress.y, 0.001)
	assert_float(_model.stress_at(_window, 114.999)).is_equal_approx(_model.uplink_stress.y, 0.001)

func test_stress_only_rises_inside_a_phase() -> void:
	var previous := _model.stress_at(_window, 30.0)
	for i: int in range(1, 65):
		var current := _model.stress_at(_window, 30.0 + i)
		assert_float(current).is_greater_equal(previous)
		previous = current

func test_after_los_stress_settles_to_zero() -> void:
	assert_float(_model.stress_at(_window, 115.0)).is_equal_approx(_model.uplink_stress.y, 0.0001)
	assert_float(_model.stress_at(_window, 115.0 + _model.settle_seconds)).is_equal(0.0)
	assert_float(_model.stress_at(_window, 175.0)).is_equal(0.0)
	assert_float(_model.stress_at(_window, 500.0)).is_equal(0.0)

func test_without_a_pass_stress_is_zero() -> void:
	assert_float(_model.stress_at(null, 50.0)).is_equal(0.0)

func test_zero_lengths_do_not_divide_by_zero() -> void:
	_window.aos = 0.0
	assert_float(_model.stress_at(_window, -1.0)).is_equal_approx(_model.pre_aos_stress.y, 0.0001)
	_model.settle_seconds = 0.0
	assert_float(_model.stress_at(_window, 115.0)).is_equal(0.0)

func test_bed_is_quiet_at_full_knob_and_full_at_zero() -> void:
	assert_float(_model.bed_level(1.0)).is_equal_approx(_model.bed_floor, 0.0001)
	assert_float(_model.bed_level(0.0)).is_equal_approx(1.0, 0.0001)

func test_melody_is_silent_at_full_knob_and_full_at_zero() -> void:
	assert_float(_model.melody_level(1.0)).is_equal(0.0)
	assert_float(_model.melody_level(0.0)).is_equal_approx(1.0, 0.0001)
	assert_float(_model.melody_level(0.5)).is_less(0.5)

func test_plucks_come_faster_with_stress() -> void:
	assert_float(_model.pluck_gap(0.0, 0.0)).is_equal_approx(_model.pluck_gap_relaxed.x, 0.0001)
	assert_float(_model.pluck_gap(1.0, 1.0)).is_equal_approx(_model.pluck_gap_tense.y, 0.0001)
	assert_float(_model.pluck_gap(1.0, 1.0)).is_less(_model.pluck_gap(0.0, 0.0))

func test_cutoff_stays_within_its_range() -> void:
	for i: int in range(-2, 13):
		var cutoff := _model.cutoff(i * 0.1)
		assert_float(cutoff).is_between(_model.cutoff_min, _model.cutoff_max)

func test_low_pass_alpha_is_a_fraction() -> void:
	var alpha := _model.low_pass_alpha(_model.cutoff_max)
	assert_float(alpha).is_greater(0.0)
	assert_float(alpha).is_less(1.0)

func test_bass_pulses_from_its_threshold() -> void:
	assert_float(_model.bass_pulse(0.0)).is_equal(0.0)
	assert_float(_model.bass_pulse(_model.bass_pulse_start)).is_equal(0.0)
	assert_float(_model.bass_pulse(1.0)).is_equal_approx(_model.bass_pulse_max, 0.0001)

func test_motif_plays_every_cycle_from_its_threshold() -> void:
	assert_bool(_model.motif_every_cycle(_model.motif_dense_from - 0.01)).is_false()
	assert_bool(_model.motif_every_cycle(_model.motif_dense_from)).is_true()

func test_tension_is_silent_below_its_start() -> void:
	assert_float(_model.tension(0.5)).is_equal(0.0)
	assert_float(_model.tension(_model.tension_start)).is_equal(0.0)
	assert_float(_model.tension(1.0)).is_equal_approx(1.0, 0.0001)

func test_every_note_stays_below_the_carrier() -> void:
	# The carrier is 880 Hz; the spec keeps every fundamental under 700 Hz.
	var notes := PackedFloat32Array([_model.bass_note, _model.tension_note])
	notes.append_array(_model.pad_notes)
	notes.append_array(_model.color_notes)
	notes.append_array(_model.pluck_notes)
	notes.append_array(_model.motif_notes)
	for note: float in notes:
		assert_float(note).is_less(700.0)
