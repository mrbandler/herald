class_name Resetter
extends Node

## Resets a list of atoms to their defaults when it enters the tree.
## Put it first in its scene: its `_ready` must run before siblings read or connect to them.

@export var atoms: Array[Value] = []


func _ready() -> void:
	for atom: Value in atoms:
		atom.reset()
