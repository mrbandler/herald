class_name LinkModePrinter
extends Node

## On lock, writes which way the link runs: HERALD speaking (downlink) until the uplink opens,
## then listening. Sits after the lock printer so the mode follows the lock line.

## Watched. Only a gained lock prints.
@export var locked: BoolValue
## Read. Picks the uplink line while true.
@export var uplink_open: BoolValue
@export var downlink_text: String
@export var uplink_text: String
## Receives the lines. Usually stdout.
@export var out: StringEvent


func _ready() -> void:
	locked.updated.connect(_on_locked)


func _on_locked(_previous: bool, current: bool) -> void:
	if current:
		out.raise(uplink_text if uplink_open.value else downlink_text)
