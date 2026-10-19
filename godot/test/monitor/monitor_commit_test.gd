extends GdUnitTestSuite

var _commit: MonitorCommit
var _out: AtomSpy
var _image: StoredItem

func before_test() -> void:
	_commit = auto_free(MonitorCommit.new())
	_commit.commit_pressed = Event.new()
	_commit.shown_item = ResourceValue.new()
	_commit.monitor_mode = IntValue.new()
	_commit.knob_line = FloatValue.new()
	_commit.knob_line.value = 103.4
	_commit.knob_offset = FloatValue.new()
	_commit.knob_offset.value = 0.37
	_commit.knob_contrast = FloatValue.new()
	_commit.knob_contrast.value = 0.6
	_commit.storage = ResourceListValue.new()
	_commit.downlink_model = DownlinkModel.new()
	_commit.out = StringEvent.new()
	_image = DownlinkFixture.stored(DownlinkFixture.item(33, "IMG", 6, 2), [0, 0])
	_commit.storage.add(_image)
	_commit.shown_item.value = _image
	_out = AtomSpy.events(_commit.out)
	add_child(_commit)

func test_commit_keeps_the_tuning_as_a_decoded_copy() -> void:
	_commit.monitor_mode.value = MonitorModel.Mode.TUNE
	_commit.commit_pressed.raise()
	var kept := _commit.storage.value[0] as StoredItem
	assert_object(kept).is_not_same(_image)
	assert_bool(kept.decoded).is_true()
	assert_vector(kept.tuning).is_equal_approx(Vector3(103.4, 0.37, 0.6), Vector3.ONE * 0.0001)
	assert_object(_commit.shown_item.value).is_same(kept)
	assert_int(_commit.monitor_mode.value).is_equal(MonitorModel.Mode.SHOW)
	assert_array(_out.calls).is_equal(["33 DECODED"])

func test_only_tuning_commits() -> void:
	_commit.commit_pressed.raise()
	assert_bool((_commit.storage.value[0] as StoredItem).decoded).is_false()
	assert_array(_out.calls).is_empty()

func test_a_tagged_copy_is_the_one_committed() -> void:
	_commit.monitor_mode.value = MonitorModel.Mode.TUNE
	var tagged := _image.duplicate() as StoredItem
	tagged.tag = "RINGS"
	_commit.storage.replace(_image, tagged)
	_commit.commit_pressed.raise()
	var kept := _commit.storage.value[0] as StoredItem
	assert_bool(kept.decoded).is_true()
	assert_str(kept.tag).is_equal("RINGS")

func test_a_deleted_image_is_unknown() -> void:
	_commit.monitor_mode.value = MonitorModel.Mode.TUNE
	_commit.storage.clear()
	_commit.commit_pressed.raise()
	assert_array(_out.calls).is_equal(["33 UNKNOWN ITEM"])
	assert_int(_commit.monitor_mode.value).is_equal(MonitorModel.Mode.SNOW)
