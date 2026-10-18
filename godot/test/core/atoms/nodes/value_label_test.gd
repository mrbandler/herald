extends GdUnitTestSuite

func test_draws_on_ready_and_on_update() -> void:
	var label: ValueLabel = auto_free(ValueLabel.new())
	label.source = FloatValue.new()
	label.source.value = 214.6
	label.format = "AZ %05.1f"
	add_child(label)
	assert_str(label.text).is_equal("AZ 214.6")
	label.source.value = 7.0
	assert_str(label.text).is_equal("AZ 007.0")
