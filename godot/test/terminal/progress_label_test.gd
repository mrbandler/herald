extends GdUnitTestSuite

var _label: ProgressLabel

func before_test() -> void:
	_label = auto_free(ProgressLabel.new())
	_label.progress_line = StringValue.new()
	add_child(_label)

func test_shows_the_idle_text_dimmed_while_nothing_runs() -> void:
	assert_str(_label.text).is_equal("NO TRANSFER")
	assert_object(_label.get_theme_color("font_color")).is_equal(_label.idle_color)

func test_shows_the_running_transfer() -> void:
	_label.progress_line.value = "RECV 21 AUTH [######----] 9/16"
	assert_str(_label.text).is_equal("RECV 21 AUTH [######----] 9/16")
	assert_object(_label.get_theme_color("font_color")).is_equal(_label.active_color)
	_label.progress_line.value = ""
	assert_str(_label.text).is_equal("NO TRANSFER")
