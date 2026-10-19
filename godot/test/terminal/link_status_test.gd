extends GdUnitTestSuite

var _status: LinkStatus

func before_test() -> void:
	_status = auto_free(LinkStatus.new())
	_status.pass_time = FloatValue.new()
	_status.current_pass = ResourceValue.new()
	_status.current_pass.value = PassFixture.window_one()
	_status.signal_strength = FloatValue.new()
	_status.locked = BoolValue.new()
	_status.uplink_open = BoolValue.new()
	_status.transmitting = BoolValue.new()

func test_no_carrier_before_the_signal_rises() -> void:
	assert_int(_status.mode()).is_equal(LinkStatus.Mode.NO_CARRIER)

func test_signal_without_lock() -> void:
	_status.signal_strength.value = 0.3
	assert_int(_status.mode()).is_equal(LinkStatus.Mode.NO_LOCK)

func test_lock_before_the_uplink_is_the_downlink() -> void:
	_status.pass_time.value = 40.0
	_status.signal_strength.value = 0.8
	_status.locked.value = true
	assert_int(_status.mode()).is_equal(LinkStatus.Mode.DOWNLINK)

func test_lock_while_the_uplink_is_open() -> void:
	_status.locked.value = true
	_status.uplink_open.value = true
	assert_int(_status.mode()).is_equal(LinkStatus.Mode.UPLINK)
	_status.transmitting.value = true
	assert_int(_status.mode()).is_equal(LinkStatus.Mode.TRANSMITTING)

func test_los_wins_after_los() -> void:
	_status.pass_time.value = 120.0
	_status.signal_strength.value = 0.5
	assert_int(_status.mode()).is_equal(LinkStatus.Mode.LOS)

func test_shows_the_text_of_the_mode() -> void:
	_status.locked.value = true
	_status.refresh()
	assert_str(_status.text).is_equal(_status.downlink_text)

func test_a_notice_replaces_the_mode_until_it_expires() -> void:
	_status.status_notice = StringEvent.new()
	add_child(_status)
	_status.pass_time.value = 120.0
	_status.status_notice.raise("MANIFEST RECEIVED. 2 ITEMS")
	assert_str(_status.text).is_equal("MANIFEST RECEIVED. 2 ITEMS")
	_status.tick(3.9)
	assert_str(_status.text).is_equal("MANIFEST RECEIVED. 2 ITEMS")
	_status.tick(0.2)
	assert_str(_status.text).is_equal(_status.los_text)

func test_a_new_notice_restarts_the_timer() -> void:
	_status.status_notice = StringEvent.new()
	add_child(_status)
	_status.status_notice.raise("21 RECEIVED 16/16")
	_status.tick(3.0)
	_status.status_notice.raise("22 RECEIVED 32/32")
	_status.tick(3.0)
	assert_str(_status.text).is_equal("22 RECEIVED 32/32")

func test_a_held_link_lights_the_band() -> void:
	_status.band = auto_free(ColorRect.new())
	_status.locked.value = true
	_status.refresh()
	assert_object(_status.band.color).is_equal(_status.lit_color)
	assert_object(_status.get_theme_color("font_color")).is_equal(_status.ink_color)

func test_no_lock_darkens_the_band_and_no_carrier_dims_the_text() -> void:
	_status.band = auto_free(ColorRect.new())
	_status.signal_strength.value = 0.3
	_status.refresh()
	assert_object(_status.band.color).is_equal(_status.dark_color)
	assert_object(_status.get_theme_color("font_color")).is_equal(_status.lit_color)
	_status.signal_strength.value = 0.0
	_status.tick(0.0)
	_status.tick(2.0)
	assert_object(_status.get_theme_color("font_color")).is_equal(_status.dim_color)

func test_a_mode_change_blinks_the_band() -> void:
	_status.band = auto_free(ColorRect.new())
	_status.refresh()
	assert_object(_status.band.color).is_equal(_status.dark_color)
	_status.locked.value = true
	_status.tick(0.0)
	assert_object(_status.band.color).is_equal(_status.ink_color)
	assert_object(_status.get_theme_color("font_color")).is_equal(_status.lit_color)
	_status.tick(0.2)
	assert_object(_status.band.color).is_equal(_status.lit_color)
	_status.tick(0.15)
	assert_object(_status.band.color).is_equal(_status.ink_color)
	_status.tick(1.0)
	assert_object(_status.band.color).is_equal(_status.lit_color)

func test_counts_down_to_the_next_mark_in_the_text_colour() -> void:
	_status.countdown = auto_free(Label.new())
	_status.locked.value = true
	_status.pass_time.value = 40.0
	_status.refresh()
	var mark := PassFixture.window_one().next_mark(40.0)
	assert_str(_status.countdown.text).is_equal(mark.countdown())
	assert_object(_status.countdown.get_theme_color("font_color")).is_equal(_status.ink_color)

func test_shows_the_station_time_after_los_instead_of_the_bell() -> void:
	_status.countdown = auto_free(Label.new())
	_status.pass_time.value = 125.0
	_status.refresh()
	assert_str(_status.countdown.text).is_equal("02:42:05")
