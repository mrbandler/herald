extends GdUnitTestSuite

func test_points_at_the_lock_threshold() -> void:
	var mark: NeedleMark = auto_free(NeedleMark.new())
	mark.needle_model = NeedleModel.new()
	mark.receiver_model = ReceiverModel.new()
	mark.receiver_model.lock_on = 0.7
	add_child(mark)
	assert_float(mark.rotation_degrees.z).is_equal_approx(-20.0, 0.0001)

func test_reads_the_named_threshold() -> void:
	var mark: NeedleMark = auto_free(NeedleMark.new())
	mark.needle_model = NeedleModel.new()
	mark.receiver_model = ReceiverModel.new()
	mark.threshold = "margin"
	add_child(mark)
	var expected := mark.needle_model.angle(mark.receiver_model.margin)
	assert_float(mark.rotation_degrees.z).is_equal_approx(expected, 0.001)
