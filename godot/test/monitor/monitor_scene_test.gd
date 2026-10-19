extends GdUnitTestSuite

const MONITOR := "res://game/monitor/monitor.tscn"

func test_the_monitor_scene_is_wired() -> void:
	var scene: Node = auto_free((load(MONITOR) as PackedScene).instantiate())
	var driver := scene.get_node("Driver") as Monitor
	var handler := scene.get_node("CommitHandler") as MonitorCommit
	var button := scene.get_node("CommitButton") as PushButton
	assert_object(driver.screen).is_same(scene.get_node("Screen"))
	assert_object(button.pressed).is_same(handler.commit_pressed)
	assert_object(handler.shown_item).is_same(driver.shown_item)
	assert_object(handler.monitor_mode).is_same(driver.monitor_mode)
	var line := scene.get_node("LineKnob") as Knob
	var offset := scene.get_node("OffsetKnob") as Knob
	var contrast := scene.get_node("ContrastKnob") as Knob
	assert_object(line.target).is_same(driver.knob_line)
	assert_object(offset.target).is_same(driver.knob_offset)
	assert_object(contrast.target).is_same(driver.knob_contrast)
	assert_float(line.model.minimum).is_equal(80.0)
	assert_bool(offset.model.wraps).is_true()
	assert_str(handler.storage.resource_path.get_file()).is_equal("storage.tres")
