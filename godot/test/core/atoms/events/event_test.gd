extends GdUnitTestSuite


func test_raise_without_payload_sends_null() -> void:
	var event := Event.new()
	var spy := AtomSpy.events(event)
	event.raise()
	assert_array(spy.calls).is_equal([null])


func test_raise_passes_payload() -> void:
	var event := Event.new()
	var spy := AtomSpy.events(event)
	event.raise(7)
	assert_array(spy.calls).is_equal([7])
