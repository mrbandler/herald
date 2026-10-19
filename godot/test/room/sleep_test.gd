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
	_sleep.drowsiness = FloatValue.new()
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

func test_publishes_the_drowsiness() -> void:
	_sleep.pass_time.value = 172.0
	_sleep.tick(1.0 / 60.0)
	assert_float(_sleep.drowsiness.value).is_greater(0.0)

func test_the_view_hazes_while_drowsy_and_fully_in_the_fall() -> void:
	var haze: ColorRect = auto_free(ColorRect.new())
	haze.material = ShaderMaterial.new()
	_sleep.haze = haze
	_sleep.tick(0.1)
	assert_bool(haze.visible).is_false()
	_sleep.pass_time.value = 175.0
	_sleep.tick(0.1)
	assert_bool(haze.visible).is_true()
	var amount: float = (haze.material as ShaderMaterial).get_shader_parameter("amount")
	assert_float(amount).is_equal_approx(_sleep.model.haze_at_bell, 0.001)
	_sleep.fall(1.0)
	amount = (haze.material as ShaderMaterial).get_shader_parameter("amount")
	assert_float(amount).is_equal_approx(1.0, 0.001)
	_sleep.fall(0.0)

func test_the_sound_rises_out_of_the_muffle_as_a_window_starts() -> void:
	assert_float(AudioServer.get_bus_volume_db(0)).is_less(0.0)
	await get_tree().create_timer(_sleep.model.wake_seconds + 0.2).timeout
	assert_float(AudioServer.get_bus_volume_db(0)).is_equal_approx(0.0, 0.01)
