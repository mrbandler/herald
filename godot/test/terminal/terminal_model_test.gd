extends GdUnitTestSuite

func test_long_lines_wrap_at_the_column_count() -> void:
	var model := TerminalModel.new()
	model.columns = 4
	assert_array(model.wrap_line("ABCDEFGHIJ")).contains_exactly(["ABCD", "EFGH", "IJ"])
	assert_array(model.wrap_line("")).contains_exactly([""])

func test_compose_shows_the_tail_then_the_prompt() -> void:
	var model := TerminalModel.new()
	model.rows = 3
	var screen := model.compose(PackedStringArray(["ONE", "TWO", "THREE"]), "TX", 0)
	assert_str(screen).is_equal("TWO\nTHREE\n" + _command(model, "LP4> TX_"))

func test_scroll_moves_the_window_up() -> void:
	var model := TerminalModel.new()
	model.rows = 3
	var screen := model.compose(PackedStringArray(["ONE", "TWO", "THREE"]), "", 1)
	assert_str(screen).is_equal("ONE\nTWO\n" + _command(model, "LP4> _"))
	assert_int(model.max_scroll(3)).is_equal(1)

func test_compose_colours_commands_and_escapes_brackets() -> void:
	var model := TerminalModel.new()
	var lines := PackedStringArray(["LP4> GET 21", "RECV [##--] 1/2"])
	var screen := model.compose(lines, "", 0)
	var expected := [
		_command(model, "LP4> GET 21"),
		"RECV [lb]##--] 1/2",
		_command(model, "LP4> _"),
	]
	assert_str(screen).is_equal("\n".join(expected))

func _command(model: TerminalModel, line: String) -> String:
	return "[color=#%s]%s[/color]" % [model.command_color.to_html(false), line]

func test_the_rules_mark_lines_below_and_above() -> void:
	var model := TerminalModel.new()
	model.columns = 20
	model.rows = 4
	assert_str(model.rule_below(0)).is_equal("─".repeat(20))
	assert_str(model.rule_below(12)).is_equal("──── +12 BELOW ─────")
	assert_str(model.rule_above(0)).is_equal("─".repeat(20))
	assert_str(model.rule_above(40)).is_equal("──── +40 ABOVE ─────")
	assert_int(model.lines_above(10, 2)).is_equal(5)
	assert_int(model.lines_above(2, 0)).is_equal(0)

func test_max_input_leaves_room_for_prompt_and_cursor() -> void:
	var model := TerminalModel.new()
	assert_int(model.max_input()).is_equal(model.columns - model.prompt.length() - 1)
