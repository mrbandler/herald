extends GdUnitTestSuite

const PASS_01 := "res://game/data/passes/pass_01.tres"
const PASS_02 := "res://game/data/passes/pass_02.tres"
const TERMINAL := "res://game/terminal/terminal.tscn"

func test_window_one_offers_help_seq_tx_and_clr() -> void:
	var window: PassWindow = load(PASS_01)
	assert_array(window.command_set.names()).contains_exactly(["HELP", "SEQ", "TX", "CLR"])
	var tx := window.command_set.find("TX") as TxCommand
	assert_object(tx.tx_requested).is_not_null()
	assert_object(tx.out).is_same(window.command_set.find("SEQ").out)

func test_terminal_scene_is_wired() -> void:
	var scene: Node = auto_free((load(TERMINAL) as PackedScene).instantiate())
	add_child(scene)
	var terminal := scene.get_node("Terminal") as Terminal
	var uplink := scene.get_node("Uplink") as Uplink
	assert_object(terminal.screen).is_same(scene.get_node("Screen/Text"))
	assert_object(terminal.scroll_rule).is_same(scene.get_node("Screen/ScrollRule"))
	assert_object(uplink.out).is_same(terminal.out)
	var locked: BoolValue = load("res://game/data/atoms/antenna/locked.tres")
	assert_object(uplink.locked).is_same(locked)
	assert_str(uplink.los.resource_path.get_file()).is_equal("los.tres")
	var tx := (load(PASS_01) as PassWindow).command_set.find("TX") as TxCommand
	assert_object(tx.locked).is_same(locked)
	assert_object(tx.tx_requested).is_same(uplink.tx_requested)
	assert_object(tx.sequence).is_same(uplink.sequence)
	var clr := (load(PASS_01) as PassWindow).command_set.find("CLR") as ClrCommand
	assert_object(clr.cleared).is_same(terminal.clear)
	var focus := scene.get_node("FocusTarget") as FocusTarget
	assert_object(focus.focused).is_same(terminal.focused)
	assert_str(terminal.lean_amount.resource_path.get_file()).is_equal("lean_amount.tres")
	assert_str(focus.focus_point.resource_path.get_file()).is_equal("terminal_focus_point.tres")
	var status := scene.get_node("Screen/StatusBar") as LinkStatus
	assert_object(status.locked).is_same(locked)
	assert_object(status.uplink_open).is_same(tx.speak_open)
	assert_object(status.transmitting).is_same(uplink.transmitting)
	assert_str(status.signal_strength.resource_path.get_file()).is_equal("signal_strength.tres")
	assert_object(status.current_pass).is_same(terminal.current_pass)
	assert_object(status.band).is_same(scene.get_node("Screen/StatusBand"))
	assert_object(status.countdown).is_same(scene.get_node("Screen/StatusCountdown"))
	assert_object(scene.get_node("Screen/KeyHints")).is_not_null()
	var crt := scene.get_node("Crt") as MeshInstance3D
	var material := crt.material_override as StandardMaterial3D
	assert_vector(material.albedo_texture.get_size()).is_equal(Vector2(640, 480))

func test_downlink_is_wired() -> void:
	var scene: Node = auto_free((load(TERMINAL) as PackedScene).instantiate())
	var downlink := scene.get_node("Downlink") as Downlink
	var status := scene.get_node("Screen/StatusBar") as LinkStatus
	var progress := scene.get_node("Screen/ProgressLine") as ProgressLabel
	assert_object(progress.progress_line).is_same(downlink.progress_line)
	assert_object(progress.storage).is_same(downlink.storage)
	assert_object(progress.downlink_model).is_same(downlink.model)
	assert_object(progress.storage_readout).is_same(scene.get_node("Screen/StorageReadout"))
	assert_object(status.status_notice).is_same(downlink.status_notice)
	assert_str(downlink.storage.resource_path.get_file()).is_equal("storage.tres")
	assert_str(downlink.speak_opened.resource_path.get_file()).is_equal("speak_opened.tres")
	var two: PassWindow = load(PASS_02)
	var get_command := two.command_set.find("GET") as GetCommand
	assert_object(get_command.download_queue).is_same(downlink.download_queue)
	assert_object(get_command.downlink_open).is_same(downlink.downlink_open)
	assert_object(get_command.storage).is_same(downlink.storage)

func test_module_unlock_is_wired() -> void:
	var scene: Node = auto_free((load(TERMINAL) as PackedScene).instantiate())
	var relay := scene.get_node("RelaySound") as EventSound
	var bell := scene.get_node("UnlockBellSound") as EventSound
	assert_str(relay.event.resource_path.get_file()).is_equal("module_unlocked.tres")
	assert_object(bell.event).is_same(relay.event)
	assert_object(relay.sound.stream).is_instanceof(ClickStream)
	assert_float((bell.sound.stream as ChimeStream).lead_seconds).is_greater(0.0)
	var two: PassWindow = load(PASS_02)
	var unlock := two.command_set.find("UNLOCK") as UnlockCommand
	assert_object(unlock.module_unlocked).is_same(relay.event)
	var decode := two.command_set.find("DECODE") as DecodeCommand
	assert_object(decode.unlocked_modules).is_same(unlock.unlocked_modules)
	assert_object(decode.storage).is_same(unlock.storage)
