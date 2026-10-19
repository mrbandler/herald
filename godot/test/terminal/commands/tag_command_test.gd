extends GdUnitTestSuite

var _tag: TagCommand
var _out: AtomSpy

func before_test() -> void:
	_tag = TagCommand.new()
	_tag.out = StringEvent.new()
	_tag.downlink_model = DownlinkModel.new()
	_tag.storage = ResourceListValue.new()
	_tag.storage.add(DownlinkFixture.stored(DownlinkFixture.item(21, "AUTH", 1, 2), [0, 1]))
	_tag.storage.add(DownlinkFixture.stored(DownlinkFixture.item(22, "TLM", 1, 2), [0, 0]))
	_out = AtomSpy.events(_tag.out)

func _run(words: Array[String]) -> void:
	_tag.run(PackedStringArray(words))

func test_tags_by_replacing_the_item() -> void:
	var old := _tag.storage.value[0] as StoredItem
	_run(["21", "FIRST", "KEY"])
	var tagged := _tag.storage.value[0] as StoredItem
	assert_object(tagged).is_not_same(old)
	assert_str(tagged.tag).is_equal("FIRST KEY")
	assert_array(Array(tagged.grades)).is_equal([0, 1])
	assert_object(tagged.item).is_same(old.item)
	assert_array(_out.calls).is_equal(["21 TAGGED"])

func test_clears_a_tag() -> void:
	_run(["22", "OLD"])
	_run(["22"])
	assert_str((_tag.storage.value[1] as StoredItem).tag).is_empty()
	assert_str(_out.calls[-1]).is_equal("22 TAG CLEARED")

func test_refusals() -> void:
	_run([])
	_run(["99", "X"])
	_run(["22", "A", "VERY", "LONG", "LABEL", "HERE"])
	var expected := ["USAGE: TAG <ID> [TEXT]", "99 UNKNOWN ITEM", "TAG TOO LONG. 16 MAX"]
	assert_array(_out.calls).is_equal(expected)

func test_a_tag_of_exactly_the_limit_fits() -> void:
	_run(["22", "ABCDEFGH", "IJKLMNO"])
	assert_array(_out.calls).is_equal(["22 TAGGED"])
