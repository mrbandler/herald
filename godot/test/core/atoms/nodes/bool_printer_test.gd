extends GdUnitTestSuite


func test_prints_on_each_change() -> void:
	var printer: BoolPrinter = auto_free(BoolPrinter.new())
	printer.source = BoolValue.new()
	printer.on_text = "-- LOCK --"
	printer.off_text = "-- LOCK LOST --"
	printer.out = StringEvent.new()
	var lines: Array[String] = []
	printer.out.raised.connect(
		func(line: Variant) -> void:
			lines.append(str(line)),
	)
	add_child(printer)
	printer.source.value = false
	printer.source.value = true
	printer.source.value = true
	printer.source.value = false
	assert_array(lines).contains_exactly(["-- LOCK --", "-- LOCK LOST --"])
