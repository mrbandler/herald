extends GdUnitTestSuite

func test_resets_every_atom_on_ready() -> void:
	var time := FloatValue.new()
	time.default = 5.0
	time.value = 99.0
	var lock := BoolValue.new()
	lock.value = true
	var resetter: Resetter = auto_free(Resetter.new())
	resetter.atoms = [time, lock]
	add_child(resetter)
	assert_float(time.value).is_equal(5.0)
	assert_bool(lock.value).is_false()
