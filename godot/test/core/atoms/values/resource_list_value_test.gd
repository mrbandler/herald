extends GdUnitTestSuite

func test_add_and_remove_emit_and_keep_the_type() -> void:
	var atom := ResourceListValue.new()
	var spy := AtomSpy.values(atom)
	var first := Resource.new()
	atom.add(first)
	atom.add(Resource.new())
	atom.remove(first)
	assert_int(spy.calls.size()).is_equal(3)
	assert_int(atom.value.size()).is_equal(1)
	assert_bool(atom.value.is_typed()).is_true()

func test_add_never_mutates_the_old_array() -> void:
	var atom := ResourceListValue.new()
	var before := atom.value
	atom.add(Resource.new())
	assert_int(before.size()).is_equal(0)

func test_clear_and_reset_return_to_empty() -> void:
	var atom := ResourceListValue.new()
	atom.add(Resource.new())
	atom.clear()
	assert_int(atom.value.size()).is_equal(0)
	atom.add(Resource.new())
	atom.reset()
	assert_int(atom.value.size()).is_equal(0)
