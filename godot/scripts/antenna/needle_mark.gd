class_name NeedleMark
extends Node3D

## A fixed tick on a gauge face at a ReceiverModel threshold.

## Gives the angle for a reading.
@export var needle_model: NeedleModel

## Supplies the threshold.
@export var receiver_model: ReceiverModel

## The ReceiverModel property the tick marks: `lock_on` on TUNE, `margin` on SIGNAL.
@export var threshold := "lock_on"

## Turns the tick to the threshold. A wrong property name fails loudly.
func _ready() -> void:
	assert(threshold in receiver_model, "NeedleMark: no ReceiverModel property " + threshold)
	var reading: float = receiver_model.get(threshold)
	rotation_degrees.z = needle_model.angle(reading)
