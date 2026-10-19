extends GdUnitTestSuite

func test_pauses_while_warming_then_lets_the_room_run() -> void:
	var card: WakeCard = (load("res://game/room/wake_card.tscn") as PackedScene).instantiate()
	var wall := Label3D.new()
	wall.text = "T+ 214Y 118D\n02:40:00"
	card.wall_clock = auto_free(wall)
	add_child(card)
	assert_bool(get_tree().paused).is_true()
	assert_str(card.clock.text).is_equal(wall.text)
	card.tick(card.warm_seconds / 2.0)
	assert_str(card.bar.text).contains("##########")
	card.tick(card.warm_seconds)
	assert_bool(get_tree().paused).is_false()
	card.queue_free()
