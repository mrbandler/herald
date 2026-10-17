extends GdUnitTestSuite

## Checks the scene's wiring without running it: every export points at an atom.


func test_pass_scene_is_wired() -> void:
	var scene: Node = auto_free((load("res://game/pass/pass.tscn") as PackedScene).instantiate())
	var clock := scene.get_node("PassClock") as PassClock
	var schedule := scene.get_node("PassSchedule") as PassSchedule
	var wall := scene.get_node("WallClock") as WallClock
	assert_object(clock.pass_time).is_not_null()
	assert_object(clock.shift_ended).is_not_null()
	assert_object(schedule.current_pass).is_not_null()
	assert_str(schedule.aos_event.resource_path.get_file()).is_equal("aos.tres")
	assert_str(schedule.turn_event.resource_path.get_file()).is_equal("turn_started.tres")
	assert_str(schedule.speak_event.resource_path.get_file()).is_equal("speak_opened.tres")
	assert_str(schedule.los_event.resource_path.get_file()).is_equal("los.tres")
	assert_str(schedule.bell_event.resource_path.get_file()).is_equal("morning_bell.tres")
	assert_object(wall.pass_time).is_same(clock.pass_time)
	assert_object(wall.current_pass).is_same(schedule.current_pass)
