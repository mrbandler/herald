class_name StationFile
extends Resource

## A file on one of the station's volumes: where it lives, what it says, and what unlocks it.

## The full path with its volume, e.g. `USR:OKONJO/WAKE.TXT`.
@export var path := ""

## The file's text, authored at 64 columns or less so the popup never wraps it.
@export_multiline var text := ""

## The module that makes the file exist, e.g. `TLM`. Empty for always.
@export var unlocked_by := ""

## The volume part of the path, before the colon, e.g. `USR`.
func volume() -> String:
	return path.get_slice(":", 0)
