extends GdUnitTestSuite


func test_level_dips_more_often_as_sleep_nears() -> void:
	assert_float(LampFlicker.level(0.0, 0.0)).is_equal(1.0)
	assert_float(LampFlicker.level(0.5, 0.2)).is_less(1.0)
	assert_float(LampFlicker.level(0.5, 0.3)).is_equal(1.0)
	assert_float(LampFlicker.level(1.0, 0.45)).is_less(1.0)


func test_steady_until_the_warning_then_stops_at_shift_end() -> void:
	var flicker: LampFlicker = auto_free(LampFlicker.new())
	flicker.light = auto_free(OmniLight3D.new())
	flicker.light.light_energy = 2.0
	flicker.pass_time = FloatValue.new()
	flicker.current_pass = ResourceValue.new()
	flicker.current_pass.value = PassFixture.window_one()
	flicker.tunables = Tunables.new()
	flicker.shift_ended = Event.new()
	add_child(flicker)
	flicker.pass_time.value = 150.0
	flicker.tick(0.0)
	assert_float(flicker.light.light_energy).is_equal(2.0)
	flicker.pass_time.value = 174.0
	flicker.tick(0.0)
	assert_float(flicker.light.light_energy).is_less(2.0)
	flicker.shift_ended.raise()
	flicker.light.light_energy = 0.5
	flicker.tick(0.0)
	assert_float(flicker.light.light_energy).is_equal(0.5)
