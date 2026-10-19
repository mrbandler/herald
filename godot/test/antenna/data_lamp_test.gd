extends GdUnitTestSuite

func test_pulses_on_each_row() -> void:
	var lamp: DataLamp = auto_free(DataLamp.new())
	lamp.model = LampModel.new()
	lamp.row_received = Event.new()
	add_child(lamp)
	lamp.tick(0.0)
	assert_float(lamp.energy()).is_equal(lamp.model.off_energy)
	lamp.row_received.raise()
	lamp.tick(0.03)
	assert_float(lamp.energy()).is_equal(lamp.model.on_energy)
	lamp.tick(0.05)
	assert_float(lamp.energy()).is_equal(lamp.model.off_energy)
