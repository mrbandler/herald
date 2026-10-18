extends GdUnitTestSuite

const PASS_01 := "res://game/data/passes/pass_01.tres"


func test_window_one_offers_help_seq_and_tx() -> void:
	var window: PassWindow = load(PASS_01)
	assert_array(window.command_set.names()).contains_exactly(["HELP", "SEQ", "TX"])
	var tx := window.command_set.find("TX") as TxCommand
	assert_object(tx.tx_requested).is_not_null()
	assert_object(tx.out).is_same(window.command_set.find("SEQ").out)


func test_terminal_scene_is_wired() -> void:
	var scene: Node = auto_free(
		(load("res://game/terminal/terminal.tscn") as PackedScene).instantiate()
	)
	add_child(scene)
	var terminal := scene.get_node("Terminal") as Terminal
	var uplink := scene.get_node("Uplink") as Uplink
	assert_object(terminal.screen).is_same(scene.get_node("Screen/Text"))
	assert_object(uplink.out).is_same(terminal.out)
	var locked: BoolValue = load("res://game/data/atoms/antenna/locked.tres")
	assert_object(uplink.locked).is_same(locked)
	assert_str(uplink.los.resource_path.get_file()).is_equal("los.tres")
	var tx := (load(PASS_01) as PassWindow).command_set.find("TX") as TxCommand
	assert_object(tx.locked).is_same(locked)
	assert_object(tx.tx_requested).is_same(uplink.tx_requested)
	assert_object(tx.sequence).is_same(uplink.sequence)
	var focus := scene.get_node("FocusTarget") as FocusTarget
	assert_object(focus.focused).is_same(terminal.focused)
	assert_str(focus.focus_point.resource_path.get_file()).is_equal("terminal_focus_point.tres")
	var uplink_open := scene.get_node("UplinkOpenPrinter") as EventPrinter
	assert_str(uplink_open.event.resource_path.get_file()).is_equal("speak_opened.tres")
	assert_object(uplink_open.out).is_same(terminal.out)
	var lock := scene.get_node("LockPrinter") as BoolPrinter
	assert_object(lock.source).is_same(locked)
	assert_object(lock.out).is_same(terminal.out)
	var mode := scene.get_node("LinkModePrinter") as LinkModePrinter
	assert_object(mode.locked).is_same(locked)
	assert_object(mode.uplink_open).is_same(tx.speak_open)
	assert_object(mode.out).is_same(terminal.out)
	assert_int(mode.get_index()).is_greater(lock.get_index())
	var crt := scene.get_node("Crt") as MeshInstance3D
	var material := crt.material_override as StandardMaterial3D
	assert_vector(material.albedo_texture.get_size()).is_equal(Vector2(512, 384))
