extends GdUnitTestSuite

var _vrfy: VrfyCommand
var _out: AtomSpy

func before_test() -> void:
	_vrfy = VrfyCommand.new()
	_vrfy.out = StringEvent.new()
	_vrfy.module_model = ModuleModel.new()
	_vrfy.downlink_model = DownlinkModel.new()
	_vrfy.storage = ResourceListValue.new()
	_out = AtomSpy.events(_vrfy.out)

func _key(grades: Array[int]) -> StoredItem:
	var item := DownlinkFixture.item(21, "AUTH", 1, 4)
	item.key_for = "TLM"
	return DownlinkFixture.stored(item, grades)

func test_usage_and_unknown() -> void:
	_vrfy.run(PackedStringArray())
	_vrfy.run(PackedStringArray(["99"]))
	assert_array(_out.calls).is_equal(["USAGE: VRFY <ID>", "99 UNKNOWN ITEM"])

func test_a_valid_key() -> void:
	var clean := DownlinkModel.Grade.CLEAN
	_vrfy.storage.add(_key([clean, clean, DownlinkModel.Grade.NOISY, clean]))
	_vrfy.run(PackedStringArray(["21"]))
	var expected := [" 21 AUTH  ROWS 4/4  CLEAN 3 NOISY 1 LOST 0", " KEY FOR TLM. VALID"]
	assert_array(_out.calls).is_equal(expected)

func test_an_invalid_key() -> void:
	_vrfy.storage.add(_key([DownlinkModel.Grade.CLEAN, DownlinkModel.Grade.LOST]))
	_vrfy.run(PackedStringArray(["21"]))
	assert_str(_out.calls[1]).is_equal(" KEY FOR TLM. INVALID. 3 ROWS MISSING")

func test_a_tagged_text_item() -> void:
	var tlm := DownlinkFixture.stored(DownlinkFixture.item(22, "TLM", 1, 2), [0, 0])
	tlm.tag = "FIRST TLM"
	_vrfy.storage.add(tlm)
	_vrfy.run(PackedStringArray(["22"]))
	var expected := [" 22 TLM  ROWS 2/2  CLEAN 2 NOISY 0 LOST 0", " TAG: FIRST TLM"]
	assert_array(_out.calls).is_equal(expected)

func test_a_decoded_image_says_so() -> void:
	var image := DownlinkFixture.stored(DownlinkFixture.item(33, "IMG", 6, 2), [0, 0])
	image.decoded = true
	_vrfy.storage.add(image)
	_vrfy.run(PackedStringArray(["33"]))
	assert_array(_out.calls).is_equal([" 33 IMG  ROWS 2/2  CLEAN 2 NOISY 0 LOST 0", " DECODED"])
