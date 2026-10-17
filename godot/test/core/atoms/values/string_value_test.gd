extends GdUnitTestSuite


func test_starts_empty_and_resets_to_default() -> void:
	var atom := StringValue.new()
	assert_str(atom.value).is_empty()
	atom.default = "USR:/ODA/NOTES"
	atom.value = ""
	atom.reset()
	assert_str(atom.value).is_equal("USR:/ODA/NOTES")


func test_json_round_trip_keeps_string() -> void:
	var atom := StringValue.new()
	atom.value = "LP4> TX"
	var other := StringValue.new()
	other.restore(JSON.parse_string(JSON.stringify(atom.snapshot())))
	assert_str(other.value).is_equal("LP4> TX")
