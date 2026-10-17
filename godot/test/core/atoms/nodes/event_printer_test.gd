extends GdUnitTestSuite


func test_writes_text_when_event_fires() -> void:
	var printer: EventPrinter = auto_free(EventPrinter.new())
	printer.event = Event.new()
	printer.text = "-- TURN --"
	printer.out = StringEvent.new()
	var spy := AtomSpy.events(printer.out)
	add_child(printer)
	printer.event.raise(42)
	assert_array(spy.calls).is_equal(["-- TURN --"])
