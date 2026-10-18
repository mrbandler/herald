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
	for knob: Knob in [azimuth, scene.get_node("TuningKnob") as Knob]:
		assert_object(knob.click.stream).is_instanceof(ClickStream)
	var elevation := scene.get_node("ElevationKnob") as Knob
	assert_bool(azimuth.model.wraps).is_true()
	assert_bool(elevation.model.wraps).is_false()
	assert_object(elevation.target).is_same(receiver.dish_elevation)
	var carrier_latch := scene.get_node("CarrierLatch") as EventLatch
	var turn_latch := scene.get_node("TurnLatch") as EventLatch
	var speak_latch := scene.get_node("SpeakLatch") as EventLatch
	assert_object(carrier_latch.target).is_same(receiver.carrier_present)
	assert_object(turn_latch.target).is_same(tone.turn_active)
	assert_object((scene.get_node("SpeakLamp") as Lamp).source).is_same(speak_latch.target)
	for latch: EventLatch in [carrier_latch, turn_latch, speak_latch]:
		assert_object(latch.on).is_not_same(latch.off)
	assert_vector(azimuth.rotation_degrees).is_equal_approx(Vector3(90, 0, 0), Vector3.ONE * 0.01)
