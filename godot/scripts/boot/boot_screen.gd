class_name BootScreen
extends Control

## The first screen, before the room loads: the station terminal asks for headphones. Any key or
## click goes on to the game.

## The scene the game starts in.
@export_file("*.tscn") var next_scene := "res://game/room/room.tscn"

## Goes on with any key or click.
func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	var click := event as InputEventMouseButton
	if (key != null and key.pressed) or (click != null and click.pressed):
		get_viewport().set_input_as_handled()
		go_on()

## Loads the game.
func go_on() -> void:
	get_tree().change_scene_to_file(next_scene)
