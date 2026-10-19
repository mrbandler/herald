extends GdUnitTestSuite

var _popup: AlertPopup

func before_test() -> void:
	_popup = auto_free(AlertPopup.new())
	_popup.alert = StringValue.new()
	_popup.focused = BoolValue.new()
	_popup.panel = auto_free(ColorRect.new())
	_popup.body = auto_free(Label.new())
	add_child(_popup)

func test_hidden_without_an_alert() -> void:
	assert_bool(_popup.panel.visible).is_false()
	assert_bool(_popup.handle_key(KEY_ENTER)).is_false()

func test_shows_the_alert_until_enter() -> void:
	_popup.alert.value = "!! NO ACK SENT !!"
	assert_bool(_popup.panel.visible).is_true()
	assert_str(_popup.body.text).is_equal("!! NO ACK SENT !!")
	assert_bool(_popup.handle_key(KEY_A)).is_true()
	assert_bool(_popup.panel.visible).is_true()
	assert_bool(_popup.handle_key(KEY_ENTER)).is_true()
	assert_str(_popup.alert.value).is_empty()
	assert_bool(_popup.panel.visible).is_false()

func test_escape_still_leaves_the_terminal() -> void:
	_popup.alert.value = "!! NO ACK SENT !!"
	assert_bool(_popup.handle_key(KEY_ESCAPE)).is_false()
	assert_bool(_popup.panel.visible).is_true()
