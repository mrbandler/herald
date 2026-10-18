class_name EventSound
extends Node

## Plays a sound every time an event fires.

## Plays `sound` when raised.
@export var event: Event

## The player to play.
@export var sound: AudioStreamPlayer3D

## Listens for the event.
func _ready() -> void:
	event.raised.connect(_on_raised)

## Plays the sound.
func _on_raised(_payload: Variant) -> void:
	sound.play()
