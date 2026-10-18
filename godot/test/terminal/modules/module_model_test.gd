extends GdUnitTestSuite

const CLEAN := DownlinkModel.Grade.CLEAN
const NOISY := DownlinkModel.Grade.NOISY
const LOST := DownlinkModel.Grade.LOST

var _model := ModuleModel.new()

func _text(id: int, rows: int, content: String, grades: Array[int]) -> StoredItem:
	var item := DownlinkFixture.item(id, "TLM", 1, rows)
	item.content = content
	return DownlinkFixture.stored(item, grades)

func _key(grades: Array[int]) -> StoredItem:
	var item := DownlinkFixture.item(21, "AUTH", 1, 4)
	item.key_for = "TLM"
	return DownlinkFixture.stored(item, grades)

func _differences(a: String, b: String) -> int:
	var count := 0
	for i: int in range(a.length()):
		if a[i] != b[i]:
			count += 1
	return count

func test_a_key_needs_every_row() -> void:
	assert_bool(_model.is_valid_key(_key([CLEAN, CLEAN, NOISY, CLEAN]))).is_true()
	assert_bool(_model.is_valid_key(_key([CLEAN, LOST, CLEAN, CLEAN]))).is_false()
	assert_bool(_model.is_valid_key(_key([CLEAN, CLEAN]))).is_false()
	assert_bool(_model.is_valid_key(_text(22, 4, "A", [CLEAN, CLEAN, CLEAN, CLEAN]))).is_false()

func test_decoders_and_banners() -> void:
	assert_str(_model.decoder_for("TLM")).is_equal("TLM")
	assert_str(_model.decoder_for("AUTH")).is_empty()
	assert_array(_model.banner("IMG")).is_empty()
	var shipped: ModuleModel = load("res://game/data/models/modules.tres")
	assert_str(shipped.banner("TLM")[0]).is_equal("TLM DECODER V1.4  (C) SOWING PROGRAMME")
	assert_int(shipped.banner("TLM").size()).is_equal(4)

func test_clean_rows_decode_as_written() -> void:
	var grades: Array[int] = [CLEAN, CLEAN, CLEAN, CLEAN, CLEAN, CLEAN, CLEAN, CLEAN]
	var stored := _text(22, 8, "AAAA\nBBBB\nCCCC\nDDDD\n", grades)
	assert_array(_model.decode_lines(stored)).is_equal(
		PackedStringArray(["AAAA", "BBBB", "CCCC", "DDDD"])
	)

func test_lost_noisy_and_unsent_rows_show() -> void:
	var stored := _text(22, 8, "AAAA\nBBBB\nCCCC\nDDDD", [CLEAN, CLEAN, LOST, CLEAN, NOISY, CLEAN])
	var lines := _model.decode_lines(stored)
	assert_str(lines[0]).is_equal("AAAA")
	assert_str(lines[1]).is_equal("▒▒▒▒")
	assert_int(_differences(lines[2], "CCCC")).is_equal(2)
	assert_str(lines[3]).is_equal("▒▒▒▒")

func test_noise_is_seeded_and_skips_spaces() -> void:
	var stored := _text(22, 2, "A B C D E F", [NOISY, NOISY])
	var first := _model.decode_lines(stored)
	assert_array(_model.decode_lines(stored)).is_equal(first)
	for i: int in [1, 3, 5, 7, 9]:
		assert_str(first[0][i]).is_equal(" ")
	assert_int(_differences(first[0], "A B C D E F")).is_equal(4)

func test_more_lines_than_rows_still_cover_a_row_each() -> void:
	var lines := _model.decode_lines(_text(22, 2, "A\nB\nC\nD", [CLEAN, LOST]))
	assert_array(lines).is_equal(PackedStringArray(["A", "B", "▒", "▒"]))

func test_empty_content_and_blank_noisy_lines() -> void:
	assert_array(_model.decode_lines(_text(22, 2, "", [CLEAN, CLEAN]))).is_empty()
	var lines := _model.decode_lines(_text(22, 3, "A\n\nB", [CLEAN, NOISY, CLEAN]))
	assert_str(lines[1]).is_empty()
