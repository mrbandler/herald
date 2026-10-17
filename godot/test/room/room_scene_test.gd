extends GdUnitTestSuite

## Checks the composition without running it (the player would capture the mouse).

const ROOM := "res://game/room/room.tscn"


func test_resetter_and_loader_come_first() -> void:
	var room: Node = auto_free((load(ROOM) as PackedScene).instantiate())
	assert_str(room.get_child(0).name).is_equal("Resetter")
	assert_str(room.get_child(1).name).is_equal("PassLoader")
	var loader := room.get_child(1) as PassLoader
	assert_int(loader.passes.size()).is_equal(1)


func test_room_holds_every_feature() -> void:
	var room: Node = auto_free((load(ROOM) as PackedScene).instantiate())
	for child: String in ["Pass", "Player", "Antenna", "Terminal", "ShiftEnd", "DebugCommands"]:
		assert_object(room.get_node_or_null(child)).is_not_null()


func test_room_is_the_main_scene() -> void:
	var main: String = ProjectSettings.get_setting("application/run/main_scene")
	assert_str(main).is_equal(ROOM)
