extends GdUnitTestSuite

var _mod: ModCommand
var _out: AtomSpy

func before_test() -> void:
	_mod = ModCommand.new()
	_mod.out = StringEvent.new()
	_mod.module_model = ModuleModel.new()
	_mod.unlocked_modules = StringListValue.new()
	_out = AtomSpy.events(_mod.out)

func test_lists_the_module_states() -> void:
	_mod.unlocked_modules.value = PackedStringArray(["TLM"])
	_mod.run(PackedStringArray())
	assert_array(_out.calls).is_equal([" TLM  UNLOCKED", " IMG  LOCKED", " SPC  LOCKED"])

func test_refuses_arguments() -> void:
	_mod.run(PackedStringArray(["TLM"]))
	assert_array(_out.calls).is_equal(["USAGE: MOD"])
