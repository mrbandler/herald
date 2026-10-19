extends GdUnitTestSuite

var _cd: CdCommand
var _out: AtomSpy

func before_test() -> void:
	_cd = CdCommand.new()
	_cd.out = StringEvent.new()
	_cd.unlocked_modules = StringListValue.new()
	_cd.directory = StringValue.new()
	_cd.volume_model = VolumeModel.new()
	var wake := StationFile.new()
	wake.path = "USR:OKONJO/WAKE.TXT"
	_cd.volume_model.files = [wake]
	_out = AtomSpy.events(_cd.out)

func test_moves_down_up_and_to_the_top() -> void:
	_cd.run(PackedStringArray(["USR"]))
	assert_str(_cd.directory.value).is_equal("USR:")
	_cd.run(PackedStringArray(["OKONJO"]))
	assert_str(_cd.directory.value).is_equal("USR:OKONJO/")
	_cd.run(PackedStringArray([".."]))
	assert_str(_cd.directory.value).is_equal("USR:")
	_cd.run(PackedStringArray(["USR:OKONJO"]))
	_cd.run(PackedStringArray())
	assert_str(_cd.directory.value).is_empty()
	assert_array(_out.calls).is_empty()

func test_refuses_sealed_unknown_and_missing() -> void:
	_cd.run(PackedStringArray(["ARC:"]))
	_cd.run(PackedStringArray(["DAT"]))
	_cd.run(PackedStringArray(["USR:NOBODY"]))
	_cd.run(PackedStringArray(["A", "B"]))
	var expected := [
		" ARC: SEALED",
		"DAT UNKNOWN VOLUME",
		"USR:NOBODY NOT FOUND",
		"USAGE: CD [<DIR>]",
	]
	assert_array(_out.calls).is_equal(expected)
	assert_str(_cd.directory.value).is_empty()
