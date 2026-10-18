extends GdUnitTestSuite

var _printer: LinkModePrinter
var _lines: Array[String] = []


func before_test() -> void:
	_lines.clear()
	_printer = auto_free(LinkModePrinter.new())
	_printer.locked = BoolValue.new()
	_printer.uplink_open = BoolValue.new()
	_printer.downlink_text = "DOWN"
	_printer.uplink_text = "UP"
	_printer.out = StringEvent.new()
	_printer.out.raised.connect(
		func(line: Variant) -> void:
			_lines.append(str(line)),
	)
	add_child(_printer)


func test_lock_before_the_uplink_names_the_downlink() -> void:
	_printer.locked.value = true
	assert_array(_lines).contains_exactly(["DOWN"])


func test_lock_while_the_uplink_is_open_names_the_uplink() -> void:
	_printer.uplink_open.value = true
	_printer.locked.value = true
	assert_array(_lines).contains_exactly(["UP"])


func test_losing_lock_prints_nothing() -> void:
	_printer.locked.value = true
	_printer.locked.value = false
	assert_array(_lines).contains_exactly(["DOWN"])
