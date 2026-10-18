class_name BoolPrinter
extends Node

## Writes a line to a StringEvent (usually stdout) whenever a BoolValue turns on or off.

## Watched for changes.
@export var source: BoolValue
## Written when `source` turns true, e.g. `-- LOCK --`.
@export var on_text: String
## Written when `source` turns false.
@export var off_text: String
## Receives the lines. Usually stdout.
@export var out: StringEvent


func _ready() -> void:
	source.updated.connect(_on_updated)


func _on_updated(_previous: Variant, current: Variant) -> void:
	out.raise(on_text if current else off_text)
