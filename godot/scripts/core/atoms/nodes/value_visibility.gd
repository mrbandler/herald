class_name ValueVisibility
extends Node

## Shows `target` while `source` is above zero, and hides it otherwise.

## Read. Above zero shows the target.
@export var source: FloatValue

## The node shown and hidden.
@export var target: Node3D

## Listens for changes and draws the current state.
func _ready() -> void:
	source.updated.connect(_on_updated)
	refresh()

## Shows the target while the source is above zero.
func refresh() -> void:
	target.visible = source.value > 0.0

## Redraws on every change.
func _on_updated(_previous: Variant, _current: Variant) -> void:
	refresh()
