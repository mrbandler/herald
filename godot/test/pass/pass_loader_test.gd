extends GdUnitTestSuite


func test_points_at_the_numbered_window() -> void:
	var second := PassFixture.window_one()
	var loader := _loader([PassFixture.window_one(), second], 2)
	assert_object(loader.current_pass.value).is_same(second)


func test_clamps_out_of_range_numbers() -> void:
	var first := PassFixture.window_one()
	var last := PassFixture.window_one()
	assert_object(_loader([first, last], 9).current_pass.value).is_same(last)
	assert_object(_loader([first, last], 0).current_pass.value).is_same(first)


func test_clears_the_pointer_on_exit() -> void:
	var loader := _loader([PassFixture.window_one()], 1)
	remove_child(loader)
	assert_object(loader.current_pass.value).is_null()


func _loader(passes: Array[PassWindow], number: int) -> PassLoader:
	var loader: PassLoader = auto_free(PassLoader.new())
	loader.passes = passes
	loader.window_number = IntValue.new()
	loader.window_number.value = number
	loader.current_pass = ResourceValue.new()
	add_child(loader)
	return loader
