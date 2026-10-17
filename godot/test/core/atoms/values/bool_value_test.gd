extends GdUnitTestSuite


func test_default_seeds_and_reset_returns() -> void:
	var atom := BoolValue.new()
	assert_bool(atom.value).is_false()
	atom.default = true
	assert_bool(atom.value).is_true()
	atom.value = false
	atom.reset()
	assert_bool(atom.value).is_true()


func test_emits_on_toggle() -> void:
	var atom := BoolValue.new()
	var spy := AtomSpy.values(atom)
	atom.value = true
	assert_array(spy.calls).is_equal([[false, true]])


func test_json_round_trip_keeps_bool() -> void:
	var atom := BoolValue.new()
	atom.value = true
	var other := BoolValue.new()
	other.restore(JSON.parse_string(JSON.stringify(atom.snapshot())))
	assert_bool(other.value).is_true()
