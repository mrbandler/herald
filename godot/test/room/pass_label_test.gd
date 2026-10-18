extends GdUnitTestSuite

var _label: PassLabel

func before_test() -> void:
	_label = auto_free(PassLabel.new())
	_label.current_pass = ResourceValue.new()
	_label.current_pass.value = PassFixture.window_one()
	_label.fields = PackedStringArray(["card_azimuth", "card_elevation", "card_tuning"])
	_label.format = "AZ %05.1f EL %04.1f DIAL %.0f"
	add_child(_label)

func test_formats_the_window_fields() -> void:
	assert_str(_label.text).is_equal("AZ 214.6 EL 38.2 DIAL 52")
	assert_bool(_label.visible).is_true()

func test_redraws_when_the_window_changes() -> void:
	var other := PassFixture.window_one()
	other.card_azimuth = 99.5
	_label.current_pass.value = other
	assert_str(_label.text).is_equal("AZ 099.5 EL 38.2 DIAL 52")

func test_hides_without_a_window() -> void:
	_label.current_pass.value = null
	assert_str(_label.text).is_empty()
	assert_bool(_label.visible).is_false()

func test_hides_an_empty_text() -> void:
	_label.fields = PackedStringArray(["letter"])
	_label.format = "%s"
	_label.refresh()
	assert_bool(_label.visible).is_false()
