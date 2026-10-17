extends GdUnitTestSuite


func test_drag_writes_the_target() -> void:
	var knob: Knob = auto_free(Knob.new())
	knob.target = FloatValue.new()
	knob.target.value = 10.0
	knob.model = KnobModel.new()
	knob.visual = auto_free(Node3D.new())
	add_child(knob)
	knob.drag(40.0, false)
	assert_float(knob.target.value).is_equal_approx(12.0, 0.0001)


func test_visual_follows_the_value() -> void:
	var knob: Knob = auto_free(Knob.new())
	knob.target = FloatValue.new()
	knob.model = KnobModel.new()
	knob.visual = auto_free(Node3D.new())
	add_child(knob)
	knob.target.value = 2.0
	assert_float(knob.visual.rotation_degrees.y).is_equal_approx(-72.0, 0.0001)
