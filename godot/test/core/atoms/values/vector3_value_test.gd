extends GdUnitTestSuite


func test_starts_at_zero() -> void:
	assert_vector(Vector3Value.new().value).is_equal(Vector3.ZERO)


func test_json_round_trip_keeps_vector() -> void:
	var atom := Vector3Value.new()
	atom.value = Vector3(1.5, -2.0, 3.25)
	var other := Vector3Value.new()
	other.restore(JSON.parse_string(JSON.stringify(atom.snapshot())))
	assert_vector(other.value).is_equal(Vector3(1.5, -2.0, 3.25))
