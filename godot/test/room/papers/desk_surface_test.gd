extends GdUnitTestSuite

var _surface: DeskSurface
var _put: Array[Transform3D] = []

func _on_put(at: Variant) -> void:
	var placed: Transform3D = at
	_put.append(placed)

func before_test() -> void:
	_put.clear()
	_surface = auto_free(DeskSurface.new())
	_surface.reading = ResourceValue.new()
	_surface.aim_point = Vector3Value.new()
	_surface.put_down = Event.new()
	_surface.put_down.raised.connect(_on_put)
	_surface.shape = CollisionShape3D.new()
	_surface.add_child(_surface.shape)
	add_child(_surface)

func test_is_a_placement() -> void:
	assert_bool(_surface.is_placement()).is_true()
	var plain: Interactable = auto_free(Interactable.new())
	assert_bool(plain.is_placement()).is_false()

func test_takes_clicks_only_with_a_paper_in_hand() -> void:
	assert_bool(_surface.shape.disabled).is_true()
	_surface.reading.value = Paper.new()
	await await_idle_frame()
	assert_bool(_surface.shape.disabled).is_false()
	_surface.grab()
	await await_idle_frame()
	assert_bool(_surface.shape.disabled).is_true()

func test_puts_the_paper_down_at_the_aim_turned_to_the_chair() -> void:
	_surface.grab()
	assert_array(_put).is_empty()
	_surface.reading.value = Paper.new()
	_surface.aim_point.value = Vector3(0.0, 0.75, -0.75)
	_surface.grab()
	assert_object(_surface.reading.value).is_null()
	assert_int(_put.size()).is_equal(1)
	assert_vector(_put[0].origin).is_equal_approx(Vector3(0.0, 0.752, -0.75), Vector3.ONE * 0.0001)
	var foot := _put[0].basis * Vector3.BACK
	assert_vector(foot).is_equal_approx(Vector3.BACK, Vector3.ONE * 0.0001)

func test_the_pin_wall_hangs_the_paper_upright_foot_down() -> void:
	_surface.upright = true
	_surface.reading.value = Paper.new()
	_surface.aim_point.value = Vector3(0.0, 1.5, -1.6)
	_surface.grab()
	assert_vector(_put[0].origin).is_equal_approx(Vector3(0.0, 1.5, -1.598), Vector3.ONE * 0.0001)
	assert_vector(_put[0].basis.y).is_equal_approx(Vector3.BACK, Vector3.ONE * 0.0001)
	assert_vector(_put[0].basis * Vector3.BACK).is_equal_approx(Vector3.DOWN, Vector3.ONE * 0.0001)
