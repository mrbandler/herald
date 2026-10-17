extends GdUnitTestSuite


func test_tick_moves_the_reading_toward_the_source() -> void:
	var needle: Needle = auto_free(Needle.new())
	needle.model = NeedleModel.new()
	needle.source = FloatValue.new()
	needle.source.value = 1.0
	add_child(needle)
	needle.set_process(false)
	needle.tick(0.1)
	assert_float(needle.reading).is_greater(0.0)
	assert_float(needle.rotation_degrees.z).is_less(needle.model.angle_at_zero)
