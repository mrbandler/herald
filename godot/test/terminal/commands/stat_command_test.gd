extends GdUnitTestSuite

var _stat: StatCommand
var _out: AtomSpy

func before_test() -> void:
	_stat = StatCommand.new()
	_stat.out = StringEvent.new()
	_stat.download_queue = ResourceListValue.new()
	_stat.download_received = IntValue.new()
	_out = AtomSpy.events(_stat.out)

func test_nothing_running() -> void:
	_stat.run(PackedStringArray())
	assert_array(_out.calls).is_equal(["NO DOWNLOADS"])

func test_running_and_queued() -> void:
	_stat.download_queue.add(DownlinkFixture.item(21, "AUTH", 1, 16))
	_stat.download_queue.add(DownlinkFixture.item(22, "TLM", 1, 32))
	_stat.download_received.value = 10
	_stat.run(PackedStringArray())
	assert_array(_out.calls).is_equal(["RECV 21 AUTH 10/16", "QUEUED 22 TLM"])
