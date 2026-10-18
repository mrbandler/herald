extends GdUnitTestSuite

var _clr: ClrCommand
var _spy: AtomSpy
var _cleared: AtomSpy

func before_test() -> void:
	_clr = ClrCommand.new()
	_clr.out = StringEvent.new()
	_clr.cleared = Event.new()
	_spy = AtomSpy.events(_clr.out)
	_cleared = AtomSpy.events(_clr.cleared)

func test_clears_the_screen() -> void:
	_clr.run(PackedStringArray())
	assert_int(_cleared.calls.size()).is_equal(1)
	assert_array(_spy.calls).is_empty()

func test_refuses_arguments() -> void:
	_clr.run(PackedStringArray(["ALL"]))
	assert_int(_cleared.calls.size()).is_equal(0)
	assert_array(_spy.calls).is_equal(["USAGE: CLR"])
