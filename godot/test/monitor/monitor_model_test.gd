extends GdUnitTestSuite

var _model := MonitorModel.new()

func _image(rows: int) -> StoredItem:
	var item := DownlinkFixture.item(33, "IMG", 6, rows)
	item.line_length = 100.0
	item.phase = 0.25
	return DownlinkFixture.stored(item, [])

func test_row_states_follow_the_grades_and_mark_unsent_rows() -> void:
	var stored := _image(4)
	stored.grades = PackedByteArray([0, 1, 2])
	var states := _model.row_states(stored)
	assert_int(states.get_width()).is_equal(4)
	var bytes := states.get_data()
	assert_array(Array(bytes)).is_equal([0, 1, 2, 3])

func test_the_mapping_is_upright_at_the_true_line_and_phase() -> void:
	var spot := _model.source(0.3, 0.5, 10, 1.0, 0.25, 0.25)
	assert_vector(spot).is_equal_approx(Vector2(0.3, 5.0), Vector2.ONE * 0.0001)

func test_a_wrong_line_slants_each_row_further() -> void:
	var first := _model.source(0.0, 0.05, 10, 1.01, 0.0, 0.0)
	var later := _model.source(0.0, 0.95, 10, 1.01, 0.0, 0.0)
	assert_float(first.x).is_equal_approx(0.0, 0.0001)
	assert_float(later.x).is_equal_approx(0.09, 0.0001)

func test_rows_past_the_stream_are_unsent() -> void:
	assert_float(_model.source(0.9, 0.95, 10, 1.2, 0.0, 0.0).y).is_equal(-1.0)
	assert_float(_model.source(0.1, 0.0, 10, 1.0, 0.0, 0.5).y).is_equal(-1.0)

func test_a_cal_presets_close_but_not_exact() -> void:
	var image := DownlinkFixture.item(33, "IMG", 4, 4)
	image.phase = 0.98
	var cal := DownlinkFixture.item(32, "CAL", 1, 2)
	cal.line_length = 103.4
	var preset := _model.from_cal(image, cal)
	assert_float(preset.x).is_equal_approx(103.4 + _model.cal_line_error, 0.0001)
	assert_float(preset.y).is_equal_approx(fposmod(0.98 + _model.cal_offset_error, 1.0), 0.0001)
	assert_float(_model.cal_line_error).is_not_equal(0.0)

func test_settings_per_mode() -> void:
	var stored := _image(4)
	var knobs := Vector3(97.0, 0.6, 0.8)
	assert_vector(_model.settings(MonitorModel.Mode.STREAM, stored, knobs)).is_equal(knobs)
	assert_vector(_model.settings(MonitorModel.Mode.TUNE, stored, knobs)).is_equal(knobs)
	stored.tuning = Vector3(99.9, 0.2, 0.4)
	assert_vector(_model.settings(MonitorModel.Mode.SHOW, stored, knobs)).is_equal(stored.tuning)
