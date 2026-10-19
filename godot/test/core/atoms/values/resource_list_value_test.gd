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

func test_replace_keeps_the_place_and_emits() -> void:
	var atom := ResourceListValue.new()
	var first := Resource.new()
	var second := Resource.new()
	var third := Resource.new()
	atom.add(first)
	atom.add(second)
	var spy := AtomSpy.values(atom)
	atom.replace(first, third)
	assert_object(atom.value[0]).is_same(third)
	assert_object(atom.value[1]).is_same(second)
	assert_int(spy.calls.size()).is_equal(1)
	atom.replace(Resource.new(), first)
	assert_int(spy.calls.size()).is_equal(1)
