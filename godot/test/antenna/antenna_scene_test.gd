extends GdUnitTestSuite

## Checks the scene's wiring. Exported node paths only resolve once the scene is in the tree.

func test_antenna_scene_is_wired() -> void:
	var scene: Node = auto_free(
		(load("res://game/antenna/antenna.tscn") as PackedScene).instantiate()
	)
	add_child(scene)
	var receiver := scene.get_node("Receiver") as Receiver
	var azimuth := scene.get_node("AzimuthKnob") as Knob
	var lock_lamp := scene.get_node("LockLamp") as Lamp
	var tone := scene.get_node("CarrierTone") as CarrierTone
	assert_object(receiver.model).is_not_null()
	assert_object(receiver.locked).is_not_null()
	assert_object(azimuth.target).is_same(receiver.dish_azimuth)
	assert_object(azimuth.visual).is_not_null()
	var dial := scene.get_node("TuningCounter") as ValueLabel
	assert_object(dial.source).is_same(receiver.tuning)
	assert_object(lock_lamp.source).is_same(receiver.locked)
	assert_object(lock_lamp.blink_source).is_same(receiver.signal_strength)
	assert_object(tone.signal_strength).is_same(receiver.signal_strength)
	assert_object(tone.tuning).is_same(receiver.tuning)
	assert_object((scene.get_node("TuneNeedle") as Needle).source).is_same(receiver.lock_quality)
	var mark := scene.get_node("LockMark") as NeedleMark
	assert_object(mark.receiver_model).is_same(receiver.model)
	var margin_mark := scene.get_node("MarginMark") as NeedleMark
	assert_str(margin_mark.threshold).is_equal("margin")
	assert_object(margin_mark.receiver_model).is_same(receiver.model)
	var volume := scene.get_node("VolumeKnob") as Knob
	assert_object(tone.volume).is_same(volume.target)
	for knob: Knob in [azimuth, volume, scene.get_node("TuningKnob") as Knob]:
		assert_object(knob.click.stream).is_instanceof(ClickStream)
	var elevation := scene.get_node("ElevationKnob") as Knob
	assert_bool(azimuth.model.wraps).is_true()
	assert_bool(elevation.model.wraps).is_false()
	assert_object(elevation.target).is_same(receiver.dish_elevation)
	var carrier_latch := scene.get_node("CarrierLatch") as EventLatch
	var speak_latch := scene.get_node("SpeakLatch") as EventLatch
	assert_object(carrier_latch.target).is_same(receiver.carrier_present)
	assert_object((scene.get_node("SpeakLamp") as Lamp).source).is_same(speak_latch.target)
	var chime := scene.get_node("UplinkChime") as BoolSound
	assert_object(chime.source).is_same(speak_latch.target)
	assert_object(chime.on_sound.stream).is_instanceof(ChimeStream)
	assert_object(chime.off_sound.stream).is_instanceof(ChimeStream)
	assert_object(chime.on_sound.stream).is_not_same(chime.off_sound.stream)
	for latch: EventLatch in [carrier_latch, speak_latch]:
		assert_object(latch.on).is_not_same(latch.off)
	assert_vector(azimuth.rotation_degrees).is_equal_approx(Vector3(90, 0, 0), Vector3.ONE * 0.01)
	var data_lamp := scene.get_node("DataLamp") as DataLamp
	assert_str(data_lamp.row_received.resource_path.get_file()).is_equal("row_received.tres")
	var lock_sound := scene.get_node("LockSound") as BoolSound
	assert_str(lock_sound.source.resource_path.get_file()).is_equal("locked.tres")
	assert_object(lock_sound.on_sound.stream).is_instanceof(ClickStream)
	assert_object(lock_sound.off_sound.stream).is_instanceof(ClickStream)
	var bell := scene.get_node("BellSound") as EventSound
	assert_str(bell.event.resource_path.get_file()).is_equal("download_complete.tres")
	assert_object(bell.sound.stream).is_instanceof(ChimeStream)
