extends GdUnitTestSuite

func test_prints_its_text() -> void:
	var command := TextCommand.new()
	command.out = StringEvent.new()
	command.text = "ONE\nTWO"
	var out := AtomSpy.events(command.out)
	command.run(PackedStringArray(["ANYTHING"]))
	assert_array(out.calls).is_equal(["ONE", "TWO"])
