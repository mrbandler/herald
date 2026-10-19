extends GdUnitTestSuite

var _store: StoreCommand
var _out: AtomSpy

func before_test() -> void:
	_store = StoreCommand.new()
	_store.out = StringEvent.new()
	_store.model = DownlinkModel.new()
	_store.storage = ResourceListValue.new()
	_out = AtomSpy.events(_store.out)

func test_empty_storage() -> void:
	_store.run(PackedStringArray())
	assert_array(_out.calls).is_equal(["STORAGE 0/8"])

func test_lists_full_and_partial_items() -> void:
	var clean := DownlinkModel.Grade.CLEAN
	var full: Array[int] = []
	full.resize(16)
	full.fill(clean)
	var auth := DownlinkFixture.item(21, "AUTH", 1, 16)
	var tlm := DownlinkFixture.item(22, "TLM", 1, 32)
	_store.storage.add(DownlinkFixture.stored(auth, full))
	_store.storage.add(DownlinkFixture.stored(tlm, [clean, DownlinkModel.Grade.NOISY]))
	_store.run(PackedStringArray())
	var expected := [
		"STORAGE 2/8",
		" ID   TYPE  SIZE  ROWS   CLEAN NOISY LOST",
		" 21   AUTH  1     16/16  16    0     0",
		" 22   TLM   1     2/32   1     1     0",
	]
	assert_array(_out.calls).is_equal(expected)

func test_shows_a_tag_under_its_item() -> void:
	var tlm := DownlinkFixture.stored(DownlinkFixture.item(22, "TLM", 1, 2), [0, 0])
	tlm.tag = "FIRST TLM"
	_store.storage.add(tlm)
	_store.run(PackedStringArray())
	assert_str(_out.calls[-1]).is_equal("      TAG: FIRST TLM")

func test_a_decoded_image_shows_one_unit_and_is_marked() -> void:
	var image := DownlinkFixture.stored(DownlinkFixture.item(33, "IMG", 6, 2), [0, 0])
	image.decoded = true
	_store.storage.add(image)
	_store.run(PackedStringArray())
	assert_array(_out.calls).is_equal(
		[
			"STORAGE 1/8",
			" ID   TYPE  SIZE  ROWS   CLEAN NOISY LOST",
			" 33   IMG   1     2/2    2     0     0",
			"      DECODED",
		]
	)
