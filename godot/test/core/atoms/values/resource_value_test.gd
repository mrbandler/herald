extends GdUnitTestSuite


func test_starts_null() -> void:
	assert_object(ResourceValue.new().value).is_null()


func test_switching_the_pointer_emits() -> void:
	var atom := ResourceValue.new()
	var first := FloatValue.new()
	var second := FloatValue.new()
	atom.value = first
	var spy := AtomSpy.values(atom)
	atom.value = second
	assert_object(atom.value).is_same(second)
	assert_int(spy.calls.size()).is_equal(1)


func test_default_seeds_the_pointer() -> void:
	var atom := ResourceValue.new()
	var target := FloatValue.new()
	atom.default = target
	assert_object(atom.value as FloatValue).is_same(target)
