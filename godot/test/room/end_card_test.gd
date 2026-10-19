extends GdUnitTestSuite

func test_an_ending_offers_the_credits() -> void:
	var card: EndCard = auto_free(
		(load("res://game/room/end_card.tscn") as PackedScene).instantiate()
	)
	add_child(card)
	card.show_card("SILENCE", "NO WORD WENT UP.", false)
	assert_str(card.keys.text).is_equal(card.ending_keys)
	card.show_credits()
	assert_bool(card.credits.visible).is_true()
	assert_bool(card.body.visible).is_false()
	assert_str(card.credits.text).contains("NASA")
	card.show_card("HERALD IS LOST", "FELL PAST.", true)
	assert_bool(card.credits.visible).is_false()
	assert_str(card.keys.text).is_equal(card.retry_keys)
