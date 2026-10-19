extends GdUnitTestSuite

var _decode: DecodeCommand
var _out: AtomSpy

func before_test() -> void:
	_decode = DecodeCommand.new()
	_decode.out = StringEvent.new()
	_decode.module_model = ModuleModel.new()
	_decode.downlink_model = DownlinkModel.new()
	_decode.storage = ResourceListValue.new()
	_decode.unlocked_modules = StringListValue.new()
	var tlm := DownlinkFixture.item(22, "TLM", 1, 2)
	tlm.content = "HELLO\nWORLD"
	_decode.storage.add(DownlinkFixture.stored(tlm, [0, 0]))
	_decode.storage.add(DownlinkFixture.stored(DownlinkFixture.item(21, "AUTH", 1, 2), [0, 0]))
	_decode.storage.add(DownlinkFixture.stored(DownlinkFixture.item(30, "CAL", 1, 2), [0, 0]))
	_decode.storage.add(DownlinkFixture.stored(DownlinkFixture.item(31, "TLM", 1, 2), [0, 0]))
	_out = AtomSpy.events(_decode.out)

func _run(words: Array[String]) -> void:
	_decode.run(PackedStringArray(words))

func test_refusals_in_order() -> void:
	_run([])
	_run(["99"])
	_run(["21"])
	_run(["30"])
	_run(["22"])
	var expected := [
		"USAGE: DECODE <ID> [CAL <ID>]",
		"99 UNKNOWN ITEM",
		"21 IS AN AUTH BLOCK. USE UNLOCK",
		"NO DECODER FOR CAL",
		"TLM MODULE LOCKED",
	]
	assert_array(_out.calls).is_equal(expected)

func test_prints_the_decoded_lines() -> void:
	_decode.unlocked_modules.value = PackedStringArray(["TLM"])
	_run(["22"])
	_run(["31"])
	assert_array(_out.calls).is_equal([" HELLO", " WORLD", "31 NO TEXT"])

func _monitor() -> StoredItem:
	_decode.module_model.modules = PackedStringArray(["TLM", "IMG"])
	_decode.unlocked_modules.value = PackedStringArray(["IMG"])
	_decode.monitor_model = MonitorModel.new()
	_decode.shown_item = ResourceValue.new()
	_decode.monitor_mode = IntValue.new()
	_decode.knob_line = FloatValue.new()
	_decode.knob_offset = FloatValue.new()
	_decode.knob_contrast = FloatValue.new()
	var image := DownlinkFixture.stored(DownlinkFixture.item(33, "IMG", 6, 2), [0, 0])
	_decode.storage.add(image)
	return image

func test_an_image_goes_on_the_monitor_to_tune() -> void:
	var image := _monitor()
	_run(["33"])
	assert_object(_decode.shown_item.value).is_same(image)
	assert_int(_decode.monitor_mode.value).is_equal(MonitorModel.Mode.TUNE)
	assert_array(_out.calls).is_equal(["TUNE THE MONITOR. COMMIT TO DECODE"])

func test_a_raw_image_keeps_the_knobs_where_they_are() -> void:
	_monitor()
	_decode.knob_line.value = 103.4
	_run(["33"])
	assert_float(_decode.knob_line.value).is_equal(103.4)

func test_a_cal_presets_the_knobs_roughly() -> void:
	var image := _monitor()
	image.item.phase = 0.37
	var cal := DownlinkFixture.item(32, "CAL", 1, 2)
	cal.line_length = 103.4
	_decode.storage.add(DownlinkFixture.stored(cal, [0, 0]))
	_decode.knob_contrast.value = 0.7
	_run(["33", "CAL", "32"])
	var model := _decode.monitor_model
	assert_float(_decode.knob_line.value).is_equal_approx(103.4 + model.cal_line_error, 0.0001)
	assert_float(_decode.knob_offset.value).is_equal_approx(0.37 + model.cal_offset_error, 0.0001)
	assert_float(_decode.knob_contrast.value).is_equal(0.7)
	assert_int(_decode.monitor_mode.value).is_equal(MonitorModel.Mode.TUNE)

func test_cal_refusals() -> void:
	_monitor()
	_decode.unlocked_modules.value = PackedStringArray(["IMG", "TLM"])
	_run(["33", "CAL"])
	_run(["33", "CAL", "99"])
	_run(["33", "CAL", "22"])
	_run(["22", "CAL", "30"])
	var expected := [
		"USAGE: DECODE <ID> [CAL <ID>]",
		"99 UNKNOWN ITEM",
		"22 IS NOT A CAL",
		"22 IS NOT AN IMAGE",
	]
	assert_array(_out.calls).is_equal(expected)
	assert_object(_decode.shown_item.value).is_null()

func test_a_decoded_image_starts_from_its_tuning() -> void:
	var image := _monitor()
	image.decoded = true
	image.tuning = Vector3(99.0, 0.3, 0.7)
	_run(["33"])
	assert_float(_decode.knob_offset.value).is_equal_approx(0.3, 0.0001)
	assert_float(_decode.knob_contrast.value).is_equal_approx(0.7, 0.0001)

func test_a_streaming_monitor_is_busy() -> void:
	_monitor()
	_decode.monitor_mode.value = MonitorModel.Mode.STREAM
	_run(["33"])
	assert_array(_out.calls).is_equal(["MONITOR BUSY"])
	assert_object(_decode.shown_item.value).is_null()
