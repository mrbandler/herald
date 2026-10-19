class_name Checkpoint
extends Node

## Remembers the atoms that carry the campaign as each window starts, so a lost game can retry
## that window, or start over from the first. Kept in memory for the session only.

## What every room load saved, by atom. Static, so it outlives the room's reload.
static var _saved: Dictionary[Value, Variant] = { }

## The atoms that carry the campaign from window to window.
@export var atoms: Array[Value] = []

## Saves the window that is starting.
func _ready() -> void:
	save()

## Remembers every atom's value.
func save() -> void:
	_saved.clear()
	for atom: Value in atoms:
		_saved[atom] = atom.snapshot()

## Puts every atom back to how the window started.
func retry() -> void:
	for atom: Value in atoms:
		if _saved.has(atom):
			atom.restore(_saved[atom])

## Resets every atom, so the next room load starts at window 1.
func start_over() -> void:
	for atom: Value in atoms:
		atom.reset()
