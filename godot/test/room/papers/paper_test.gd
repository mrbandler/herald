extends GdUnitTestSuite

func test_plain_text_stays_as_written() -> void:
	var paper := Paper.new()
	paper.text = "HELLO"
	assert_str(paper.text_for(PassFixture.window_one())).is_equal("HELLO")

func test_fields_fill_the_text_from_the_window() -> void:
	var paper := Paper.new()
	paper.text = "AZ %05.1f  EL %04.1f\nBIND IT AT DIAL %.0f"
	paper.fields = PackedStringArray(["card_azimuth", "card_elevation", "card_tuning"])
	var text := paper.text_for(PassFixture.window_one())
	assert_str(text).is_equal("AZ 214.6  EL 38.2\nBIND IT AT DIAL 52")

func test_a_sheet_starts_its_text_at_the_top_left_margin() -> void:
	var sheet: PaperSheet = auto_free(PaperSheet.new())
	sheet.show_paper(Vector2(0.1, 0.2), "TEXT")
	var top_left := Vector3(PaperSheet.MARGIN - 0.05, 0.1 - PaperSheet.MARGIN, 0.0005)
	assert_vector(sheet.label.position).is_equal_approx(top_left, Vector3.ONE * 0.00001)
	sheet.unlit()
	assert_bool(sheet.label.shaded).is_false()
