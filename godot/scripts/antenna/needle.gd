class_name Needle
extends Node3D

## Signal-strength needle. Rotates around its local Z axis.

## Model to use.
@export var model: NeedleModel

## The 0..1 reading the needle follows.
@export var source: FloatValue

## Current needle position, 0..1. Lags behind `source`.
var reading := 0.0

## Current needle speed, in readings per second.
var _velocity := 0.0

## Springs the needle each frame.
func _process(delta: float) -> void:
	tick(delta)

## Springs the reading toward `source` for one frame and rotates the needle.
func tick(delta: float) -> void:
	var state := model.step(reading, _velocity, source.value, delta)
	reading = state.x
	_velocity = state.y
	rotation_degrees.z = model.angle(reading)
