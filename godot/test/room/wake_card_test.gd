extends GdUnitTestSuite

func test_pauses_while_warming_then_lets_the_room_run() -> void:
	var card: WakeCard = (load("res://game/room/wake_card.tscn") as PackedScene).instantiate()
	var wall: WallClock = auto_free(WallClock.new())
	wall.pass_time = FloatValue.new()
	wall.current_pass = ResourceValue.new()
	wall.current_pass.value = PassFixture.window_one()
	card.wall_clock = wall
	add_child(card)
	assert_bool(get_tree().paused).is_true()
	assert_str(card.clock.text).is_equal(WallClock.format_mission(wall.mission_seconds() - 4.0))
	card.tick(card.warm_seconds / 2.0)
	assert_str(card.bar.text).contains("###############")
	card.tick(card.warm_seconds)
	assert_bool(get_tree().paused).is_false()
	assert_str(card.clock.text).is_equal(WallClock.format_mission(wall.mission_seconds()))
	card.queue_free()
