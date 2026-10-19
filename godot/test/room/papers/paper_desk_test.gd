extends GdUnitTestSuite

var _desk: PaperDesk
var _arrivals: AtomSpy

func _paper(arrives_at: float) -> Paper:
	var paper := Paper.new()
	paper.arrives_at = arrives_at
	return paper

func _build(
	papers: Array[Paper],
	kept: Array[Paper] = [],
	heard := true,
	placed: Array[Resource] = [],
) -> void:
	var window := PassFixture.window_one()
	window.papers = papers
	_desk = auto_free(PaperDesk.new())
	_desk.kept = kept
	_desk.ack_heard = BoolValue.new()
	_desk.ack_heard.value = heard
	_desk.missed_ack = _paper(5.0)
	_desk.placed = ResourceListValue.new()
	_desk.placed.value = placed
	_desk.current_pass = ResourceValue.new()
	_desk.current_pass.value = window
	_desk.pass_time = FloatValue.new()
	_desk.reading = ResourceValue.new()
	_desk.put_down = Event.new()
	_desk.capsule_arrived = Event.new()
	_desk.capsule_waiting = FloatValue.new()
	_arrivals = AtomSpy.events(_desk.capsule_arrived)
	var room: Node3D = auto_free(Node3D.new())
	_desk.centre = _marker(room, Vector3.ZERO)
	_desk.stacks.append(_marker(room, Vector3(-1.0, 0.0, 0.0)))
	_desk.stacks.append(_marker(room, Vector3(1.0, 0.0, 0.0)))
	_desk.tray = _marker(room, Vector3(0.0, 1.0, 0.0))
	add_child(room)
	add_child(_desk)
	_desk.set_process(false)

func _marker(room: Node3D, at: Vector3) -> Marker3D:
	var marker := Marker3D.new()
	marker.position = at
	room.add_child(marker)
	return marker

func _sheets() -> Array[DeskPaper]:
	var found: Array[DeskPaper] = []
	for child: Node in _desk.get_children():
		found.append(child as DeskPaper)
	return found

func test_the_centred_paper_lies_in_the_middle_and_the_rest_stack_left_and_right() -> void:
	var card := _paper(0.0)
	card.centred = true
	var letter := _paper(0.0)
	_build([_paper(0.0), card, _paper(0.0)], [letter])
	var sheets := _sheets()
	assert_object(sheets[0].paper).is_same(letter)
	assert_vector(sheets[0].global_position).is_equal(Vector3(-1.0, 0.0, 0.0))
	assert_vector(sheets[1].global_position).is_equal(Vector3(1.0, 0.0, 0.0))
	assert_object(sheets[2].paper).is_same(card)
	assert_vector(sheets[2].global_position).is_equal(Vector3.ZERO)
	assert_vector(sheets[3].global_position).is_equal_approx(
		Vector3(-1.0, PaperDesk.STACK, 0.0),
		Vector3.ONE * 0.0001,
	)

func test_a_tube_paper_arrives_once_its_time_has_come() -> void:
	_build([_paper(40.0)])
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
	_build([_paper(60.0), _paper(40.0)])
	_desk.pass_time.value = 90.0
	_desk.tick()
	var sheets := _sheets()
	assert_int(sheets.size()).is_equal(2)
	assert_int(_arrivals.calls.size()).is_equal(2)
	assert_float(sheets[1].global_position.y).is_equal_approx(1.003, 0.0001)
	assert_float(sheets[0].paper.arrives_at).is_equal(40.0)

func test_the_tube_lamp_waits_for_the_paper_to_be_picked_up() -> void:
	_build([_paper(0.0), _paper(40.0)])
	_desk.pass_time.value = 40.0
	_desk.tick()
	assert_float(_desk.capsule_waiting.value).is_equal(1.0)
	_desk.reading.value = _sheets()[0].paper
	assert_float(_desk.capsule_waiting.value).is_equal(1.0)
	_desk.reading.value = _sheets()[1].paper
	assert_float(_desk.capsule_waiting.value).is_equal(0.0)

func test_the_insider_spells_the_heartbeat_out_after_a_missed_ack() -> void:
	_build([], [], false)
	_desk.pass_time.value = 5.0
	_desk.tick()
	assert_int(_sheets().size()).is_equal(1)
	assert_object(_sheets()[0].paper).is_same(_desk.missed_ack)

func test_no_insider_letter_after_a_heard_ack() -> void:
	_build([])
	_desk.pass_time.value = 5.0
	_desk.tick()
	assert_int(_sheets().size()).is_equal(0)

func test_a_paper_put_down_is_remembered_where_it_lies() -> void:
	_build([])
	var letter := _paper(0.0)
	_desk.reading.value = letter
	_desk.put_down.raise(Transform3D.IDENTITY)
	var hung := Transform3D(Basis(Vector3.RIGHT, PI / 2.0), Vector3(0.0, 1.5, -1.6))
	_desk.put_down.raise(hung)
	assert_int(_desk.placed.value.size()).is_equal(1)
	var entry := _desk.placed.value[0] as PlacedPaper
	assert_object(entry.paper).is_same(letter)
	assert_vector(entry.at.origin).is_equal(hung.origin)

func test_papers_from_the_start_are_remembered() -> void:
	_build([_paper(0.0)])
	assert_int(_desk.placed.value.size()).is_equal(1)

func test_a_remembered_paper_lies_where_it_was_and_leaves_the_stack() -> void:
	var letter := _paper(0.0)
	var entry := PlacedPaper.new()
	entry.paper = letter
	entry.at = Transform3D(Basis(Vector3.RIGHT, PI / 2.0), Vector3(0.0, 2.0, 0.0))
	_build([], [letter], true, [entry])
	var sheets := _sheets()
	assert_int(sheets.size()).is_equal(1)
	assert_vector(sheets[0].global_position).is_equal(Vector3(0.0, 2.0, 0.0))

func test_a_new_paper_goes_on_top_of_one_left_on_the_stack() -> void:
	var old := PlacedPaper.new()
	old.paper = _paper(0.0)
	old.at = Transform3D(Basis.IDENTITY, Vector3(-1.0, 0.0, 0.0))
	_build([_paper(0.0)], [], true, [old])
	assert_float(_sheets()[1].global_position.y).is_equal_approx(PaperDesk.STACK, 0.0001)

func test_last_windows_prayer_card_goes() -> void:
	var card := _paper(0.0)
	card.centred = true
	var entry := PlacedPaper.new()
	entry.paper = card
	_build([], [], true, [entry])
	assert_int(_sheets().size()).is_equal(0)
	assert_array(_desk.placed.value).is_empty()
