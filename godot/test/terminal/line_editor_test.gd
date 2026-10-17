extends GdUnitTestSuite

var _history := PackedStringArray(["SEQ ADD ACK", "TX"])


func test_insert_is_upper_case_and_capped() -> void:
	var editor := LineEditor.new()
	editor.insert("s", 2)
	editor.insert("e", 2)
	editor.insert("q", 2)
	assert_str(editor.text).is_equal("SE")


func test_backspace_removes_the_last_character() -> void:
	var editor := LineEditor.new()
	editor.insert("A", 10)
	editor.insert("B", 10)
	editor.backspace()
	assert_str(editor.text).is_equal("A")
	editor.backspace()
	editor.backspace()
	assert_str(editor.text).is_empty()


func test_submit_returns_and_clears() -> void:
	var editor := LineEditor.new()
	editor.insert("A", 10)
	assert_str(editor.submit()).is_equal("A")
	assert_str(editor.text).is_empty()


func test_history_walks_up_and_back_down() -> void:
	var editor := LineEditor.new()
	editor.history_up(_history)
	assert_str(editor.text).is_equal("TX")
	editor.history_up(_history)
	assert_str(editor.text).is_equal("SEQ ADD ACK")
	editor.history_up(_history)
	assert_str(editor.text).is_equal("SEQ ADD ACK")
	editor.history_down(_history)
	assert_str(editor.text).is_equal("TX")
	editor.history_down(_history)
	assert_str(editor.text).is_empty()


func test_scroll_is_clamped() -> void:
	var editor := LineEditor.new()
	editor.scroll_by(16, 10)
	assert_int(editor.scroll).is_equal(10)
	editor.scroll_by(-16, 10)
	assert_int(editor.scroll).is_equal(0)
