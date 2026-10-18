extends GdUnitTestSuite

var _model := ReceiverModel.new()


func test_card_error_grows_per_window_and_caps() -> void:
	assert_float(_model.card_error(1)).is_equal_approx(0.8, 0.0001)
	assert_float(_model.card_error(12)).is_equal(4.0)


func test_target_starts_card_error_away_from_the_card() -> void:
	var window := PassFixture.window_one()
	var card := Vector2(window.card_azimuth, window.card_elevation)
	assert_float(_model.target_at(window, 0.0).distance_to(card)).is_equal_approx(0.8, 0.0001)


func test_target_drifts_by_dish_drift_per_second() -> void:
	var window := PassFixture.window_one()
	var moved := _model.target_at(window, 10.0) - _model.target_at(window, 0.0)
	assert_vector(moved).is_equal_approx(_model.dish_drift * 10.0, Vector2.ONE * 0.0001)


func test_card_error_direction_depends_on_the_seed() -> void:
	var first := PassFixture.window_one()
	var second := PassFixture.window_one()
	second.card_seed = 2
	assert_vector(_model.target_at(first, 0.0)).is_not_equal(_model.target_at(second, 0.0))


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


func test_true_tuning_matches_the_card_at_aos_then_drifts() -> void:
	var window := PassFixture.window_one()
	assert_float(_model.true_tuning(window, 10.0)).is_equal(52.0)
	assert_float(_model.true_tuning(window, 30.0)).is_equal(52.0)
	assert_float(_model.true_tuning(window, 40.0)).is_equal_approx(52.2, 0.0001)


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
