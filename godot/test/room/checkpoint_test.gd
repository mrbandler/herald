extends GdUnitTestSuite

func test_retry_restores_the_window_start_and_start_over_resets() -> void:
	var number := IntValue.new()
	number.value = 4
	var history := StringListValue.new()
	history.value = PackedStringArray(["LS"])
	var checkpoint: Checkpoint = auto_free(Checkpoint.new())
	checkpoint.atoms = [number, history]
	add_child(checkpoint)
	number.value = 5
	history.value = PackedStringArray(["LS", "TX"])
	checkpoint.retry()
	assert_int(number.value).is_equal(4)
	assert_array(history.value).is_equal(PackedStringArray(["LS"]))
	checkpoint.start_over()
	assert_int(number.value).is_equal(number.default)
	assert_array(history.value).is_empty()
