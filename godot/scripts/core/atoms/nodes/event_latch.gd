class_name EventLatch
extends Node

## Turns two moments into a held state: `on` sets `target` true, `off` sets it false.

## Sets `target` true.
@export var on: Event
## Optional. Sets `target` false.
@export var off: Event
## The bool this latch writes.
@export var target: BoolValue


func _ready() -> void:
	on.raised.connect(_on_on)
	if off != null:
		off.raised.connect(_on_off)


func _on_on(_payload: Variant) -> void:
	target.value = true


func _on_off(_payload: Variant) -> void:
	target.value = false
