extends GdUnitTestSuite

var _unlock: UnlockCommand
var _out: AtomSpy
var _unlocked: AtomSpy

func before_test() -> void:
	_unlock = UnlockCommand.new()
	_unlock.out = StringEvent.new()
	_unlock.module_model = ModuleModel.new()
	var banners: Dictionary[String, PackedStringArray] = { "TLM": PackedStringArray(["BANNER"]) }
	_unlock.module_model.banners = banners
	_unlock.downlink_model = DownlinkModel.new()
	_unlock.storage = ResourceListValue.new()
	_unlock.unlocked_modules = StringListValue.new()
	_unlock.module_unlocked = Event.new()
	_unlock.used_keys = StringListValue.new()
	_out = AtomSpy.events(_unlock.out)
	_unlocked = AtomSpy.events(_unlock.module_unlocked)

func _key(id: int, key_for: String, grades: Array[int]) -> StoredItem:
	var item := DownlinkFixture.item(id, "AUTH", 1, 2)
	item.key_for = key_for
	var stored := DownlinkFixture.stored(item, grades)
	_unlock.storage.add(stored)
	return stored

func _run(words: Array[String]) -> void:
	_unlock.run(PackedStringArray(words))

func test_unlocks_with_a_valid_key_and_uses_it_up() -> void:
	_key(21, "TLM", [0, 1])
	_run(["TLM", "21"])
	assert_array(_out.calls).is_equal([" -- TLM UNLOCKED --", " BANNER"])
	assert_bool(_unlock.unlocked_modules.value.has("TLM")).is_true()
	assert_int(_unlock.storage.value.size()).is_equal(0)
	assert_array(_unlocked.calls).is_equal(["TLM"])
	assert_array(_unlock.used_keys.value).is_equal(PackedStringArray(["21"]))

func test_refusals_in_order() -> void:
	_key(21, "TLM", [0, 2])
	_key(23, "IMG", [0, 0])
	_unlock.storage.add(DownlinkFixture.stored(DownlinkFixture.item(22, "TLM", 1, 2), [0, 0]))
	_run(["TLM"])
	_run(["XYZ", "21"])
	_run(["TLM", "99"])
	_run(["TLM", "22"])
	_run(["TLM", "23"])
	_run(["TLM", "21"])
	var expected := [
		"USAGE: UNLOCK <NAME> <ID>",
		"XYZ CANNOT BE UNLOCKED",
		"99 UNKNOWN ITEM",
		"22 IS NOT AN AUTH BLOCK",
		"KEY DOES NOT FIT TLM",
		"21 INVALID. 1 ROWS MISSING",
	]
	assert_array(_out.calls).is_equal(expected)
	assert_array(_unlocked.calls).is_empty()
	assert_int(_unlock.storage.value.size()).is_equal(3)
	assert_array(_unlock.unlocked_modules.value).is_empty()

func test_refuses_an_unlocked_module_and_prints_no_banner_without_one() -> void:
	_unlock.unlocked_modules.value = PackedStringArray(["TLM"])
	_run(["TLM", "21"])
	_key(23, "IMG", [0, 0])
	_run(["IMG", "23"])
	assert_array(_out.calls).is_equal(["TLM ALREADY UNLOCKED", " -- IMG UNLOCKED --"])
