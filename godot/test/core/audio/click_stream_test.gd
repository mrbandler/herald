extends GdUnitTestSuite

func test_builds_a_short_decaying_tick() -> void:
	var click := ClickStream.new()
	assert_int(click.data.size()).is_equal(int(click.rate * click.duration) * 2)
	var head := absi(click.data.decode_s16(2)) + absi(click.data.decode_s16(4))
	var tail := absi(click.data.decode_s16(click.data.size() - 2))
	assert_int(head).is_greater(tail)
	click.duration = 0.05
	assert_int(click.data.size()).is_equal(int(click.rate * 0.05) * 2)
