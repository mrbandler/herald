class_name BoolSound
extends Node

## Plays one sound when a BoolValue turns on and another when it turns off.

## Watched for changes.
@export var source: BoolValue

## Played when `source` turns true. Optional.
@export var on_sound: AudioStreamPlayer3D

## Played when `source` turns false. Optional.
@export var off_sound: AudioStreamPlayer3D

## Watches `source` for changes.
func _ready() -> void:
	source.updated.connect(_on_updated)

## Plays the on or off sound for the new value, when it is set.
func _on_updated(_previous: Variant, current: Variant) -> void:
	var sound := on_sound if current else off_sound

	if sound != null:
		sound.play()
