extends GdUnitTestSuite

var _sleep: Sleep


func before_test() -> void:
	_sleep = auto_free(Sleep.new())
	_sleep.model = SleepModel.new()
	_sleep.camera = auto_free(Camera3D.new())
	_sleep.top_lid = auto_free(ColorRect.new())
	_sleep.bottom_lid = auto_free(ColorRect.new())
	_sleep.pass_time = FloatValue.new()
	_sleep.current_pass = ResourceValue.new()
	_sleep.current_pass.value = PassFixture.window_one()
	_sleep.shift_ended = Event.new()
	add_child(_sleep)


func test_eyes_stay_open_before_the_warning() -> void:
	_sleep.pass_time.value = 150.0
	for _i: int in range(120):
		_sleep.tick(1.0 / 60.0)
	assert_float(_sleep.top_lid.anchor_bottom).is_equal(0.0)
	assert_float(_sleep.camera.rotation_degrees.x).is_equal(0.0)


func test_eyes_blink_and_the_head_sags_while_drowsy() -> void:
	_sleep.pass_time.value = 172.0
	var deepest := 0.0
	var lowest := 0.0
	for _i: int in range(120):
		_sleep.tick(1.0 / 60.0)
		deepest = maxf(deepest, _sleep.top_lid.anchor_bottom)
		lowest = minf(lowest, _sleep.camera.rotation_degrees.x)
	assert_float(deepest).is_greater(0.4)
	assert_float(lowest).is_less(0.0)
	assert_float(_sleep.bottom_lid.anchor_top).is_less(1.0)


func test_falling_asleep_shuts_the_eyes_and_drops_the_head() -> void:
	_sleep.fall(1.0)
	assert_float(_sleep.top_lid.anchor_bottom).is_greater_equal(0.5)
	assert_float(_sleep.bottom_lid.anchor_top).is_less_equal(0.5)
	assert_float(_sleep.camera.rotation_degrees.x).is_equal_approx(
		-_sleep.model.drop_degrees,
		0.001,
	)
	assert_vector(_sleep.camera.position).is_equal_approx(
		_sleep.model.drop_offset,
		Vector3.ONE * 0.001,
	)


func test_blinking_stops_once_the_shift_ends() -> void:
	_sleep.shift_ended.raise()
	_sleep.fall(0.0)
	_sleep.pass_time.value = 172.0
	for _i: int in range(120):
		_sleep.tick(1.0 / 60.0)
	assert_float(_sleep.top_lid.anchor_bottom).is_equal(0.0)
