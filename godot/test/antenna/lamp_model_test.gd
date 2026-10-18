extends GdUnitTestSuite

func test_source_wins_over_blink() -> void:
	var model := LampModel.new()
	assert_int(model.state(true, 0.5)).is_equal(LampModel.State.ON)

func test_blinks_while_heard_but_not_on() -> void:
	var model := LampModel.new()
	assert_int(model.state(false, 0.5)).is_equal(LampModel.State.BLINK)

func test_off_without_either() -> void:
	var model := LampModel.new()
	assert_int(model.state(false, 0.0)).is_equal(LampModel.State.OFF)

func test_blink_alternates_at_the_blink_rate() -> void:
	var model := LampModel.new()
	model.blink_rate = 2.0
	assert_float(model.energy(LampModel.State.BLINK, 0.1)).is_equal(model.on_energy)
	assert_float(model.energy(LampModel.State.BLINK, 0.3)).is_equal(model.off_energy)
	assert_float(model.energy(LampModel.State.ON, 0.3)).is_equal(model.on_energy)
	assert_float(model.energy(LampModel.State.OFF, 0.1)).is_equal(model.off_energy)
