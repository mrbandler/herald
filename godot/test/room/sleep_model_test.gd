extends GdUnitTestSuite

func test_drowsiness_rises_over_the_warning() -> void:
	var model := SleepModel.new()
	assert_float(model.drowsiness(150.0, 175.0)).is_equal(0.0)
	assert_float(model.drowsiness(167.5, 175.0)).is_equal_approx(0.5, 0.001)
	assert_float(model.drowsiness(200.0, 175.0)).is_equal(1.0)

func test_blinks_get_longer_and_more_frequent() -> void:
	var model := SleepModel.new()
	assert_float(model.blink_period(1.0)).is_less(model.blink_period(0.0))
	assert_float(model.lid_closure(0.3, 1.0)).is_greater(model.lid_closure(0.3, 0.0))

func test_a_blink_opens_again_before_the_next() -> void:
	var model := SleepModel.new()
	assert_float(model.lid_closure(0.0, 0.5)).is_equal_approx(0.0, 0.001)
	assert_float(model.lid_closure(0.95, 0.5)).is_equal_approx(0.0, 0.001)
	var duty := lerpf(model.blink_duty.x, model.blink_duty.y, 0.5)
	assert_float(model.lid_closure(duty * 0.5, 0.5)).is_equal_approx(1.0, 0.001)

func test_asleep_closes_the_eyes_before_the_head_lands() -> void:
	var model := SleepModel.new()
	assert_float(model.asleep_closure(0.0)).is_equal(0.0)
	assert_float(model.asleep_closure(0.9)).is_equal(1.0)
	assert_float(model.asleep_drop(0.5)).is_less(0.5)
	assert_float(model.asleep_drop(1.0)).is_equal(1.0)
