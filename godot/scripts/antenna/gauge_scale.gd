class_name GaugeScale
extends Node3D

## Ticks spread evenly over a gauge face, from an empty reading to a full one, at the needle's
## angles.

## Gives the angle for a reading.
@export var needle_model: NeedleModel

## Ticks from empty to full, both ends included.
@export var ticks := 11

## Metres from the needle's pivot to a tick.
@export var radius := 0.083

## One tick's mesh.
@export var mark: Mesh

## Lays the ticks.
func _ready() -> void:
	for i: int in range(ticks):
		var pivot := Node3D.new()
		pivot.rotation_degrees.z = needle_model.angle(i / float(ticks - 1))

		var tick := MeshInstance3D.new()
		tick.mesh = mark
		tick.position = Vector3(0.0, radius, 0.0)
		pivot.add_child(tick)
		add_child(pivot)
