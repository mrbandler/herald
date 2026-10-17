extends GdUnitTestSuite

const ROOM := "res://game/data/input/room.tres"
const TERMINAL := "res://game/data/input/terminal.tres"


func test_room_context_maps_look_grab_fine_and_release() -> void:
	var room: GUIDEMappingContext = load(ROOM)
	var names: Array[String] = []
	for mapping: GUIDEActionMapping in room.mappings:
		names.append(mapping.action.name)
	assert_array(names).contains_exactly(["look", "grab", "fine", "release_mouse"])


func test_terminal_context_maps_leave() -> void:
	var terminal: GUIDEMappingContext = load(TERMINAL)
	assert_int(terminal.mappings.size()).is_equal(1)
	assert_str(terminal.mappings[0].action.name).is_equal("leave_terminal")


func test_bindings_use_the_intended_keys() -> void:
	var room: GUIDEMappingContext = load(ROOM)
	var grab := room.mappings[1].input_mappings[0].input as GUIDEInputMouseButton
	var fine := room.mappings[2].input_mappings[0].input as GUIDEInputKey
	var release := room.mappings[3].input_mappings[0].input as GUIDEInputKey
	var terminal: GUIDEMappingContext = load(TERMINAL)
	var leave := terminal.mappings[0].input_mappings[0].input as GUIDEInputKey
	assert_int(grab.button).is_equal(MOUSE_BUTTON_LEFT)
	assert_int(fine.key).is_equal(KEY_SHIFT)
	assert_int(release.key).is_equal(KEY_F1)
	assert_int(leave.key).is_equal(KEY_ESCAPE)


func test_look_is_a_2d_axis() -> void:
	var look: GUIDEAction = load("res://game/data/input/look.tres")
	assert_int(look.action_value_type).is_equal(GUIDEAction.GUIDEActionValueType.AXIS_2D)
