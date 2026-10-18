extends GdUnitTestSuite

var _schedule: PassSchedule
var _order: Array[String] = []


func before_test() -> void:
	_order.clear()
	_schedule = auto_free(PassSchedule.new())
	_schedule.pass_time = FloatValue.new()
	_schedule.current_pass = ResourceValue.new()
	_schedule.current_pass.value = PassFixture.window_one()
	_schedule.aos_event = _event("aos")
	_schedule.speak_event = _event("speak")
	_schedule.los_event = _event("los")
	_schedule.bell_event = _event("bell")
	add_child(_schedule)


func test_crossing_a_mark_raises_it_once() -> void:
	_schedule.pass_time.value = 29.9
	_schedule.pass_time.value = 30.1
	_schedule.pass_time.value = 30.2
	assert_array(_order).contains_exactly(["aos"])


func test_landing_exactly_on_a_mark_raises_it_once() -> void:
	_schedule.pass_time.value = 30.0
	_schedule.pass_time.value = 30.5
	assert_array(_order).contains_exactly(["aos"])


func test_a_jump_raises_every_crossed_mark_in_order() -> void:
	_schedule.pass_time.value = 120.0
	assert_array(_order).contains_exactly(["aos", "speak", "los"])


func test_a_jump_past_the_bell_raises_all_four() -> void:
	_schedule.pass_time.value = 200.0
	assert_array(_order).contains_exactly(["aos", "speak", "los", "bell"])


func test_going_back_raises_nothing() -> void:
	_schedule.pass_time.value = 120.0
	_order.clear()
	_schedule.pass_time.value = 0.0
	assert_array(_order).is_empty()


func _event(event_name: String) -> Event:
	var event := Event.new()
	event.raised.connect(
		func(_payload: Variant) -> void:
			_order.append(event_name),
	)
	return event
