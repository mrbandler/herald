extends GdUnitTestSuite

func test_on_and_off_drive_the_bool() -> void:
	var latch: EventLatch = auto_free(EventLatch.new())
	latch.on = Event.new()
	latch.off = Event.new()
	latch.target = BoolValue.new()
	add_child(latch)
	latch.on.raise()
	assert_bool(latch.target.value).is_true()
	latch.off.raise()
	assert_bool(latch.target.value).is_false()

func test_off_is_optional() -> void:
	var latch: EventLatch = auto_free(EventLatch.new())
	latch.on = Event.new()
	latch.target = BoolValue.new()
	add_child(latch)
	latch.on.raise()
	assert_bool(latch.target.value).is_true()
