extends GdUnitTestSuite

var _viewer: FileViewer

func before_test() -> void:
	_viewer = auto_free(FileViewer.new())
	_viewer.terminal_model = TerminalModel.new()
	_viewer.page_lines = 3
	_viewer.volume_model = VolumeModel.new()
	var file := StationFile.new()
	file.path = "USR:A.TXT"
	file.text = "1\n2\n3\n4\n5\n6\n7\n"
	_viewer.volume_model.files = [file]
	_viewer.viewing = StringValue.new()
	_viewer.focused = BoolValue.new()
	_viewer.focused.value = true
	_viewer.lean_amount = FloatValue.new()
	_viewer.lean_amount.value = 1.0
	_viewer.unlocked_modules = StringListValue.new()
	_viewer.panel = auto_free(Control.new())
	_viewer.title = auto_free(Label.new())
	_viewer.counter = auto_free(Label.new())
	_viewer.body = auto_free(Label.new())
	_viewer.hints = auto_free(Label.new())
	_viewer.hints.text = "ESC LEAVE"
	add_child(_viewer)

func test_hidden_until_a_file_is_viewed() -> void:
	assert_bool(_viewer.panel.visible).is_false()
	assert_str(_viewer.hints.text).is_equal("ESC LEAVE")
	assert_bool(_viewer.handle_key(KEY_DOWN)).is_false()

func test_shows_the_file_and_swaps_the_hints() -> void:
	_viewer.viewing.value = "USR:A.TXT"
	assert_bool(_viewer.panel.visible).is_true()
	assert_str(_viewer.title.text).is_equal("USR:A.TXT")
	assert_str(_viewer.body.text).is_equal("1\n2\n3")
	assert_str(_viewer.counter.text).is_equal("1-3/7")
	assert_str(_viewer.hints.text).is_equal(FileViewer.HINTS)
	_viewer.viewing.value = ""
	assert_bool(_viewer.panel.visible).is_false()
	assert_str(_viewer.hints.text).is_equal("ESC LEAVE")

func test_scrolls_within_the_file() -> void:
	_viewer.viewing.value = "USR:A.TXT"
	assert_bool(_viewer.handle_key(KEY_DOWN)).is_true()
	assert_str(_viewer.counter.text).is_equal("2-4/7")
	_viewer.handle_key(KEY_PAGEDOWN)
	_viewer.handle_key(KEY_PAGEDOWN)
	assert_str(_viewer.counter.text).is_equal("5-7/7")
	assert_str(_viewer.body.text).is_equal("5\n6\n7")
	_viewer.handle_key(KEY_PAGEUP)
	_viewer.handle_key(KEY_UP)
	_viewer.handle_key(KEY_UP)
	assert_str(_viewer.counter.text).is_equal("1-3/7")

func test_the_wheel_scrolls_and_esc_is_left_alone() -> void:
	_viewer.viewing.value = "USR:A.TXT"
	assert_bool(_viewer.handle_wheel(MOUSE_BUTTON_WHEEL_DOWN)).is_true()
	assert_str(_viewer.counter.text).is_equal("4-6/7")
	assert_bool(_viewer.handle_wheel(MOUSE_BUTTON_LEFT)).is_false()
	assert_bool(_viewer.handle_key(KEY_ESCAPE)).is_false()

func test_a_locked_file_does_not_open() -> void:
	_viewer.volume_model.files[0].unlocked_by = "TLM"
	_viewer.viewing.value = "USR:A.TXT"
	assert_bool(_viewer.panel.visible).is_false()

func test_a_file_already_open_shows_on_ready() -> void:
	var fresh: FileViewer = auto_free(FileViewer.new())
	fresh.terminal_model = _viewer.terminal_model
	fresh.page_lines = 3
	fresh.volume_model = _viewer.volume_model
	fresh.viewing = StringValue.new()
	fresh.viewing.value = "USR:A.TXT"
	fresh.focused = _viewer.focused
	fresh.lean_amount = _viewer.lean_amount
	fresh.unlocked_modules = _viewer.unlocked_modules
	fresh.panel = auto_free(Control.new())
	fresh.title = auto_free(Label.new())
	fresh.counter = auto_free(Label.new())
	fresh.body = auto_free(Label.new())
	fresh.hints = auto_free(Label.new())
	add_child(fresh)
	assert_bool(fresh.panel.visible).is_true()
	assert_str(fresh.hints.text).is_equal(FileViewer.HINTS)
