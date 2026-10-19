extends GdUnitTestSuite

func test_builds_the_rush_then_the_thunk() -> void:
	var whoosh := WhooshStream.new()
	assert_int(whoosh.data.size()).is_equal(int(whoosh.rate * whoosh.duration) * 2)
	var early := absi(whoosh.data.decode_s16(int(whoosh.rate * 0.02) * 2))
	var landing := int(whoosh.rate * whoosh.duration * whoosh.rush) + 40
	var peak := 0
	for i: int in range(landing, landing + 400):
		peak = maxi(peak, absi(whoosh.data.decode_s16(i * 2)))
	assert_int(peak).is_greater(early)
