extends GdUnitTestSuite

func _stored(type: String, note: String, decoded: bool) -> StoredItem:
	var stored := StoredItem.new()
	stored.item = ManifestItem.new()
	stored.item.type = type
	stored.item.note = note
	stored.decoded = decoded
	return stored

func test_picks_the_ending_from_the_verdict_and_the_evidence() -> void:
	var model: EndingModel = load("res://game/data/models/ending.tres")
	var face := _stored("IMG", "CANDRA NARROW", true)
	var air := _stored("SPC", "CANDRA", false)
	var both: Array[Resource] = [face, air]
	var raw: Array[Resource] = [_stored("IMG", "CANDRA NARROW", false), air]
	var none: Array[Resource] = []
	var descend := PackedStringArray(["ACK", "DESCEND"])
	assert_str(model.pick(descend, both)[0]).is_equal(model.ark_title)
	assert_str(model.pick(descend, raw)[0]).is_equal(model.blind_title)
	assert_str(model.pick(PackedStringArray(["TRANSFER"]), both)[0]).is_equal(model.transfer_title)
	assert_str(model.pick(PackedStringArray(["ACK"]), none)[0]).is_equal(model.silence_title)
	assert_str(model.ark_text).is_not_empty()
