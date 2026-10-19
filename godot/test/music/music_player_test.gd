extends GdUnitTestSuite

var _player: MusicPlayer

func before_test() -> void:
	# Never added to the tree: `_ready` does not run, so no stream and no thread.
	_player = auto_free(MusicPlayer.new())
	_player.model = MusicModel.new()
	_player.volume = FloatValue.new()
	_player.pass_time = FloatValue.new()
	_player.current_pass = ResourceValue.new()
	_player.current_pass.value = PassFixture.window_one()

func test_tick_turns_the_atoms_into_the_snapshot() -> void:
	_player.volume.value = 0.4
	_player.pass_time.value = 60.0
	_player.tick()
	var model := _player.model
	assert_float(_player.bed).is_equal_approx(model.bed_level(0.4), 0.0001)
	assert_float(_player.melody).is_equal_approx(model.melody_level(0.4), 0.0001)
	var expected := model.stress_at(PassFixture.window_one(), 60.0)
	assert_float(_player.stress).is_equal_approx(expected, 0.0001)

func test_full_knob_leaves_only_the_quiet_bed() -> void:
	_player.volume.value = 1.0
	_player.tick()
	assert_float(_player.melody).is_equal(0.0)
	assert_float(_player.bed).is_equal_approx(_player.model.bed_floor, 0.0001)

func test_without_a_pass_there_is_no_stress() -> void:
	_player.current_pass.value = null
	_player.pass_time.value = 100.0
	_player.tick()
	assert_float(_player.stress).is_equal(0.0)
