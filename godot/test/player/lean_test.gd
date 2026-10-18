extends GdUnitTestSuite

var _lean: Lean

func before_test() -> void:
	var player: Node3D = auto_free(Node3D.new())
	var pivot := Node3D.new()
	pivot.position = Vector3(0.0, 1.0, 0.0)
	player.add_child(pivot)
	_lean = Lean.new()
	player.add_child(_lean)
	_lean.model = PlayerModel.new()
	_lean.pivot = pivot
	_lean.focused = BoolValue.new()
	_lean.focus_point = Vector3Value.new()
	_lean.focus_point.value = Vector3(0.0, 1.0, -1.0)
	add_child(player)
	_lean.set_process(false)

func test_leans_in_while_focused_and_looking_at_it() -> void:
	_lean.focused.value = true
	_lean.tick(1.0)
	assert_float(_lean.amount).is_equal(1.0)
	var leaned := _lean.focus_point.value + _lean.model.lean_offset
	assert_vector(_lean.pivot.position).is_equal_approx(leaned, Vector3.ONE * 0.0001)

func test_looking_away_pulls_back() -> void:
	_lean.focused.value = true
	_lean.pivot.rotation_degrees.y = 90.0
	_lean.tick(1.0)
	assert_float(_lean.amount).is_equal(0.0)

func test_unfocus_returns_to_the_seat() -> void:
	_lean.focused.value = true
	_lean.tick(1.0)
	_lean.focused.value = false
	_lean.tick(1.0)
	assert_vector(_lean.pivot.position).is_equal_approx(
		Vector3(0.0, 1.0, 0.0),
		Vector3.ONE * 0.0001,
	)
