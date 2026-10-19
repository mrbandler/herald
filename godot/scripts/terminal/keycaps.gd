class_name Keycaps
extends MultiMeshInstance3D

## Lays a grid of keycaps on the keyboard, centred on this node: `rows` by `columns`, `pitch`
## apart. Looks only; typing comes from the real keyboard.

## Rows of keys, front to back.
@export var rows := 4

## Keys per row.
@export var columns := 13

## Metres from one key's centre to the next.
@export var pitch := 0.028

## One keycap's size in metres.
@export var cap_size := Vector3(0.021, 0.008, 0.021)

## Builds the caps.
func _ready() -> void:
	var cap := BoxMesh.new()
	cap.size = cap_size

	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = cap
	var spots := positions()
	multimesh.instance_count = spots.size()
	for i: int in range(spots.size()):
		multimesh.set_instance_transform(i, Transform3D(Basis.IDENTITY, spots[i]))

## Every keycap's centre, row by row, centred on this node.
func positions() -> PackedVector3Array:
	var spots := PackedVector3Array()
	for row: int in range(rows):
		for column: int in range(columns):
			var x := (column - (columns - 1) / 2.0) * pitch
			var z := (row - (rows - 1) / 2.0) * pitch
			spots.append(Vector3(x, 0.0, z))

	return spots
