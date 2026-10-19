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

func test_the_game_files_fit_the_popup_and_their_volumes() -> void:
	var game: VolumeModel = load("res://game/data/models/volumes.tres")
	var paths := PackedStringArray()
	for file: StationFile in game.files:
		paths.append(file.path)
		assert_bool(game.volumes.has(file.volume())).override_failure_message(file.path).is_true()
		for line: String in game.lines(file):
			var message := "%s: %s" % [file.path, line]
			assert_int(line.length()).override_failure_message(message).is_less_equal(60)

	var expected := ["HTB:HEARTBEAT.LOG", "USR:OKONJO/NIGHTS.TXT", "USR:OKONJO/WAKE.TXT"]
	expected.append_array(["SYS:BOOT.LOG", "SYS:TLM.MAN"])
	assert_array(paths).is_equal(PackedStringArray(expected))
	assert_object(game.find("SYS:TLM.MAN", PackedStringArray())).is_null()
