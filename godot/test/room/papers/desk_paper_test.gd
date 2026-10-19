extends GdUnitTestSuite

var _reading: ResourceValue
var _put_down: Event

func _sheet(text: String) -> DeskPaper:
	var paper := Paper.new()
	paper.text = text
	var sheet: DeskPaper = auto_free(DeskPaper.new())
	sheet.paper = paper
	sheet.current_pass = ResourceValue.new()
	sheet.reading = _reading
	sheet.put_down = _put_down
	add_child(sheet)
	return sheet

func before_test() -> void:
	_reading = ResourceValue.new()
	_put_down = Event.new()

func test_grab_lifts_it_and_it_hides_until_put_back() -> void:
	var letter := _sheet("LETTER")
	letter.grab()
	assert_object(_reading.value).is_same(letter.paper)
	assert_bool(letter.visible).is_false()
	_reading.value = null
	assert_bool(letter.visible).is_true()

func test_grabbing_another_swaps_them() -> void:
	var letter := _sheet("LETTER")
	var card := _sheet("CARD")
	card.position = Vector3(1.0, 0.0, 0.0)
	letter.grab()
	card.grab()
	assert_object(_reading.value).is_same(card.paper)
	assert_vector(letter.position).is_equal(Vector3(1.0, DeskPaper.SWAP_LIFT, 0.0))
	assert_bool(letter.visible).is_true()
	assert_bool(card.visible).is_false()

func test_put_down_moves_only_the_paper_in_hand() -> void:
	var letter := _sheet("LETTER")
	var card := _sheet("CARD")
	letter.grab()
	_put_down.raise(Transform3D(Basis.IDENTITY, Vector3(0.0, 0.0, 2.0)))
	assert_vector(letter.position).is_equal(Vector3(0.0, 0.0, 2.0))
	assert_vector(card.position).is_equal(Vector3.ZERO)
