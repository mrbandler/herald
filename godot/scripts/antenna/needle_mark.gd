class_name NeedleMark
extends Node3D

## A fixed tick on a gauge face at the reading where the receiver locks.

## Gives the angle for a reading.
@export var needle_model: NeedleModel
## Supplies the lock threshold.
@export var receiver_model: ReceiverModel


func _ready() -> void:
	rotation_degrees.z = needle_model.angle(receiver_model.lock_on)
