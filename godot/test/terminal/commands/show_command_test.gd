extends GdUnitTestSuite

var _show: ShowCommand
var _out: AtomSpy
var _image: StoredItem

func before_test() -> void:
	_show = ShowCommand.new()
	_show.out = StringEvent.new()
	_show.module_model = ModuleModel.new()
	_show.module_model.modules = PackedStringArray(["TLM", "IMG"])
	_show.downlink_model = DownlinkModel.new()
	_show.storage = ResourceListValue.new()
	_show.unlocked_modules = StringListValue.new()
	_show.unlocked_modules.value = PackedStringArray(["IMG"])
	_show.shown_item = ResourceValue.new()
	_show.monitor_mode = IntValue.new()
	_image = DownlinkFixture.stored(DownlinkFixture.item(33, "IMG", 6, 2), [0, 0])
	_show.storage.add(_image)
	_show.storage.add(DownlinkFixture.stored(DownlinkFixture.item(22, "TLM", 1, 2), [0, 0]))
	_out = AtomSpy.events(_show.out)

func _run(words: Array[String]) -> void:
	_show.run(PackedStringArray(words))

func test_shows_a_decoded_image() -> void:
	_image.decoded = true
	_run(["33"])
	assert_object(_show.shown_item.value).is_same(_image)
	assert_int(_show.monitor_mode.value).is_equal(MonitorModel.Mode.SHOW)
	assert_array(_out.calls).is_equal(["33 ON THE MONITOR"])

func test_refusals() -> void:
	_run([])
	_run(["99"])
	_run(["22"])
	_run(["33"])
	_show.monitor_mode.value = MonitorModel.Mode.STREAM
	_image.decoded = true
	_run(["33"])
	_show.unlocked_modules.value = PackedStringArray()
	_run(["33"])
	var expected := [
		"USAGE: SHOW <ID>",
		"99 UNKNOWN ITEM",
		"22 IS NOT AN IMAGE",
		"33 NOT DECODED. DECODE 33",
		"MONITOR BUSY",
		"IMG MODULE LOCKED",
	]
	assert_array(_out.calls).is_equal(expected)
