extends GdUnitTestSuite

func test_shows_the_target_while_above_zero() -> void:
	var shown: ValueVisibility = auto_free(ValueVisibility.new())
	shown.source = FloatValue.new()
	shown.target = auto_free(Node3D.new())
	add_child(shown)
	assert_bool(shown.target.visible).is_false()
	shown.source.value = 1.0
	assert_bool(shown.target.visible).is_true()
	shown.source.value = 0.0
	assert_bool(shown.target.visible).is_false()
