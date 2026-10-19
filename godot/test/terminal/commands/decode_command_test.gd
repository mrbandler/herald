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
		"USAGE: DECODE <ID>",
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
