extends GdUnitTestSuite

var _popup: AlertPopup
var _alert: Alert

func before_test() -> void:
	_popup = auto_free(AlertPopup.new())
	_popup.alert = ResourceValue.new()
	_popup.focused = BoolValue.new()
	_popup.panel = auto_free(ColorRect.new())
	_popup.body = auto_free(Label.new())
	_alert = Alert.new()
	_alert.title = "NO ACK SENT"
	_alert.explainer = "THE HEARTBEAT NEVER REACHED HERALD."
	add_child(_popup)

func test_hidden_without_an_alert() -> void:
	assert_bool(_popup.panel.visible).is_false()
	assert_bool(_popup.handle_key(KEY_ENTER)).is_false()

func test_shows_the_alert_until_enter() -> void:
	_popup.alert.value = _alert
	assert_bool(_popup.panel.visible).is_true()
	assert_str(_popup.body.text).starts_with(AlertPopup.TRIANGLE)
	assert_str(_popup.body.text).contains("!! NO ACK SENT !!")
	assert_str(_popup.body.text).ends_with("THE HEARTBEAT NEVER REACHED HERALD.")
	assert_bool(_popup.handle_key(KEY_A)).is_true()
	assert_bool(_popup.panel.visible).is_true()
	assert_bool(_popup.handle_key(KEY_ENTER)).is_true()
	assert_object(_popup.alert.value).is_null()
	assert_bool(_popup.panel.visible).is_false()

func test_escape_still_leaves_the_terminal() -> void:
	_popup.alert.value = _alert
	assert_bool(_popup.handle_key(KEY_ESCAPE)).is_false()
	assert_bool(_popup.panel.visible).is_true()

func test_the_shipped_alert_fits_the_box() -> void:
	var model: UplinkModel = load("res://game/data/models/uplink.tres")
	assert_str(model.ack_missed_alert.title).is_equal("NO ACK SENT")
	for line: String in AlertPopup.text_for(model.ack_missed_alert).split("\n"):
		assert_int(line.length()).is_less_equal(40)

func test_each_triangle_row_is_two_wider_so_centring_keeps_it_straight() -> void:
	var rows := AlertPopup.TRIANGLE.split("\n")
	for i: int in range(rows.size()):
		assert_int(rows[i].length()).is_equal(2 * i + 2)
