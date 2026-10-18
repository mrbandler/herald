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
	_manifest.manifest = DownlinkFixture.list(listed)
	_out = AtomSpy.events(_manifest.out)

func test_no_manifest_before_the_push() -> void:
	_manifest.run(PackedStringArray())
	assert_array(_out.calls).is_equal(["NO MANIFEST"])

func test_prints_the_received_list() -> void:
	_manifest.manifest_received.value = true
	_manifest.run(PackedStringArray())
	var expected := [
		" HERALD QUEUE - 2 ITEMS",
		" ID   TYPE  SIZE  NOTE",
		" 21   AUTH  1     PHASE 2",
		" 22   TLM   1     AUTO",
	]
	assert_array(_out.calls).is_equal(expected)
