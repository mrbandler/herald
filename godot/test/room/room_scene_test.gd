extends GdUnitTestSuite

## Checks the composition without running it (the player would capture the mouse).

const ROOM := "res://game/room/room.tscn"

func test_resetter_and_loader_come_first() -> void:
	var room: Node = auto_free((load(ROOM) as PackedScene).instantiate())
	assert_str(room.get_child(0).name).is_equal("Resetter")
	assert_str(room.get_child(1).name).is_equal("PassLoader")
	var loader := room.get_child(1) as PassLoader
	assert_int(loader.passes.size()).is_equal(3)
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
	var chain := room.get_node("RightLamp/LampChain") as LampChain
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
	assert_int(papers.stacks.size()).is_equal(2)
	assert_float(papers.centre.position.x).is_equal(0.0)
	assert_str(papers.kept[0].body()).contains("SEQ ADD ACK")
	assert_str(papers.ack_heard.resource_path.get_file()).is_equal("ack_heard.tres")
	assert_str(papers.missed_ack.body()).contains("SEQ ADD ACK")
	assert_str(papers.placed.resource_path.get_file()).is_equal("placed.tres")
	var wall := room.get_node("PinWall") as DeskSurface
	assert_bool(wall.upright).is_true()
	assert_object(wall.put_down).is_same(surface.put_down)
	assert_object(wall.reading).is_same(surface.reading)
	assert_object(papers.tray).is_same(room.get_node("Tube/Tray"))
	assert_object(sound.event).is_same(papers.capsule_arrived)
	var lamp := room.get_node("Tube/Lamp") as Lamp
	assert_object(lamp.blink_source).is_same(papers.capsule_waiting)
	var capsule := room.get_node("Tube/CapsuleShown") as ValueVisibility
	assert_object(capsule.source).is_same(papers.capsule_waiting)
	assert_object(capsule.target).is_same(room.get_node("Tube/Capsule"))
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

func test_the_monitor_stands_in_the_room_with_window_three() -> void:
	var room: Node = auto_free((load(ROOM) as PackedScene).instantiate())
	var loader := room.get_node("PassLoader") as PassLoader
	assert_int(loader.passes.size()).is_equal(3)
	assert_int(loader.passes[2].number).is_equal(3)
	var driver := room.get_node("Monitor/Driver") as Monitor
	assert_str(driver.shown_item.resource_path.get_file()).is_equal("shown_item.tres")
