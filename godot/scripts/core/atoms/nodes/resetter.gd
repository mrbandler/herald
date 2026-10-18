class_name Resetter
extends Node

## Resets a list of atoms to their defaults when it enters the tree.
## Put it first in its scene: its `_ready` must run before siblings read or connect to them.

## Reset to their defaults on ready.
@export var atoms: Array[Value] = []

## Resets every atom in `atoms`.
func _ready() -> void:
	for atom: Value in atoms:
		atom.reset()
