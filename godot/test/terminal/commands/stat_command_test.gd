extends GdUnitTestSuite

var _stat: StatCommand
var _out: AtomSpy

func before_test() -> void:
	_stat = StatCommand.new()
	_stat.out = StringEvent.new()
	_stat.download_queue = ResourceListValue.new()
	_stat.running_item = ResourceValue.new()
	_stat.model = DownlinkModel.new()
	_out = AtomSpy.events(_stat.out)

func test_nothing_running() -> void:
	_stat.run(PackedStringArray())
	assert_array(_out.calls).is_equal(["NO DOWNLOADS"])

func test_running_and_queued() -> void:
	_stat.download_queue.add(DownlinkFixture.item(21, "AUTH", 1, 16))
	_stat.download_queue.add(DownlinkFixture.item(22, "TLM", 1, 32))
	var clean := DownlinkModel.Grade.CLEAN
	var running := DownlinkFixture.stored(_stat.download_queue.value[0] as ManifestItem, [clean])
	running.grades.append(DownlinkModel.Grade.NOISY)
	running.grades.append(DownlinkModel.Grade.LOST)
	_stat.running_item.value = running
	_stat.run(PackedStringArray())
	var expected := ["RECV 21 AUTH 2/16. CLEAN 1 NOISY 1 LOST 1", "QUEUED 22 TLM"]
	assert_array(_out.calls).is_equal(expected)

func test_a_head_not_yet_started_shows_no_rows() -> void:
	_stat.download_queue.add(DownlinkFixture.item(21, "AUTH", 1, 16))
	_stat.run(PackedStringArray())
	assert_array(_out.calls).is_equal(["RECV 21 AUTH 0/16. CLEAN 0 NOISY 0 LOST 0"])
