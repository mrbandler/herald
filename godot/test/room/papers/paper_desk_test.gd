extends GdUnitTestSuite

var _desk: PaperDesk
var _arrivals: AtomSpy

func _paper(arrives_at: float) -> Paper:
	var paper := Paper.new()
	paper.arrives_at = arrives_at
	return paper

func _build(papers: Array[Paper], slots: int) -> void:
	var window := PassFixture.window_one()
	window.papers = papers
	_desk = auto_free(PaperDesk.new())
	_desk.current_pass = ResourceValue.new()
	_desk.current_pass.value = window
	_desk.pass_time = FloatValue.new()
	_desk.reading = ResourceValue.new()
	_desk.put_down = Event.new()
	_desk.capsule_arrived = Event.new()
	_arrivals = AtomSpy.events(_desk.capsule_arrived)
	var room: Node3D = auto_free(Node3D.new())
	for i: int in range(slots):
		var slot := Marker3D.new()
		slot.position = Vector3(float(i), 0.0, 0.0)
		room.add_child(slot)
		_desk.desk_slots.append(slot)
	_desk.tray = Marker3D.new()
	_desk.tray.position = Vector3(0.0, 1.0, 0.0)
	room.add_child(_desk.tray)
	add_child(room)
	add_child(_desk)
	_desk.set_process(false)

func _sheets() -> Array[DeskPaper]:
	var found: Array[DeskPaper] = []
	for child: Node in _desk.get_children():
		found.append(child as DeskPaper)
	return found

func test_start_papers_land_on_the_slots_and_extras_are_left_out() -> void:
	_build([_paper(0.0), _paper(0.0), _paper(0.0)], 2)
	var sheets := _sheets()
	assert_int(sheets.size()).is_equal(2)
	assert_vector(sheets[1].global_position).is_equal(Vector3(1.0, 0.0, 0.0))

func test_a_tube_paper_arrives_once_its_time_has_come() -> void:
	_build([_paper(40.0)], 1)
	_desk.pass_time.value = 39.0
	_desk.tick()
	assert_int(_sheets().size()).is_equal(0)
	_desk.pass_time.value = 40.0
	_desk.tick()
	_desk.tick()
	assert_int(_sheets().size()).is_equal(1)
	assert_int(_arrivals.calls.size()).is_equal(1)
	assert_vector(_sheets()[0].global_position).is_equal(Vector3(0.0, 1.0, 0.0))

func test_a_skip_delivers_every_paper_due_stacked() -> void:
	_build([_paper(60.0), _paper(40.0)], 1)
	_desk.pass_time.value = 90.0
	_desk.tick()
	var sheets := _sheets()
	assert_int(sheets.size()).is_equal(2)
	assert_int(_arrivals.calls.size()).is_equal(2)
	assert_float(sheets[1].global_position.y).is_equal_approx(1.003, 0.0001)
	assert_float(sheets[0].paper.arrives_at).is_equal(40.0)
