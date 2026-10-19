extends GdUnitTestSuite

var _manifest: ManifestCommand
var _out: AtomSpy

func before_test() -> void:
	_manifest = ManifestCommand.new()
	_manifest.out = StringEvent.new()
	_manifest.manifest_received = BoolValue.new()
	var listed: Array[Resource] = [
		DownlinkFixture.item(21, "AUTH", 1, 16, "PHASE 2"),
		DownlinkFixture.item(22, "TLM", 1, 32, "AUTO"),
	]
	listed.append(DownlinkFixture.item(23, "IMG", 6, 4))
	listed.append(DownlinkFixture.item(24, "TLM", 1, 2))
	_manifest.manifest = DownlinkFixture.list(listed)
	_manifest.download_queue = ResourceListValue.new()
	_manifest.storage = ResourceListValue.new()
	_manifest.model = DownlinkModel.new()
	_manifest.manifest_seen = BoolValue.new()
	_out = AtomSpy.events(_manifest.out)

func test_no_manifest_before_the_push() -> void:
	_manifest.run(PackedStringArray())
	assert_array(_out.calls).is_equal(["NO MANIFEST"])
	assert_bool(_manifest.manifest_seen.value).is_false()
	_manifest.manifest_received.value = true
	_manifest.run(PackedStringArray())
	assert_bool(_manifest.manifest_seen.value).is_true()

func test_prints_the_list_with_each_items_state() -> void:
	_manifest.manifest_received.value = true
	var clean := DownlinkModel.Grade.CLEAN
	var items := _manifest.manifest.value
	_manifest.storage.add(DownlinkFixture.stored(items[0] as ManifestItem, []))
	_manifest.storage.add(DownlinkFixture.stored(items[3] as ManifestItem, [clean, clean]))
	_manifest.download_queue.add(items[2])
	_manifest.run(PackedStringArray())
	var expected := [
		" HERALD QUEUE - 4 ITEMS",
		" ID   TYPE  SIZE  STATE    NOTE",
		" 21   AUTH  1     DAMAGED  PHASE 2",
		" 22   TLM   1     NONE     AUTO",
		" 23   IMG   6     QUEUED",
		" 24   TLM   1     STORED",
	]
	assert_array(_out.calls).is_equal(expected)
