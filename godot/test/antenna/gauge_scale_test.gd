extends GdUnitTestSuite

func test_spreads_the_ticks_from_empty_to_full() -> void:
	var scale: GaugeScale = auto_free(GaugeScale.new())
	scale.needle_model = NeedleModel.new()
	scale.ticks = 5
	add_child(scale)
	assert_int(scale.get_child_count()).is_equal(5)
	var first := scale.get_child(0) as Node3D
	var last := scale.get_child(4) as Node3D
	assert_float(first.rotation_degrees.z).is_equal_approx(scale.needle_model.angle(0.0), 0.001)
	assert_float(last.rotation_degrees.z).is_equal_approx(scale.needle_model.angle(1.0), 0.001)
