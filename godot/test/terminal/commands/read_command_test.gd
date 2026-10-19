extends GdUnitTestSuite

var _read: ReadCommand
var _out: AtomSpy

func before_test() -> void:
	_read = ReadCommand.new()
	_read.out = StringEvent.new()
	_read.unlocked_modules = StringListValue.new()
	_read.viewing = StringValue.new()
	_read.directory = StringValue.new()
	_read.volume_model = VolumeModel.new()
	var wake := StationFile.new()
	wake.path = "USR:OKONJO/WAKE.TXT"
	var manual := StationFile.new()
	manual.path = "SYS:TLM.MAN"
	manual.unlocked_by = "TLM"
	_read.volume_model.files = [wake, manual]
	_out = AtomSpy.events(_read.out)

func test_opens_the_file_by_its_own_path() -> void:
	_read.run(PackedStringArray(["usr:okonjo/wake.txt"]))
	assert_str(_read.viewing.value).is_equal("USR:OKONJO/WAKE.TXT")
	assert_array(_out.calls).is_empty()

func test_missing_and_locked_files_are_not_found() -> void:
	_read.run(PackedStringArray(["USR:NOPE.TXT"]))
	_read.run(PackedStringArray(["SYS:TLM.MAN"]))
	assert_str(_read.viewing.value).is_empty()
	assert_array(_out.calls).is_equal(["USR:NOPE.TXT NOT FOUND", "SYS:TLM.MAN NOT FOUND"])

func test_reads_relative_to_the_working_directory() -> void:
	_read.directory.value = "USR:OKONJO/"
	_read.run(PackedStringArray(["WAKE.TXT"]))
	assert_str(_read.viewing.value).is_equal("USR:OKONJO/WAKE.TXT")

func test_usage() -> void:
	_read.run(PackedStringArray())
	assert_array(_out.calls).is_equal(["USAGE: READ <FILE>"])
