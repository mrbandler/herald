extends GdUnitTestSuite

const PASS_01 := "res://game/data/passes/pass_01.tres"
const PASS_02 := "res://game/data/passes/pass_02.tres"
const TERMINAL := "res://game/terminal/terminal.tscn"

func test_both_windows_share_the_station_commands() -> void:
	var window: PassWindow = load(PASS_01)
	var two: PassWindow = load(PASS_02)
	assert_object(window.command_set).is_same(two.command_set)
	assert_str(window.command_set.resource_path.get_file()).is_equal("station.tres")
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
	assert_object(terminal.top_rule).is_same(scene.get_node("Screen/TopRule"))
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
	var uplink := scene.get_node("Uplink") as Uplink
	assert_object(uplink.progress_line).is_same(downlink.progress_line)
	assert_object(uplink.status_notice).is_same(downlink.status_notice)
	assert_object(uplink.receiver_model).is_same(downlink.receiver_model)
	assert_object(uplink.signal_strength).is_same(downlink.signal_strength)
	assert_str(uplink.acked.resource_path.get_file()).is_equal("acked.tres")
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
	var stat := two.command_set.find("STAT") as StatCommand
	assert_object(stat.running_item).is_same(downlink.running_item)
	assert_str(downlink.shown_item.resource_path.get_file()).is_equal("shown_item.tres")
	assert_str(downlink.monitor_mode.resource_path.get_file()).is_equal("monitor_mode.tres")
	var listing := two.command_set.find("MANIFEST") as ManifestCommand
	assert_object(progress.manifest_seen).is_same(listing.manifest_seen)
	assert_object(progress.manifest_received).is_same(downlink.manifest_received)
	assert_object(downlink.out).is_same(scene.get_node("Terminal").get("out"))
	var manifest := two.command_set.find("MANIFEST") as ManifestCommand
	assert_object(manifest.storage).is_same(downlink.storage)
	assert_object(manifest.download_queue).is_same(downlink.download_queue)

func test_the_drive_unit_shows_storage() -> void:
	var scene: Node = auto_free((load(TERMINAL) as PackedScene).instantiate())
	var lamps := scene.get_node("DriveUnit/StorageLamps") as StorageLamps
	var downlink := scene.get_node("Downlink") as Downlink
	assert_int(lamps.get_child_count()).is_equal(14)
	assert_object(lamps.storage).is_same(downlink.storage)
	assert_object(scene.get_node("Keyboard")).is_not_null()

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
	var seq := two.command_set.find("SEQ") as SeqCommand
	assert_object(seq.unlocked_modules).is_same(unlock.unlocked_modules)
	var uplink := scene.get_node("Uplink") as Uplink
	assert_object(seq.last_sent).is_same(uplink.last_sent)
	var herald_names := PackedStringArray()
	for listed: HeraldCommand in seq.herald_commands:
		herald_names.append(listed.name)
	var expected := ["ACK", "RETX", "IMG", "SPC", "INSERT", "PWR", "RESET", "ERASE"]
	expected.append_array(["DESCEND", "TRANSFER"])
	assert_array(herald_names).is_equal(expected)
	assert_object(decode.storage).is_same(unlock.storage)

func test_volumes_are_wired() -> void:
	var scene: Node = auto_free((load(TERMINAL) as PackedScene).instantiate())
	var terminal := scene.get_node("Terminal") as Terminal
	var viewer := scene.get_node("FileViewer") as FileViewer
	var two: PassWindow = load(PASS_02)
	var ls := two.command_set.find("LS") as LsCommand
	var read := two.command_set.find("READ") as ReadCommand
	var unlock := two.command_set.find("UNLOCK") as UnlockCommand
	assert_object(read.viewing).is_same(terminal.viewing)
	assert_object(viewer.viewing).is_same(terminal.viewing)
	assert_object(viewer.focused).is_same(terminal.focused)
	assert_object(viewer.lean_amount).is_same(terminal.lean_amount)
	assert_object(viewer.terminal_model).is_same(terminal.model)
	assert_object(viewer.volume_model).is_same(read.volume_model)
	assert_object(terminal.volume_model).is_same(read.volume_model)
	assert_object(terminal.unlocked_modules).is_same(unlock.unlocked_modules)
	assert_object(ls.volume_model).is_same(read.volume_model)
	assert_object(viewer.unlocked_modules).is_same(unlock.unlocked_modules)
	assert_object(ls.unlocked_modules).is_same(unlock.unlocked_modules)
	assert_object(read.unlocked_modules).is_same(unlock.unlocked_modules)
	var cd := two.command_set.find("CD") as CdCommand
	assert_object(cd.directory).is_same(terminal.directory)
	assert_object(ls.directory).is_same(terminal.directory)
	assert_object(read.directory).is_same(terminal.directory)
	assert_object(viewer.panel).is_same(scene.get_node("Screen/FilePanel"))
	assert_object(viewer.title).is_same(scene.get_node("Screen/FilePanel/Title"))
	assert_object(viewer.counter).is_same(scene.get_node("Screen/FilePanel/Counter"))
	assert_object(viewer.body).is_same(scene.get_node("Screen/FilePanel/Body"))
	var dim := scene.get_node("Screen/FilePanel/Dim") as ColorRect
	assert_bool(dim.show_behind_parent).is_true()
	assert_object(scene.get_node("Screen/FilePanel/Keys")).is_not_null()
	assert_bool(viewer.panel.visible).is_false()

func test_exit_is_a_hidden_easter_egg() -> void:
	var two: PassWindow = load(PASS_02)
	var exit := two.command_set.find("EXIT") as TextCommand
	assert_bool(exit.hidden).is_true()
	assert_str(exit.text).is_not_empty()
