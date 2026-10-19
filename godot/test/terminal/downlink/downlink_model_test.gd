extends GdUnitTestSuite

var _model := DownlinkModel.new()

func _item(id: int, type: String, size: int, rows: int) -> ManifestItem:
	var item := ManifestItem.new()
	item.id = id
	item.type = type
	item.size = size
	item.rows = rows
	return item

func _stored(item: ManifestItem) -> StoredItem:
	var stored := StoredItem.new()
	stored.item = item
	return stored

func test_grades_by_lock_and_margin() -> void:
	assert_int(_model.grade(false, 1.0, 0.6)).is_equal(DownlinkModel.Grade.LOST)
	assert_int(_model.grade(true, 0.59, 0.6)).is_equal(DownlinkModel.Grade.NOISY)
	assert_int(_model.grade(true, 0.6, 0.6)).is_equal(DownlinkModel.Grade.CLEAN)

func test_time_scales_with_size() -> void:
	assert_float(_model.seconds_for(_item(21, "AUTH", 1, 16))).is_equal(15.0)
	assert_float(_model.seconds_for(_item(23, "IMG", 6, 480))).is_equal(90.0)

func test_the_longest_progress_line_fills_the_row_beside_the_storage() -> void:
	var model: DownlinkModel = load("res://game/data/models/downlink.tres")
	var terminal: TerminalModel = load("res://game/data/models/terminal.tres")
	var line := model.item_line(_item(123, "AUTH", 1, 480), 240, 480)
	var gap_and_readout := "  STORAGE 14/14"
	assert_int(line.length() + gap_and_readout.length()).is_equal(terminal.columns)

func test_merged_keeps_each_rows_better_grade() -> void:
	var item := _item(21, "AUTH", 1, 4)
	var clean := DownlinkModel.Grade.CLEAN
	var noisy := DownlinkModel.Grade.NOISY
	var lost := DownlinkModel.Grade.LOST
	var kept := DownlinkFixture.stored(item, [clean, lost, noisy])
	kept.tag = "KEY"
	var again := DownlinkFixture.stored(item, [noisy, clean, lost, clean])
	var best := _model.merged(kept, again)
	assert_array(Array(best.grades)).is_equal([clean, clean, noisy, clean])
	assert_str(best.tag).is_equal("KEY")
	assert_array(Array(kept.grades)).is_equal([clean, lost, noisy])

func test_rows_arrive_one_interval_after_another() -> void:
	var item := _item(21, "AUTH", 1, 16)
	assert_int(_model.rows_due(item, 0.0)).is_equal(0)
	assert_int(_model.rows_due(item, 0.9)).is_equal(0)
	assert_int(_model.rows_due(item, 0.9375)).is_equal(1)
	assert_int(_model.rows_due(item, 15.0)).is_equal(16)
	assert_int(_model.rows_due(item, 99.0)).is_equal(16)
	assert_int(_model.rows_due(item, -1.0)).is_equal(0)

func test_progress_lines_and_notices() -> void:
	assert_str(_model.bar(0.6)).is_equal("[######----]")
	var auth := _item(21, "AUTH", 1, 16)
	assert_str(_model.item_line(auth, 10, 9)).is_equal("RECV 21 AUTH [######----] 9/16")
	assert_str(_model.manifest_line(0.5)).is_equal("RECV MANIFEST [#####-----]")
	var stored := _stored(auth)
	stored.grades = PackedByteArray([0, 0, 1, 2])
	var counts := "CLEAN 2 NOISY 1 LOST 1"
	assert_str(_model.received_notice(stored)).is_equal("21 RECEIVED 3/16. " + counts)
	assert_str(_model.cut_notice(stored)).is_equal("21 CUT 3/16. " + counts)

func test_units_and_lookups() -> void:
	var auth := _item(21, "AUTH", 1, 16)
	var image := _item(23, "IMG", 6, 480)
	var listed: Array[Resource] = [auth, image]
	var stored: Array[Resource] = [_stored(image)]
	assert_int(_model.units(listed)).is_equal(7)
	assert_int(_model.units(stored)).is_equal(6)
	assert_object(_model.listed(listed, "23")).is_same(image)
	assert_object(_model.listed(listed, "ABC")).is_null()
	assert_object(_model.stored(stored, "23").item).is_same(image)
	assert_object(_model.stored(stored, "21")).is_null()
