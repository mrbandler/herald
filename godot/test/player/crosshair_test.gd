extends GdUnitTestSuite

func test_picks_the_icon_by_state() -> void:
	var crosshair: Crosshair = auto_free(Crosshair.new())
	crosshair.idle_icon = PlaceholderTexture2D.new()
	crosshair.hover_icon = PlaceholderTexture2D.new()
	crosshair.grab_icon = PlaceholderTexture2D.new()
	assert_object(crosshair.pick_icon(false, false)).is_same(crosshair.idle_icon)
	assert_object(crosshair.pick_icon(true, false)).is_same(crosshair.hover_icon)
	assert_object(crosshair.pick_icon(true, true)).is_same(crosshair.grab_icon)
	assert_object(crosshair.pick_icon(false, true)).is_same(crosshair.grab_icon)
