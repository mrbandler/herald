extends GdUnitTestSuite

var _model := ReceiverModel.new()


func test_card_error_grows_per_window_and_caps() -> void:
	assert_float(_model.card_error(_window(1))).is_equal_approx(0.8, 0.0001)
	assert_float(_model.card_error(_window(12))).is_equal(4.0)


func test_a_window_can_set_its_own_card_error() -> void:
	var window := _window(1)
	window.card_error = 2.5
	assert_float(_model.card_error(window)).is_equal(2.5)
	window.card_error = 0.0
	assert_float(_model.card_error(window)).is_equal(0.0)


func test_target_is_card_error_away_from_the_card_at_aos() -> void:
	var window := PassFixture.window_one()
	var card := Vector2(window.card_azimuth, window.card_elevation)
	var at_aos := _model.target_at(window, window.aos)
	assert_float(at_aos.distance_to(card)).is_equal_approx(0.8, 0.0001)


func test_target_drifts_by_dish_drift_per_second() -> void:
	var window := PassFixture.window_one()
	var moved := _model.target_at(window, 10.0) - _model.target_at(window, 0.0)
	assert_vector(moved).is_equal_approx(_model.dish_drift * 10.0, Vector2.ONE * 0.0001)


func test_card_error_direction_depends_on_the_seed() -> void:
	var first := PassFixture.window_one()
	var second := PassFixture.window_one()
	second.card_seed = 2
	assert_vector(_model.target_at(first, 0.0)).is_not_equal(_model.target_at(second, 0.0))


func test_tuning_error_grows_per_window_and_caps() -> void:
	assert_float(absf(_model.card_tuning_offset(_window(1)))).is_equal_approx(0.4, 0.0001)
	assert_float(absf(_model.card_tuning_offset(_window(12)))).is_equal(2.0)


func test_a_window_can_set_its_own_tuning_error() -> void:
	var window := _window(1)
	window.card_tuning_error = 1.5
	assert_float(absf(_model.card_tuning_offset(window))).is_equal(1.5)


func test_pointing_error_wraps_azimuth() -> void:
	var error := _model.pointing_error(Vector2(359.5, 10.0), Vector2(0.5, 10.0))
	assert_float(error).is_equal_approx(1.0, 0.0001)
	var reverse := _model.pointing_error(Vector2(0.5, 10.0), Vector2(359.5, 10.0))
	assert_float(reverse).is_equal_approx(1.0, 0.0001)


func test_strength_falls_to_zero_at_the_hearing_radius() -> void:
	assert_float(_model.strength(0.0)).is_equal(1.0)
	assert_float(_model.strength(0.75)).is_equal_approx(0.5, 0.0001)
	assert_float(_model.strength(1.5)).is_equal(0.0)
	assert_float(_model.strength(3.0)).is_equal(0.0)


func test_hearing_curve_softens_the_edge() -> void:
	_model.hearing_curve = 2.0
	assert_float(_model.strength(0.0)).is_equal(1.0)
	assert_float(_model.strength(0.75)).is_equal_approx(0.25, 0.0001)
	assert_float(_model.strength(1.5)).is_equal(0.0)


func test_true_tuning_is_tuning_error_off_the_card_at_aos() -> void:
	var window := PassFixture.window_one()
	var offset := _model.card_tuning_offset(window)
	assert_float(_model.true_tuning(window, 30.0)).is_equal_approx(52.0 + offset, 0.0001)


func test_true_tuning_drifts_into_aos_and_on_past_it() -> void:
	var window := PassFixture.window_one()
	var at_aos := _model.true_tuning(window, 30.0)
	assert_float(_model.true_tuning(window, 10.0) - at_aos).is_equal_approx(-0.4, 0.0001)
	assert_float(_model.true_tuning(window, 40.0) - at_aos).is_equal_approx(0.2, 0.0001)


func test_the_carrier_rises_over_the_prep() -> void:
	var window := PassFixture.window_one()
	assert_float(_model.presence(window, 0.0)).is_equal(0.0)
	assert_float(_model.presence(window, 15.0)).is_equal_approx(0.5, 0.0001)
	assert_float(_model.presence(window, 30.0)).is_equal(1.0)
	assert_float(_model.presence(window, 100.0)).is_equal(1.0)


func test_the_carrier_sets_over_set_seconds_after_los() -> void:
	var window := PassFixture.window_one()
	_model.set_seconds = 10.0
	assert_float(_model.presence(window, 115.0)).is_equal(1.0)
	assert_float(_model.presence(window, 120.0)).is_equal_approx(0.5, 0.0001)
	assert_float(_model.presence(window, 125.0)).is_equal(0.0)
	assert_float(_model.presence(window, 175.0)).is_equal(0.0)


func test_lock_quality_by_tuning_error() -> void:
	assert_float(_model.lock_quality(0.0)).is_equal(1.0)
	assert_float(_model.lock_quality(-1.0)).is_equal_approx(0.5, 0.0001)
	assert_float(_model.lock_quality(3.0)).is_equal(0.0)


func test_lock_has_hysteresis_and_needs_a_carrier() -> void:
	assert_bool(_model.next_locked(false, 0.95, 0.5)).is_true()
	assert_bool(_model.next_locked(false, 0.8, 0.5)).is_false()
	assert_bool(_model.next_locked(true, 0.8, 0.5)).is_true()
	assert_bool(_model.next_locked(true, 0.6, 0.5)).is_false()
	assert_bool(_model.next_locked(true, 1.0, 0.0)).is_false()


func _window(number: int) -> PassWindow:
	var window := PassFixture.window_one()
	window.number = number
	return window
