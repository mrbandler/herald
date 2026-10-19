extends GdUnitTestSuite

func test_hold_and_release_drive_grabbing() -> void:
	var picker: Picker = auto_free(Picker.new())
	picker.grabbing = BoolValue.new()
	var target: FocusTarget = auto_free(FocusTarget.new())
	target.focused = BoolValue.new()
	picker.hold(target)
	assert_bool(picker.grabbing.value).is_true()
	assert_bool(target.focused.value).is_true()
	assert_object(picker.held).is_same(target)
	picker.release()
	assert_bool(picker.grabbing.value).is_false()
	assert_object(picker.held).is_null()

func test_release_without_a_hold_does_nothing() -> void:
	var picker: Picker = auto_free(Picker.new())
	picker.grabbing = BoolValue.new()
	picker.release()
	assert_bool(picker.grabbing.value).is_false()

func test_writes_where_the_ray_hits() -> void:
	var camera: Camera3D = auto_free(Camera3D.new())
	var target := Interactable.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.0, 1.0, 0.2)
	shape.shape = box
	target.add_child(shape)
	target.position = Vector3(0.0, 0.0, -1.0)
	camera.add_child(target)
	add_child(camera)
	var picker: Picker = auto_free(Picker.new())
	picker.model = PlayerModel.new()
	picker.camera = camera
	picker.hovering = BoolValue.new()
	picker.grabbing = BoolValue.new()
	picker.aim_point = Vector3Value.new()
	await get_tree().physics_frame
	await get_tree().physics_frame
	assert_object(picker.cast()).is_same(target)
	assert_float(picker.aim_point.value.z).is_equal_approx(-0.9, 0.01)
