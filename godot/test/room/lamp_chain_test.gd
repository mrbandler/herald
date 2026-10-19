extends GdUnitTestSuite

func test_pulls_only_once_unlocked() -> void:
	var chain: LampChain = auto_free(LampChain.new())
	chain.unlocked = BoolValue.new()
	chain.pull = Event.new()
	var spy := AtomSpy.events(chain.pull)
	add_child(chain)
	chain.grab()
	assert_int(spy.calls.size()).is_equal(0)
	chain.unlocked.value = true
	chain.grab()
	assert_int(spy.calls.size()).is_equal(1)

func test_is_usable_only_once_unlocked() -> void:
	var chain: LampChain = auto_free(LampChain.new())
	chain.unlocked = BoolValue.new()
	assert_bool(chain.is_usable()).is_false()
	chain.unlocked.value = true
	assert_bool(chain.is_usable()).is_true()
