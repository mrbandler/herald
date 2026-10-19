extends GdUnitTestSuite

func test_average_of_a_half_lit_screen() -> void:
	var image := Image.create(64, 48, false, Image.FORMAT_RGBA8)
	image.fill_rect(Rect2i(0, 0, 32, 48), Color(1.0, 0.6, 0.2))
	var colour := ScreenGlow.average(image)
	assert_float(colour.r).is_equal_approx(0.5, 0.01)
	assert_float(colour.g).is_equal_approx(0.3, 0.01)

func test_shines_in_the_hue_and_as_bright_as_the_screen() -> void:
	var glow: ScreenGlow = auto_free(ScreenGlow.new())
	glow.shine(Color(0.5, 0.25, 0.0))
	assert_float(glow.light_color.r).is_equal_approx(1.0, 0.001)
	assert_float(glow.light_color.g).is_equal_approx(0.5, 0.001)
	assert_float(glow.light_energy).is_greater(0.0)
	glow.shine(Color.BLACK)
	assert_float(glow.light_energy).is_equal(0.0)
