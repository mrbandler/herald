extends GdUnitTestSuite


func test_starts_at_zero() -> void:
	assert_float(FloatValue.new().value).is_equal(0.0)


func test_setting_default_seeds_value_silently() -> void:
	var atom := FloatValue.new()
	var spy := AtomSpy.values(atom)
	atom.default = 2.5
	assert_float(atom.value).is_equal(2.5)
	assert_array(spy.calls).is_empty()


func test_set_emits_previous_and_current() -> void:
	var atom := FloatValue.new()
	var spy := AtomSpy.values(atom)
	atom.value = 3.0
	atom.value = 1.0
	assert_array(spy.calls).is_equal([[0.0, 3.0], [3.0, 1.0]])


func test_same_value_does_not_emit() -> void:
	var atom := FloatValue.new()
	var spy := AtomSpy.values(atom)
	atom.value = 3.0
	atom.value = 3.0
	assert_int(spy.calls.size()).is_equal(1)


func test_reset_returns_to_default() -> void:
	var atom := FloatValue.new()
	atom.default = 2.5
	atom.value = 9.0
	var spy := AtomSpy.values(atom)
	atom.reset()
	assert_float(atom.value).is_equal(2.5)
	assert_array(spy.calls).is_equal([[9.0, 2.5]])


func test_typed_handler_receives_floats() -> void:
	var atom := FloatValue.new()
	var received: Array[float] = []
	atom.updated.connect(
		func(previous: float, current: float) -> void:
			received.append_array([previous, current]),
	)
	atom.value = 2.0
	assert_array(received).contains_exactly([0.0, 2.0])


func test_snapshot_restore_round_trips_through_json() -> void:
	var atom := FloatValue.new()
	atom.value = 4.25
	var other := FloatValue.new()
	other.restore(JSON.parse_string(JSON.stringify(atom.snapshot())))
	assert_float(other.value).is_equal(4.25)
