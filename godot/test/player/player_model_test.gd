extends GdUnitTestSuite

var _model := PlayerModel.new()

func test_mouse_motion_turns_by_sensitivity() -> void:
	var angles := _model.turn(Vector2.ZERO, Vector2(100.0, -50.0))
	assert_float(angles.x).is_equal_approx(-100.0 * _model.sensitivity, 0.0001)
	assert_float(angles.y).is_equal_approx(50.0 * _model.sensitivity, 0.0001)

func test_turn_clamps_yaw_and_pitch() -> void:
	var angles := _model.turn(Vector2.ZERO, Vector2(-100000.0, 100000.0))
	assert_float(angles.x).is_equal(_model.yaw_limit)
	assert_float(angles.y).is_equal(_model.pitch_min)

func test_lean_amount_by_look_away_angle() -> void:
	assert_float(_model.lean_amount(0.0)).is_equal(1.0)
	assert_float(_model.lean_amount(_model.lean_start)).is_equal(1.0)
	assert_float(_model.lean_amount(30.0)).is_between(0.01, 0.99)
	assert_float(_model.lean_amount(_model.lean_full)).is_equal(0.0)

func test_drowsiness_slows_the_look() -> void:
	var model := PlayerModel.new()
	assert_float(model.look_scale(0.0)).is_equal(1.0)
	assert_float(model.look_scale(1.0)).is_equal_approx(1.0 - model.drowsy_slowdown, 0.0001)
