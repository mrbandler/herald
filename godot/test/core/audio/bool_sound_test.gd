extends GdUnitTestSuite

var _sound: BoolSound

func before_test() -> void:
	_sound = auto_free(BoolSound.new())
	_sound.source = BoolValue.new()
	_sound.on_sound = _player()
	_sound.off_sound = _player()
	add_child(_sound)

func test_plays_the_on_sound_when_it_turns_true() -> void:
	_sound.source.value = true
	assert_bool(_sound.on_sound.playing).is_true()
	assert_bool(_sound.off_sound.playing).is_false()

func test_plays_the_off_sound_when_it_turns_false() -> void:
	_sound.source.value = true
	_sound.on_sound.stop()
	_sound.source.value = false
	assert_bool(_sound.off_sound.playing).is_true()
	assert_bool(_sound.on_sound.playing).is_false()

func _player() -> AudioStreamPlayer3D:
	var player: AudioStreamPlayer3D = auto_free(AudioStreamPlayer3D.new())
	player.stream = AudioStreamWAV.new()
	add_child(player)
	return player
