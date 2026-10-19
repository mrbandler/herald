extends GdUnitTestSuite

func test_renders_a_click_then_a_thock() -> void:
	var stream := SwitchStream.new()
	assert_float(stream.get_length()).is_equal_approx(stream.duration, 0.001)
	var click_end := int(stream.rate * stream.bottom_delay * 0.5)
	var thock_at := int(stream.rate * (stream.bottom_delay + 0.002))
	var peak_click := 0
	for i: int in range(click_end):
		peak_click = maxi(peak_click, absi(stream.data.decode_s16(i * 2)))
	var peak_thock := 0
	for i: int in range(thock_at, thock_at + 40):
		peak_thock = maxi(peak_thock, absi(stream.data.decode_s16(i * 2)))
	assert_int(peak_click).is_greater(1000)
	assert_int(peak_thock).is_greater(peak_click)
