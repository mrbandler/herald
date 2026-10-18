extends GdUnitTestSuite

func test_default_seeds_and_reset_returns() -> void:
	var atom := IntValue.new()
	assert_int(atom.value).is_equal(0)
	atom.default = 6
	assert_int(atom.value).is_equal(6)
	atom.value = 2
	atom.reset()
	assert_int(atom.value).is_equal(6)

func test_json_round_trip_keeps_int() -> void:
	var atom := IntValue.new()
	atom.value = 3
	var other := IntValue.new()
	other.restore(JSON.parse_string(JSON.stringify(atom.snapshot())))
	assert_int(typeof(other.snapshot())).is_equal(TYPE_INT)
	assert_int(other.value).is_equal(3)
