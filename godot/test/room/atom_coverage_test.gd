extends GdUnitTestSuite

## Every value atom is either reset per pass by the room's Resetter, or kept on purpose.

const KEPT: PackedStringArray = [
	"res://game/data/atoms/campaign/window_number.tres",
	"res://game/data/atoms/terminal/command_history.tres",
	"res://game/data/atoms/modules/unlocked_modules.tres",
	"res://game/data/atoms/pass/current_pass.tres",
	"res://game/data/atoms/player/terminal_focus_point.tres",
	"res://game/data/atoms/antenna/volume.tres",
	"res://game/data/atoms/downlink/storage.tres",
]

func test_every_value_atom_is_reset_or_kept() -> void:
	var reset := _reset_paths()
	assert_int(reset.size()).is_greater(0)
	for path: String in _value_atoms("res://game/data/atoms"):
		var listed := reset.has(path) or KEPT.has(path)
		assert_bool(listed).override_failure_message(path + " is neither reset nor kept").is_true()

func _reset_paths() -> PackedStringArray:
	var state := (load("res://game/room/room.tscn") as PackedScene).get_state()
	var paths := PackedStringArray()
	for node: int in range(state.get_node_count()):
		if state.get_node_name(node) != "Resetter":
			continue
		for property: int in range(state.get_node_property_count(node)):
			if state.get_node_property_name(node, property) != "atoms":
				continue
			var atoms: Array = state.get_node_property_value(node, property)
			for atom: Resource in atoms:
				paths.append(atom.resource_path)
	return paths

func _value_atoms(dir: String) -> PackedStringArray:
	var found := PackedStringArray()
	for sub: String in DirAccess.get_directories_at(dir):
		found.append_array(_value_atoms(dir.path_join(sub)))
	for file: String in DirAccess.get_files_at(dir):
		if file.ends_with(".tres") and load(dir.path_join(file)) is Value:
			found.append(dir.path_join(file))
	return found
