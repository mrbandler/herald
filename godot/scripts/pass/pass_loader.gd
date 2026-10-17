class_name PassLoader
extends Node

## Points current_pass at the window for window_number. Second child of the room, after Resetter.

## The windows in order. Window numbers are 1-based indexes into this.
@export var passes: Array[PassWindow] = []
## 1-based number of the window to load. Clamped to the available range.
@export var window_number: IntValue
## Receives the chosen window.
@export var current_pass: ResourceValue


func _ready() -> void:
	var index := clampi(window_number.value - 1, 0, passes.size() - 1)
	current_pass.value = passes[index]
