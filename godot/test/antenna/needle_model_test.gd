extends GdUnitTestSuite

func test_spring_settles_on_the_goal() -> void:
	var model := NeedleModel.new()
	var state := Vector2.ZERO
	for _i: int in range(600):
		state = model.step(state.x, state.y, 0.7, 1.0 / 60.0)
	assert_float(state.x).is_equal_approx(0.7, 0.01)

func test_low_damping_overshoots() -> void:
	var model := NeedleModel.new()
	model.damping = 1.0
	var state := Vector2.ZERO
	var peak := 0.0
	for _i: int in range(120):
		state = model.step(state.x, state.y, 0.5, 1.0 / 60.0)
		peak = maxf(peak, state.x)
	assert_float(peak).is_greater(0.5)

func test_angle_spans_zero_to_full() -> void:
	var model := NeedleModel.new()
	assert_float(model.angle(0.0)).is_equal(model.angle_at_zero)
	assert_float(model.angle(1.0)).is_equal(model.angle_at_full)
