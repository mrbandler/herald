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
	crosshair.place_icon = PlaceholderTexture2D.new()
	assert_object(crosshair.pick_icon(true, false, true)).is_same(crosshair.place_icon)

func test_hides_at_a_full_lean() -> void:
	var crosshair: Crosshair = auto_free(Crosshair.new())
	assert_bool(crosshair.shown(0.0, false)).is_true()
	assert_bool(crosshair.shown(0.9, false)).is_true()
	assert_bool(crosshair.shown(1.0, false)).is_false()
	assert_bool(crosshair.shown(0.0, true)).is_false()
