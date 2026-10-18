extends GdUnitTestSuite

func test_publishes_its_anchor_and_focuses_on_grab() -> void:
	var target: FocusTarget = auto_free(FocusTarget.new())
	var anchor := Node3D.new()
	anchor.position = Vector3(0.0, 1.0, -1.0)
	target.add_child(anchor)
	target.anchor = anchor
	target.focused = BoolValue.new()
	target.focus_point = Vector3Value.new()
	add_child(target)
	assert_vector(target.focus_point.value).is_equal(Vector3(0.0, 1.0, -1.0))
	target.grab()
	assert_bool(target.focused.value).is_true()
