extends GdUnitTestSuite

var _get: GetCommand
var _out: AtomSpy

func before_test() -> void:
	_get = GetCommand.new()
	_get.out = StringEvent.new()
	_get.model = DownlinkModel.new()
	_get.downlink_open = BoolValue.new()
	_get.locked = BoolValue.new()
	_get.manifest_received = BoolValue.new()
	var listed: Array[Resource] = [
		DownlinkFixture.item(21, "AUTH", 1, 16),
		DownlinkFixture.item(22, "TLM", 1, 32),
		DownlinkFixture.item(23, "IMG", 6, 480),
	]
	_get.manifest = DownlinkFixture.list(listed)
	_get.download_queue = ResourceListValue.new()
	_get.storage = ResourceListValue.new()
	_out = AtomSpy.events(_get.out)

func _ready_to_get() -> void:
	_get.downlink_open.value = true
	_get.locked.value = true
	_get.manifest_received.value = true

func test_usage_without_ids() -> void:
	_get.run(PackedStringArray())
	assert_array(_out.calls).is_equal(["USAGE: GET <ID>[, <ID>]"])

func test_refuses_outside_the_downlink_without_lock_or_manifest() -> void:
	_get.run(PackedStringArray(["21"]))
	_get.downlink_open.value = true
	_get.run(PackedStringArray(["21"]))
	_get.locked.value = true
	_get.run(PackedStringArray(["21"]))
	assert_array(_out.calls).is_equal(["DOWNLINK CLOSED", "NO SIGNAL LOCK", "NO MANIFEST"])

func test_queues_several_items() -> void:
	_ready_to_get()
	_get.run(PackedStringArray(["21", "22"]))
	assert_array(_out.calls).is_equal(["21 QUEUED", "22 QUEUED"])
	assert_int(_get.download_queue.value.size()).is_equal(2)

func test_refuses_unknown_queued_and_stored_items() -> void:
	_ready_to_get()
	var auth := _get.manifest.value[0] as ManifestItem
	var clean: Array[int] = []
	clean.resize(16)
	clean.fill(DownlinkModel.Grade.CLEAN)
	_get.storage.add(DownlinkFixture.stored(auth, clean))
	_get.run(PackedStringArray(["ABC", "99", "21", "22", "22"]))
	var expected := [
		"ABC UNKNOWN ITEM",
		"99 UNKNOWN ITEM",
		"21 ALREADY STORED",
		"22 QUEUED",
		"22 ALREADY QUEUED",
	]
	assert_array(_out.calls).is_equal(expected)

func test_fetches_a_damaged_copy_again_without_extra_space() -> void:
	_ready_to_get()
	var auth := _get.manifest.value[0] as ManifestItem
	_get.storage.add(DownlinkFixture.stored(auth, [DownlinkModel.Grade.LOST]))
	_get.storage.add(DownlinkFixture.stored(_get.manifest.value[2] as ManifestItem, []))
	_get.storage.add(DownlinkFixture.stored(_get.manifest.value[1] as ManifestItem, []))
	_get.run(PackedStringArray(["21"]))
	assert_array(_out.calls).is_equal(["21 QUEUED AGAIN"])
	assert_int(_get.download_queue.value.size()).is_equal(1)

func test_refuses_items_that_do_not_fit() -> void:
	_ready_to_get()
	_get.storage.add(DownlinkFixture.stored(_get.manifest.value[2] as ManifestItem, []))
	_get.manifest.add(DownlinkFixture.item(24, "TLM", 1, 32))
	_get.run(PackedStringArray(["21", "22", "24"]))
	assert_array(_out.calls).is_equal(["21 QUEUED", "22 QUEUED", "24 NOT ENOUGH SPACE"])
