extends GdUnitTestSuite

func _glow() -> MonitorGlow:
	var glow: MonitorGlow = auto_free(MonitorGlow.new())
	glow.shown_item = ResourceValue.new()
	glow.monitor_mode = IntValue.new()
	return glow

func test_snow_without_a_picture() -> void:
	var glow := _glow()
	glow.tick()
	assert_object(glow.light_color).is_equal(glow.snow_color)
	assert_float(glow.light_energy).is_equal_approx(glow.snow_energy, 0.0001)

func test_a_picture_on_show_lights_in_its_colour() -> void:
	var glow := _glow()
	var image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.8))
	var stored := StoredItem.new()
	stored.item = ManifestItem.new()
	stored.item.image = ImageTexture.create_from_image(image)
	glow.shown_item.value = stored
	glow.monitor_mode.value = MonitorModel.Mode.SHOW
	glow.tick()
	assert_float(glow.light_color.b).is_equal_approx(1.0, 0.01)
	assert_float(glow.light_color.r).is_equal_approx(0.0, 0.01)
