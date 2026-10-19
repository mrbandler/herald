extends GdUnitTestSuite

func test_a_press_raises_its_event() -> void:
	var button: PushButton = auto_free(PushButton.new())
	button.pressed = Event.new()
	var presses := AtomSpy.events(button.pressed)
	button.grab()
	assert_int(presses.calls.size()).is_equal(1)
