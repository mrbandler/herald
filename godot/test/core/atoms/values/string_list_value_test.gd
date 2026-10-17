extends GdUnitTestSuite


func test_assigning_a_new_array_emits() -> void:
	var atom := StringListValue.new()
	var spy := AtomSpy.values(atom)
	atom.value = atom.value + PackedStringArray(["ACK"])
	assert_array(atom.value).contains_exactly(["ACK"])
	assert_int(spy.calls.size()).is_equal(1)


func test_reset_restores_the_default_without_sharing_it() -> void:
	var atom := StringListValue.new()
	atom.default = PackedStringArray(["ACK"])
	atom.value = PackedStringArray(["TX"])
	var spy := AtomSpy.values(atom)
	atom.reset()
	assert_array(atom.value).contains_exactly(["ACK"])
	assert_int(spy.calls.size()).is_equal(1)
	var read := atom.value
	read.append("X")
	assert_array(atom.default).contains_exactly(["ACK"])


func test_equal_contents_do_not_emit() -> void:
	var atom := StringListValue.new()
	atom.value = PackedStringArray(["ACK"])
	var spy := AtomSpy.values(atom)
	atom.value = PackedStringArray(["ACK"])
	assert_array(spy.calls).is_empty()


func test_json_round_trip_keeps_packed_array() -> void:
	var atom := StringListValue.new()
	atom.value = PackedStringArray(["SEQ ADD ACK", "TX"])
	var other := StringListValue.new()
	other.restore(JSON.parse_string(JSON.stringify(atom.snapshot())))
	assert_int(typeof(other.snapshot())).is_equal(TYPE_PACKED_STRING_ARRAY)
	assert_array(other.value).contains_exactly(["SEQ ADD ACK", "TX"])
