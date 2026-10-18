extends GdUnitTestSuite

func test_turn_by_rotates_the_pivot() -> void:
	var look: MouseLook = auto_free(MouseLook.new())
	look.model = PlayerModel.new()
	look.pivot = auto_free(Node3D.new())
	look.turn_by(Vector2(100.0, 0.0))
	var expected := -100.0 * look.model.sensitivity
	assert_float(look.pivot.rotation_degrees.y).is_equal_approx(expected, 0.0001)
	assert_float(look.pivot.rotation_degrees.x).is_equal_approx(0.0, 0.0001)
