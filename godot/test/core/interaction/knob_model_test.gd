extends GdUnitTestSuite


func test_drag_moves_by_units_per_pixel() -> void:
	var model := KnobModel.new()
	assert_float(model.apply(100.0, 20.0, false)).is_equal_approx(101.0, 0.0001)


func test_fine_drag_is_slower() -> void:
	var model := KnobModel.new()
	assert_float(model.apply(100.0, 20.0, true)).is_equal_approx(100.1, 0.0001)


func test_clamps_at_the_ends() -> void:
	var model := KnobModel.new()
	model.maximum = 90.0
	assert_float(model.apply(89.5, 100.0, false)).is_equal(90.0)
	assert_float(model.apply(0.5, -100.0, false)).is_equal(0.0)


func test_wraps_when_asked() -> void:
	var model := KnobModel.new()
	model.wraps = true
	assert_float(model.apply(359.5, 20.0, false)).is_equal_approx(0.5, 0.0001)
	assert_float(model.apply(0.5, -20.0, false)).is_equal_approx(359.5, 0.0001)


func test_respects_a_non_zero_minimum() -> void:
	var model := KnobModel.new()
	model.minimum = 10.0
	model.maximum = 20.0
	assert_float(model.apply(10.5, -100.0, false)).is_equal(10.0)
