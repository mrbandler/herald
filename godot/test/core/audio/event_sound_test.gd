extends GdUnitTestSuite

func test_plays_on_the_event() -> void:
	var sound: EventSound = auto_free(EventSound.new())
	sound.event = Event.new()
	sound.sound = auto_free(AudioStreamPlayer3D.new())
	sound.sound.stream = AudioStreamWAV.new()
	add_child(sound)
	sound.add_child(sound.sound)
	sound.event.raise()
	assert_bool(sound.sound.playing).is_true()
