extends GdUnitTestSuite

var _model: VolumeModel

func _file(path: String, text: String, unlocked_by: String = "") -> StationFile:
	var file := StationFile.new()
	file.path = path
	file.text = text
	file.unlocked_by = unlocked_by
	return file

func before_test() -> void:
	_model = VolumeModel.new()
	_model.files = [
		_file("USR:OKONJO/NIGHTS.TXT", "ONE\nTWO\n"),
		_file("USR:OKONJO/WAKE.TXT", "A"),
		_file("SYS:TLM.MAN", "MANUAL", "TLM"),
	]

func test_files_under_a_prefix_skip_locked_ones() -> void:
	var none := PackedStringArray()
	assert_int(_model.files_under("USR:", none).size()).is_equal(2)
	assert_int(_model.files_under("usr:okonjo/w", none).size()).is_equal(1)
	assert_int(_model.files_under("SYS:", none).size()).is_equal(0)
	assert_int(_model.files_under("SYS:", PackedStringArray(["TLM"])).size()).is_equal(1)

func test_find_ignores_case_and_hides_locked_files() -> void:
	var none := PackedStringArray()
	assert_str(_model.find("usr:okonjo/wake.txt", none).path).is_equal("USR:OKONJO/WAKE.TXT")
	assert_object(_model.find("SYS:TLM.MAN", none)).is_null()
	assert_object(_model.find("SYS:TLM.MAN", PackedStringArray(["TLM"]))).is_not_null()
	assert_object(_model.find("NOPE:X", none)).is_null()

func test_lines_drop_the_trailing_break() -> void:
	assert_array(_model.lines(_model.files[0])).is_equal(PackedStringArray(["ONE", "TWO"]))
	assert_array(_model.lines(_file("X:Y", ""))).is_empty()
	assert_str(_model.files[1].volume()).is_equal("USR")

func test_resolves_directories_from_where_you_are() -> void:
	assert_str(_model.resolve("", "usr")).is_equal("USR:")
	assert_str(_model.resolve("", "USR:OKONJO")).is_equal("USR:OKONJO/")
	assert_str(_model.resolve("USR:", "OKONJO")).is_equal("USR:OKONJO/")
	assert_str(_model.resolve("USR:OKONJO/", "..")).is_equal("USR:")
	assert_str(_model.resolve("USR:", "..")).is_empty()
	assert_str(_model.resolve("USR:OKONJO/", "")).is_empty()
	assert_str(_model.file_path("USR:OKONJO/", "WAKE.TXT")).is_equal("USR:OKONJO/WAKE.TXT")
	assert_str(_model.file_path("USR:", "SYS:BOOT.LOG")).is_equal("SYS:BOOT.LOG")

func test_directories_exist_when_they_hold_a_file() -> void:
	var none := PackedStringArray()
	assert_bool(_model.exists("", none)).is_true()
	assert_bool(_model.exists("SYS:", none)).is_true()
	assert_bool(_model.exists("USR:OKONJO/", none)).is_true()
	assert_bool(_model.exists("USR:NOBODY/", none)).is_false()
	assert_bool(_model.exists("DAT:", none)).is_false()

func test_entries_list_one_level() -> void:
	var none := PackedStringArray()
	assert_array(_model.entries("USR:", none)).is_equal(PackedStringArray(["OKONJO/"]))
	var inside := PackedStringArray(["NIGHTS.TXT", "WAKE.TXT"])
	assert_array(_model.entries("USR:OKONJO/", none)).is_equal(inside)

func test_completes_volumes_directories_and_files() -> void:
	var none := PackedStringArray()
	assert_array(_model.completions("", "us", none)).is_equal(PackedStringArray(["USR:"]))
	assert_array(_model.completions("", "USR:O", none)).is_equal(PackedStringArray(["USR:OKONJO/"]))
	var both := PackedStringArray(["OKONJO/NIGHTS.TXT", "OKONJO/WAKE.TXT"])
	assert_array(_model.completions("USR:", "OKONJO/", none)).is_equal(both)
	var wake := PackedStringArray(["WAKE.TXT"])
	assert_array(_model.completions("USR:OKONJO/", "W", none)).is_equal(wake)
	assert_array(_model.completions("", "SYS:T", none)).is_empty()

func test_the_common_start_of_names() -> void:
	var names := PackedStringArray(["OKONJO/NIGHTS.TXT", "OKONJO/WAKE.TXT"])
	assert_str(VolumeModel.common_start(names)).is_equal("OKONJO/")
	assert_str(VolumeModel.common_start(PackedStringArray())).is_empty()

func test_the_game_files_fit_the_popup_and_their_volumes() -> void:
	var game: VolumeModel = load("res://game/data/models/volumes.tres")
	var paths := PackedStringArray()
	for file: StationFile in game.files:
		paths.append(file.path)
		var depth := file.path.get_slice(":", 1).count("/")
		assert_int(depth).override_failure_message(file.path).is_less_equal(1)
		assert_bool(game.volumes.has(file.volume())).override_failure_message(file.path).is_true()
		for line: String in game.lines(file):
			var message := "%s: %s" % [file.path, line]
			assert_int(line.length()).override_failure_message(message).is_less_equal(60)

	var expected := ["HTB:HEARTBEAT.LOG", "USR:OKONJO/NIGHTS.TXT", "USR:OKONJO/WAKE.TXT"]
	expected.append_array(["SYS:BOOT.LOG", "SYS:TLM.MAN", "SYS:IMG.MAN"])
	assert_array(paths).is_equal(PackedStringArray(expected))
	assert_object(game.find("SYS:TLM.MAN", PackedStringArray())).is_null()

func test_an_unlocked_archive_is_no_longer_sealed() -> void:
	var model := VolumeModel.new()
	assert_bool(model.is_sealed("ARC", PackedStringArray())).is_true()
	assert_bool(model.is_sealed("ARC", PackedStringArray(["ARC"]))).is_false()
	assert_bool(model.is_sealed("USR", PackedStringArray())).is_false()
