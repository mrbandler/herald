extends GdUnitTestSuite


func test_builds_one_peep_per_note_with_gaps() -> void:
	var chime := ChimeStream.new()
	chime.notes = PackedFloat32Array([1000.0, 1500.0])
	var per_note := int(chime.rate * (chime.note_seconds + chime.gap_seconds))
	assert_int(chime.data.size()).is_equal(2 * per_note * 2)
	var in_gap := chime.data.decode_s16((per_note - 2) * 2)
	assert_int(in_gap).is_equal(0)
	var loudest := 0
	for i: int in range(per_note):
		loudest = maxi(loudest, absi(chime.data.decode_s16(i * 2)))
	assert_int(loudest).is_greater(1000)
