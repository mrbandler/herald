extends GdUnitTestSuite

func test_placeholders_become_glyphs_one_per_character() -> void:
	var text := "MET ON THE {{####}} DAY. AIR WAS {{~~~}}, {{#}}"
	assert_str(TextGlyphs.patch(text)).is_equal("MET ON THE ████ DAY. AIR WAS ▒▒▒, █")

func test_text_without_placeholders_stays() -> void:
	assert_str(TextGlyphs.patch("{{ MIXED #~ }} {{}}")).is_equal("{{ MIXED #~ }} {{}}")
