class_name PassMark
extends RefCounted

## The next mark of a pass and the seconds left until it.

## One of `PassWindow.MARK_NAMES`.
var name: String

## Seconds until the mark, 0 after the bell.
var remaining: float

## A mark named `p_name`, `p_remaining` seconds away.
func _init(p_name: String, p_remaining: float) -> void:
	name = p_name
	remaining = p_remaining
