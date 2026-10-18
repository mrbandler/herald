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
