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

func test_a_sheet_renders_its_markdown_on_a_page_sized_to_the_paper() -> void:
	var sheet: PaperSheet = auto_free(PaperSheet.new())
	sheet.show_paper(Vector2(0.1, 0.2), "# TITLE")
	assert_str(sheet.page.markdown_text).is_equal("# TITLE")
	assert_object(sheet.page_pixels()).is_equal(Vector2i(240, 480))

func test_placeholders_become_glyphs_on_paper() -> void:
	var paper := Paper.new()
	paper.text = "THE {{###}} DAY"
	assert_str(paper.text_for(null)).is_equal("THE ███ DAY")

func test_a_long_text_shrinks_until_it_fits() -> void:
	var sheet: PaperSheet = auto_free(PaperSheet.new())
	add_child(sheet)
	sheet.show_paper(Vector2(0.1, 0.05), "LINE\n".repeat(30))
	for _i: int in range(12):
		await get_tree().process_frame
	assert_int(sheet.font_size).is_less(PaperSheet.FONT_SIZE)
	sheet.show_paper(Vector2(0.1, 0.2), "SHORT")
	for _i: int in range(4):
		await get_tree().process_frame
	assert_int(sheet.font_size).is_equal(PaperSheet.FONT_SIZE)
