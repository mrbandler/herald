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
	_ls.volume_model = VolumeModel.new()
	_ls.volume_model.files = [
		_file("HTB:HEARTBEAT.LOG", "A"),
		_file("USR:OKONJO/NIGHTS.TXT", "A\nB"),
		_file("USR:OKONJO/WAKE.TXT", "A\nB\nC"),
		_file("SYS:TLM.MAN", "A", "TLM"),
	]
	_out = AtomSpy.events(_ls.out)

func test_lists_the_volumes() -> void:
	_ls.run(PackedStringArray())
	var expected := [" HTB:  1 FILE", " USR:  2 FILES", " SYS:  NO FILES", " ARC:  SEALED"]
	assert_array(_out.calls).is_equal(expected)

func test_lists_a_volumes_files() -> void:
	_ls.run(PackedStringArray(["USR"]))
	var expected := [
		" USR:OKONJO/NIGHTS.TXT            2 LINES",
		" USR:OKONJO/WAKE.TXT              3 LINES",
	]
	assert_array(_out.calls).is_equal(expected)

func test_a_prefix_narrows_the_files() -> void:
	_ls.run(PackedStringArray(["USR:OKONJO/W"]))
	_ls.run(PackedStringArray(["USR:NOBODY"]))
	assert_array(_out.calls).is_equal([" USR:OKONJO/WAKE.TXT              3 LINES", " NO FILES"])

func test_sealed_unknown_and_usage() -> void:
	_ls.run(PackedStringArray(["ARC:"]))
	_ls.run(PackedStringArray(["DAT:"]))
	_ls.run(PackedStringArray(["A", "B"]))
	assert_array(_out.calls).is_equal([" ARC: SEALED", "DAT UNKNOWN VOLUME", "USAGE: LS [<VOL:>]"])

func test_a_file_appears_with_its_module() -> void:
	_ls.run(PackedStringArray(["SYS:"]))
	_ls.unlocked_modules.value = PackedStringArray(["TLM"])
	_ls.run(PackedStringArray(["SYS:"]))
	assert_array(_out.calls).is_equal([" NO FILES", " SYS:TLM.MAN                      1 LINE"])
