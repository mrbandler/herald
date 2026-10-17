extends GdUnitTestSuite


func test_typed_handler_receives_string() -> void:
	var event := StringEvent.new()
	var received: Array[String] = []
	event.raised.connect(
		func(value: String) -> void:
			received.append(value),
	)
	event.raise("-- TURN --")
	assert_array(received).contains_exactly(["-- TURN --"])


func test_default_payload_is_empty_string() -> void:
	var event := StringEvent.new()
	var spy := AtomSpy.events(event)
	event.raise()
	assert_array(spy.calls).is_equal([""])
