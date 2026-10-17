extends GdUnitTestSuite

## Calls the command functions directly; registering with LimboConsole needs the tree.


func test_skip_advances_pass_time() -> void:
	var debug: DebugCommands = auto_free(DebugCommands.new())
	debug.pass_time = FloatValue.new()
	debug.pass_time.value = 10.0
	debug.skip(25.0)
	assert_float(debug.pass_time.value).is_equal(35.0)


func test_lock_toggles_the_forced_lock() -> void:
	var debug: DebugCommands = auto_free(DebugCommands.new())
	debug.force_lock = BoolValue.new()
	debug.toggle_lock()
	assert_bool(debug.force_lock.value).is_true()
	debug.toggle_lock()
	assert_bool(debug.force_lock.value).is_false()
