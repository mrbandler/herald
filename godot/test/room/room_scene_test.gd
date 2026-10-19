extends GdUnitTestSuite

## Checks the composition without running it (the player would capture the mouse).

const ROOM := "res://game/room/room.tscn"

func test_resetter_and_loader_come_first() -> void:
	var room: Node = auto_free((load(ROOM) as PackedScene).instantiate())
	assert_str(room.get_child(0).name).is_equal("Resetter")
	assert_str(room.get_child(1).name).is_equal("PassLoader")
	var loader := room.get_child(1) as PassLoader
	assert_int(loader.passes.size()).is_equal(2)
	assert_int(loader.passes[0].number).is_equal(1)
	assert_int(loader.passes[1].number).is_equal(2)

func test_room_holds_every_feature() -> void:
	var room: Node = auto_free((load(ROOM) as PackedScene).instantiate())
	for child: String in ["Pass", "Player", "Antenna", "Terminal", "ShiftEnd", "DebugCommands"]:
		assert_object(room.get_node_or_null(child)).is_not_null()

func test_room_is_the_main_scene() -> void:
	var main: String = ProjectSettings.get_setting("application/run/main_scene")
	assert_str(main).is_equal(ROOM)

func test_lamp_chain_ends_the_shift_after_los() -> void:
	var room: Node = auto_free((load(ROOM) as PackedScene).instantiate())
	var chain := room.get_node("LampChain") as LampChain
	var latch := room.get_node("ChainLatch") as EventLatch
	assert_object(chain.pull).is_same((room.get_node("ShiftEnd") as ShiftEnd).morning_bell)
	assert_object(latch.target).is_same(chain.unlocked)
	assert_str(latch.on.resource_path.get_file()).is_equal("los.tres")
	assert_object(latch.off).is_same(chain.pull)

func test_the_listener_falls_asleep_at_shift_end() -> void:
	var room: Node = auto_free((load(ROOM) as PackedScene).instantiate())
	var sleep := room.get_node("Sleep") as Sleep
	var end := room.get_node("ShiftEnd") as ShiftEnd
	assert_object(end.sleep).is_same(sleep)
	assert_object(sleep.shift_ended).is_same(end.shift_ended)
	var look := room.get_node("Player/MouseLook") as MouseLook
	assert_object(look.drowsiness).is_same(sleep.drowsiness)
	assert_object(sleep.camera).is_same(room.get_node("Player/Pivot/Camera3D"))
	assert_object(sleep.top_lid).is_not_null()
	assert_object(sleep.bottom_lid).is_not_null()
	assert_object(sleep.model).is_not_null()

func test_papers_desk_and_tube_are_wired() -> void:
	var room: Node = auto_free((load(ROOM) as PackedScene).instantiate())
	var loader := room.get_node("PassLoader") as PassLoader
	var papers := room.get_node("Papers") as PaperDesk
	var surface := room.get_node("DeskSurface") as DeskSurface
	var sound := room.get_node("CapsuleSound") as EventSound
	var held := room.get_node("Player/Pivot/Camera3D/HeldPaper") as HeldPaper
	var picker := room.get_node("Player/Picker") as Picker
	assert_object(papers.current_pass).is_same(loader.current_pass)
	assert_int(papers.desk_slots.size()).is_equal(3)
	assert_object(papers.tray).is_same(room.get_node("Tube/Tray"))
	assert_object(sound.event).is_same(papers.capsule_arrived)
	var lamp := room.get_node("Tube/Lamp") as Lamp
	assert_object(lamp.blink_source).is_same(papers.capsule_waiting)
	assert_object(surface.reading).is_same(papers.reading)
	assert_object(surface.put_down).is_same(papers.put_down)
	assert_object(surface.aim_point).is_same(picker.aim_point)
	assert_object(held.reading).is_same(papers.reading)
	assert_object(held.current_pass).is_same(loader.current_pass)
	assert_bool(papers.get_index() > loader.get_index()).is_true()
	var player := room.get_node("Player") as Node3D
	assert_vector(surface.chair).is_equal(player.position)

func test_shift_end_advances_the_campaign() -> void:
	var room: Node = auto_free((load(ROOM) as PackedScene).instantiate())
	var end := room.get_node("ShiftEnd") as ShiftEnd
	var loader := room.get_node("PassLoader") as PassLoader
	assert_object(end.window_number).is_same(loader.window_number)
	var debug := room.get_node("DebugCommands") as DebugCommands
	assert_object(debug.window_number).is_same(loader.window_number)
