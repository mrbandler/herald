extends GdUnitTestSuite

var _held: HeldPaper
var _camera: Node3D

func before_test() -> void:
	_camera = auto_free(Node3D.new())
	_held = HeldPaper.new()
	_held.model = PlayerModel.new()
	_held.reading = ResourceValue.new()
	_held.current_pass = ResourceValue.new()
	_held.lean_amount = FloatValue.new()
	_held.raised = BoolValue.new()
	_camera.add_child(_held)
	add_child(_camera)
	_held.set_process(false)

func _letter() -> Paper:
	var paper := Paper.new()
	paper.text = "THE LETTER"
	return paper

func test_hidden_until_a_paper_is_in_hand() -> void:
	assert_bool(_held.visible).is_false()
	_held.reading.value = _letter()
	assert_bool(_held.visible).is_true()
	_held.reading.value = null
	assert_bool(_held.visible).is_false()
	assert_bool(_held.raised.value).is_false()

func test_centred_when_looking_ahead_and_eased_down_when_looking_down() -> void:
	_held.reading.value = _letter()
	_held.tick(10.0)
	assert_float(_held.lowered).is_equal_approx(0.0, 0.001)
	assert_vector(_held.position).is_equal_approx(Vector3(0.0, 0.0, -0.3), Vector3.ONE * 0.001)
	assert_bool(_held.raised.value).is_true()
	_camera.rotation_degrees.x = -12.0
	_held.tick(10.0)
	assert_float(_held.lowered).is_between(0.2, 0.8)
	_camera.rotation_degrees.x = -30.0
	_held.tick(10.0)
	assert_float(_held.lowered).is_equal_approx(1.0, 0.001)
	assert_bool(_held.raised.value).is_false()
	var lowered := _held.model.paper_lowered_offset
	assert_vector(_held.position).is_equal_approx(lowered, Vector3.ONE * 0.001)

func test_a_picked_up_paper_rises_from_below_and_trails_the_look() -> void:
	_held.reading.value = _letter()
	assert_float(_held.lowered).is_equal(1.0)
	_held.tick(0.05)
	assert_float(_held.lowered).is_between(0.4, 0.9)

func test_leaning_in_lowers_it() -> void:
	_held.reading.value = _letter()
	_held.lean_amount.value = 0.5
	_held.tick(10.0)
	assert_float(_held.lowered).is_equal_approx(1.0, 0.001)

func test_looking_up_dips_the_paper_straight_down() -> void:
	_held.reading.value = _letter()
	_camera.rotation_degrees.x = 20.0
	_held.tick(10.0)
	assert_float(_held.lowered).is_equal_approx(0.0, 0.001)
	assert_bool(_held.raised.value).is_false()
	var dipped := Vector3(0.0, -_held.model.paper_dip_drop, -_held.model.paper_distance)
	assert_vector(_held.position).is_equal_approx(dipped, Vector3.ONE * 0.001)
