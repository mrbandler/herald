extends GdUnitTestSuite

var _del: DelCommand
var _out: AtomSpy

func before_test() -> void:
	_del = DelCommand.new()
	_del.out = StringEvent.new()
	_del.model = DownlinkModel.new()
	_del.storage = ResourceListValue.new()
	_del.storage.add(DownlinkFixture.stored(DownlinkFixture.item(21, "AUTH", 1, 16), []))
	_out = AtomSpy.events(_del.out)

func test_usage_without_an_id() -> void:
	_del.run(PackedStringArray())
	assert_array(_out.calls).is_equal(["USAGE: DEL <ID>"])

func test_unknown_item() -> void:
	_del.run(PackedStringArray(["99"]))
	assert_array(_out.calls).is_equal(["99 UNKNOWN ITEM"])

func test_deletes_and_reports_the_free_space() -> void:
	_del.run(PackedStringArray(["21"]))
	assert_array(_out.calls).is_equal(["21 DELETED. FREE 8."])
	assert_int(_del.storage.value.size()).is_equal(0)
