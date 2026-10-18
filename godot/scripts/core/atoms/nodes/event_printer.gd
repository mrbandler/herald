class_name EventPrinter
extends Node

## Writes a fixed line to a StringEvent (usually stdout) whenever an event fires.

## Fires the line. Its payload is ignored.
@export var event: Event
## The fixed line to write, e.g. `-- LOS. CARRIER LOST. --`.
@export var text: String
## Receives the line. Usually stdout.
@export var out: StringEvent


func _ready() -> void:
	event.raised.connect(_on_raised)


func _on_raised(_payload: Variant) -> void:
	out.raise(text)
