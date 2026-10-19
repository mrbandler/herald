extends GdUnitTestSuite

func _lamps(storage: ResourceListValue) -> StorageLamps:
	var lamps: StorageLamps = auto_free(StorageLamps.new())
	lamps.model = LampModel.new()
	lamps.downlink_model = DownlinkModel.new()
	lamps.storage = storage
	for _i: int in range(14):
		lamps.add_child(MeshInstance3D.new())
	return lamps

func test_lights_one_lamp_per_used_unit_from_the_start() -> void:
	var storage := ResourceListValue.new()
	storage.add(DownlinkFixture.stored(DownlinkFixture.item(23, "IMG", 6, 480), []))
	var lamps := _lamps(storage)
	add_child(lamps)
	assert_int(lamps.lit()).is_equal(6)
	var first := lamps.get_child(0) as MeshInstance3D
	var material := first.material_override as StandardMaterial3D
	assert_float(material.emission_energy_multiplier).is_equal(lamps.model.on_energy)
	storage.clear()
	assert_int(lamps.lit()).is_equal(0)
	assert_float(material.emission_energy_multiplier).is_equal(lamps.model.off_energy)

func test_lamps_past_the_capacity_are_blank_sockets() -> void:
	var lamps := _lamps(ResourceListValue.new())
	add_child(lamps)
	var last_live := (lamps.get_child(7) as MeshInstance3D).material_override as StandardMaterial3D
	var socket := (lamps.get_child(8) as MeshInstance3D).material_override as StandardMaterial3D
	assert_bool(last_live.emission_enabled).is_true()
	assert_bool(socket.emission_enabled).is_false()
	assert_object(socket.albedo_color).is_equal(lamps.socket_color)
