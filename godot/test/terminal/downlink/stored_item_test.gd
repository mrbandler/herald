extends GdUnitTestSuite

func _stored(rows: int, grades: Array[int]) -> StoredItem:
	var item := ManifestItem.new()
	item.rows = rows
	var stored := StoredItem.new()
	stored.item = item
	stored.grades = PackedByteArray(grades)
	return stored

func test_counts_rows_by_grade() -> void:
	var clean := DownlinkModel.Grade.CLEAN
	var noisy := DownlinkModel.Grade.NOISY
	var lost := DownlinkModel.Grade.LOST
	var stored := _stored(4, [clean, noisy, lost, clean])
	assert_int(stored.sent()).is_equal(4)
	assert_int(stored.clean()).is_equal(2)
	assert_int(stored.noisy()).is_equal(1)
	assert_int(stored.lost()).is_equal(1)
	assert_int(stored.arrived()).is_equal(3)

func test_a_partial_counts_only_what_was_sent() -> void:
	var stored := _stored(16, [DownlinkModel.Grade.CLEAN, DownlinkModel.Grade.NOISY])
	assert_int(stored.sent()).is_equal(2)
	assert_int(stored.arrived()).is_equal(2)
	assert_int(stored.lost()).is_equal(0)
