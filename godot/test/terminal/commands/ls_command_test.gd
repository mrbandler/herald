extends GdUnitTestSuite

var _ls: LsCommand
var _out: AtomSpy

func _file(path: String, text: String, unlocked_by: String = "") -> StationFile:
	var file := StationFile.new()
	file.path = path
	file.text = text
	file.unlocked_by = unlocked_by
	return file

func before_test() -> void:
	_ls = LsCommand.new()
	_ls.out = StringEvent.new()
	_ls.unlocked_modules = StringListValue.new()
	_ls.directory = StringValue.new()
	_ls.volume_model = VolumeModel.new()
	_ls.volume_model.files = [
		_file("HTB:HEARTBEAT.LOG", "A"),
		_file("USR:OKONJO/NIGHTS.TXT", "A\nB"),
		_file("USR:OKONJO/WAKE.TXT", "A\nB\nC"),
		_file("SYS:TLM.MAN", "A", "TLM"),
	]
	_out = AtomSpy.events(_ls.out)

func test_lists_the_volumes_at_the_top() -> void:
	_ls.run(PackedStringArray())
	var expected := [" HTB:  1 FILE(S)", " USR:  2 FILE(S)", " SYS:  0 FILE(S)", " ARC:  SEALED"]
	assert_array(_out.calls).is_equal(expected)

func test_lists_a_directory_one_level_deep() -> void:
	_ls.run(PackedStringArray(["USR"]))
	_ls.run(PackedStringArray(["USR:OKONJO"]))
	var expected := [
		" OKONJO/                        2 FILE(S)",
		" NIGHTS.TXT                     2 LINE(S)",
		" WAKE.TXT                       3 LINE(S)",
	]
	assert_array(_out.calls).is_equal(expected)

func test_lists_the_working_directory_and_relative_names() -> void:
	_ls.directory.value = "USR:"
	_ls.run(PackedStringArray())
	_ls.run(PackedStringArray(["OKONJO"]))
	assert_str(_out.calls[0]).is_equal(" OKONJO/                        2 FILE(S)")
	assert_int(_out.calls.size()).is_equal(3)

func test_sealed_unknown_missing_and_usage() -> void:
	_ls.run(PackedStringArray(["ARC:"]))
	_ls.run(PackedStringArray(["DAT:"]))
	_ls.run(PackedStringArray(["USR:NOBODY"]))
	_ls.run(PackedStringArray(["A", "B"]))
	var expected := [
		" ARC: SEALED",
		"DAT UNKNOWN VOLUME",
		"USR:NOBODY NOT FOUND",
		"USAGE: LS [<DIR>]",
	]
	assert_array(_out.calls).is_equal(expected)

func test_a_file_appears_with_its_module() -> void:
	_ls.run(PackedStringArray(["SYS:"]))
	_ls.unlocked_modules.value = PackedStringArray(["TLM"])
	_ls.run(PackedStringArray(["SYS:"]))
	assert_array(_out.calls).is_equal([" NO FILES", " TLM.MAN                        1 LINE(S)"])
