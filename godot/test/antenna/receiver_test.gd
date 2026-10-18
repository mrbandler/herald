extends GdUnitTestSuite

var _receiver: Receiver


func before_test() -> void:
	_receiver = auto_free(Receiver.new())
	_receiver.model = ReceiverModel.new()
	_receiver.current_pass = ResourceValue.new()
	_receiver.current_pass.value = PassFixture.window_one()
	_receiver.pass_time = FloatValue.new()
	_receiver.dish_azimuth = FloatValue.new()
	_receiver.dish_elevation = FloatValue.new()
	_receiver.tuning = FloatValue.new()
	_receiver.carrier_present = BoolValue.new()
	_receiver.force_lock = BoolValue.new()
	_receiver.signal_strength = FloatValue.new()
	_receiver.lock_quality = FloatValue.new()
	_receiver.locked = BoolValue.new()
	_receiver.pass_time.value = 30.0


func test_on_target_and_tuned_locks() -> void:
	_point_at_target()
	_tune(0.0)
	_receiver.carrier_present.value = true
	_receiver.sense()
	assert_float(_receiver.signal_strength.value).is_equal_approx(1.0, 0.0001)
	assert_float(_receiver.lock_quality.value).is_equal_approx(1.0, 0.0001)
	assert_bool(_receiver.locked.value).is_true()


func test_after_los_the_carrier_sets_without_lock() -> void:
	_point_at_target()
	_tune(0.0)
	_receiver.carrier_present.value = true
	_receiver.sense()
	_receiver.carrier_present.value = false
	_receiver.pass_time.value = 115.0 + _receiver.model.set_seconds * 0.5
	_point_at_target()
	_tune(0.0)
	_receiver.sense()
	assert_float(_receiver.signal_strength.value).is_equal_approx(0.5, 0.0001)
	assert_bool(_receiver.locked.value).is_false()


func test_without_a_pass_there_is_silence() -> void:
	_receiver.current_pass.value = null
	_receiver.sense()
	assert_float(_receiver.signal_strength.value).is_equal(0.0)
	assert_float(_receiver.lock_quality.value).is_equal(0.0)
	assert_bool(_receiver.locked.value).is_false()


func test_a_held_lock_survives_a_small_detune() -> void:
	_point_at_target()
	_receiver.carrier_present.value = true
	_tune(0.0)
	_receiver.sense()
	# Quality 0.8: between lock_off (0.7) and lock_on (0.9).
	_tune(0.4)
	_receiver.sense()
	assert_bool(_receiver.locked.value).is_true()


func test_a_small_detune_does_not_lock_from_cold() -> void:
	_point_at_target()
	_receiver.carrier_present.value = true
	_tune(0.4)
	_receiver.sense()
	assert_bool(_receiver.locked.value).is_false()


func test_before_aos_the_carrier_rises_but_cannot_lock() -> void:
	_receiver.pass_time.value = 15.0
	_point_at_target()
	_tune(0.0)
	_receiver.sense()
	assert_float(_receiver.signal_strength.value).is_equal_approx(0.5, 0.0001)
	assert_float(_receiver.lock_quality.value).is_equal_approx(1.0, 0.0001)
	assert_bool(_receiver.locked.value).is_false()


func test_force_lock_wins_even_without_carrier() -> void:
	_receiver.force_lock.value = true
	_receiver.sense()
	assert_bool(_receiver.locked.value).is_true()


func test_detuned_carrier_is_heard_but_not_locked() -> void:
	_point_at_target()
	_tune(-12.0)
	_receiver.carrier_present.value = true
	_receiver.sense()
	assert_float(_receiver.signal_strength.value).is_greater(0.9)
	assert_bool(_receiver.locked.value).is_false()


func _point_at_target() -> void:
	var window := _receiver.current_pass.value as PassWindow
	var target := _receiver.model.target_at(window, _receiver.pass_time.value)
	_receiver.dish_azimuth.value = target.x
	_receiver.dish_elevation.value = target.y


func _tune(offset: float) -> void:
	var window := _receiver.current_pass.value as PassWindow
	_receiver.tuning.value = _receiver.model.true_tuning(window, _receiver.pass_time.value) + offset
