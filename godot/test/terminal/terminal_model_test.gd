extends GdUnitTestSuite


func test_long_lines_wrap_at_the_column_count() -> void:
	var model := TerminalModel.new()
	model.columns = 4
	assert_array(model.wrap_line("ABCDEFGHIJ")).contains_exactly(["ABCD", "EFGH", "IJ"])
	assert_array(model.wrap_line("")).contains_exactly([""])


func test_compose_shows_the_tail_then_prompt_then_reserved_line() -> void:
	var model := TerminalModel.new()
	model.rows = 4
	var screen := model.compose(PackedStringArray(["ONE", "TWO", "THREE"]), "TX", 0)
	assert_str(screen).is_equal("TWO\nTHREE\nLP4> TX_\n")


func test_scroll_moves_the_window_up() -> void:
	var model := TerminalModel.new()
	model.rows = 4
	var screen := model.compose(PackedStringArray(["ONE", "TWO", "THREE"]), "", 1)
	assert_str(screen).is_equal("ONE\nTWO\nLP4> _\n")
	assert_int(model.max_scroll(3)).is_equal(1)


func test_max_input_leaves_room_for_prompt_and_cursor() -> void:
	var model := TerminalModel.new()
	assert_int(model.max_input()).is_equal(model.columns - model.prompt.length() - 1)
