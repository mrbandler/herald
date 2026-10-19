extends GdUnitTestSuite

var _label: ProgressLabel

func before_test() -> void:
	_label = auto_free(ProgressLabel.new())
	_label.progress_line = StringValue.new()
	_label.storage = ResourceListValue.new()
	_label.downlink_model = DownlinkModel.new()
	_label.storage_readout = auto_free(Label.new())
	add_child(_label)

func test_shows_the_idle_text_dimmed_while_nothing_runs() -> void:
	assert_str(_label.text).is_equal("NO TRANSFER")
	assert_object(_label.get_theme_color("font_color")).is_equal(_label.idle_color)
	assert_str(_label.storage_readout.text).is_equal("STORAGE 0/8")
	var readout_color := _label.storage_readout.get_theme_color("font_color")
	assert_object(readout_color).is_equal(_label.idle_color)

func test_shows_the_running_transfer() -> void:
	_label.progress_line.value = "RECV 21 AUTH [######----] 9/16"
	assert_str(_label.text).is_equal("RECV 21 AUTH [######----] 9/16")
	assert_object(_label.get_theme_color("font_color")).is_equal(_label.active_color)
	assert_str(_label.storage_readout.text).is_equal("STORAGE 0/8")
	_label.progress_line.value = ""
	assert_str(_label.text).is_equal("NO TRANSFER")

func test_the_readout_follows_the_storage() -> void:
	var item := DownlinkFixture.item(21, "IMG", 4, 16)
	_label.storage.add(DownlinkFixture.stored(item, []))
	assert_str(_label.storage_readout.text).is_equal("STORAGE 4/8")
