extends GdUnitTestSuite

## Checks wiring without entering the tree (MouseLook would capture the mouse).
## Node exports are checked by path, since they only resolve inside the tree.

func test_player_scene_is_wired() -> void:
	var scene: Node = auto_free(
		(load("res://game/player/player.tscn") as PackedScene).instantiate()
	)
	var look := scene.get_node("MouseLook") as MouseLook
	var picker := scene.get_node("Picker") as Picker
	var lean := scene.get_node("Lean") as Lean
	var crosshair := scene.get_node("Hud/Crosshair") as Crosshair
	assert_object(look.room_context).is_not_null()
	assert_object(picker.grabbing).is_not_null()
	assert_object(look.grabbing).is_same(picker.grabbing)
	assert_object(crosshair.grabbing).is_same(picker.grabbing)
	assert_object(picker.hovering).is_not_null()
	assert_object(crosshair.hovering).is_same(picker.hovering)
	assert_object(picker.fine).is_not_null()
	assert_object(lean.focused).is_not_null()
	assert_object(lean.focus_point).is_not_null()
	assert_str(lean.lean_amount.resource_path.get_file()).is_equal("lean_amount.tres")
	assert_object(crosshair.grab_icon).is_not_null()
	assert_int(crosshair.mouse_filter).is_equal(Control.MOUSE_FILTER_IGNORE)
	assert_object(scene.get_node("Pivot/Camera3D")).is_not_null()
