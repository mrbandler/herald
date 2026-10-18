class_name PassClock
extends Node

## Moves pass_time forward every frame until the shift ends.

## Advanced by the frame time while running.
@export var pass_time: FloatValue

## Stops the clock when raised.
@export var shift_ended: Event

## False once the shift has ended.
var running := true

## Stops the clock once the shift ends.
func _ready() -> void:
	shift_ended.raised.connect(_on_shift_ended)

## Advances the clock by the frame time.
func _process(delta: float) -> void:
	tick(delta)

## Advances `pass_time` by `delta` seconds while running.
func tick(delta: float) -> void:
	if running:
		pass_time.value += delta

## Stops the clock.
func _on_shift_ended(_payload: Variant) -> void:
	running = false
