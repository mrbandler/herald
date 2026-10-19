extends GdUnitTestSuite

var _monitor: Monitor
var _material: ShaderMaterial

func before_test() -> void:
	_monitor = auto_free(Monitor.new())
	_monitor.model = MonitorModel.new()
	_material = ShaderMaterial.new()
	_material.shader = load("res://game/monitor/monitor.gdshader")
	var screen: MeshInstance3D = auto_free(MeshInstance3D.new())
	screen.material_override = _material
	_monitor.screen = screen
	_monitor.shown_item = ResourceValue.new()
	_monitor.monitor_mode = IntValue.new()
	_monitor.knob_line = FloatValue.new()
	_monitor.knob_offset = FloatValue.new()
	_monitor.knob_contrast = FloatValue.new()
	add_child(_monitor)
	_monitor.set_process(false)

func _image() -> StoredItem:
	var item := DownlinkFixture.item(33, "IMG", 6, 4)
	item.line_length = 100.0
	item.phase = 0.25
	item.image = PlaceholderTexture2D.new()
	return DownlinkFixture.stored(item, [0, 1])

func test_snow_without_an_item() -> void:
	_monitor.tick()
	assert_int(_material.get_shader_parameter("mode")).is_equal(MonitorModel.Mode.SNOW)

func test_streams_through_the_knobs_and_marks_the_newest_row() -> void:
	_monitor.shown_item.value = _image()
	_monitor.monitor_mode.value = MonitorModel.Mode.STREAM
	_monitor.knob_line.value = 90.0
	_monitor.knob_offset.value = 0.1
	_monitor.tick()
	assert_float(_material.get_shader_parameter("k")).is_equal_approx(0.9, 0.0001)
	assert_float(_material.get_shader_parameter("offset")).is_equal_approx(0.1, 0.0001)
	assert_int(_material.get_shader_parameter("newest_row")).is_equal(1)
	assert_int(_material.get_shader_parameter("rows")).is_equal(4)

func test_tunes_with_the_knobs() -> void:
	_monitor.shown_item.value = _image()
	_monitor.monitor_mode.value = MonitorModel.Mode.TUNE
	_monitor.knob_line.value = 110.0
	_monitor.knob_offset.value = 0.5
	_monitor.tick()
	assert_float(_material.get_shader_parameter("k")).is_equal_approx(1.1, 0.0001)
	assert_float(_material.get_shader_parameter("offset")).is_equal(0.5)
	assert_int(_material.get_shader_parameter("newest_row")).is_equal(-1)
