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

func test_help_describes_every_module() -> void:
	_mod.help = "MOD   STATES"
	_mod.module_model.descriptions = { "TLM": "TELEMETRY", "IMG": "IMAGES" }
	var lines := ["MOD   STATES", "MODULES:", "TLM               TELEMETRY"]
	lines.append_array(["IMG               IMAGES", "SPC"])
	assert_str(_mod.help_text()).is_equal("\n".join(lines))
