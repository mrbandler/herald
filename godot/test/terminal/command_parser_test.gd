extends GdUnitTestSuite


func test_splits_into_upper_case_words() -> void:
	var words := CommandParser.parse("seq add ack")
	assert_array(words).contains_exactly(["SEQ", "ADD", "ACK"])


func test_commas_separate_like_spaces() -> void:
	var words := CommandParser.parse("GET 21, 23")
	assert_array(words).contains_exactly(["GET", "21", "23"])


func test_blank_line_has_no_words() -> void:
	assert_array(CommandParser.parse("   ")).is_empty()
