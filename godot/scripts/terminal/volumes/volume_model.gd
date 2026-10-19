class_name VolumeModel
extends Resource

## The station's volumes and files: which volumes exist, which are sealed, and which files are
## unlocked.

## The volumes in the order LS lists them.
@export var volumes := PackedStringArray(["HTB", "USR", "SYS", "ARC"])

## Volumes that list as SEALED and show no files.
@export var sealed := PackedStringArray(["ARC"])

## Every file on every volume, in the order LS lists them.
@export var files: Array[StationFile] = []

## The unlocked files whose path starts with `prefix`, ignoring case.
func files_under(prefix: String, unlocked: PackedStringArray) -> Array[StationFile]:
	var found: Array[StationFile] = []
	for file: StationFile in files:
		if file.path.to_upper().begins_with(prefix.to_upper()) and _unlocked(file, unlocked):
			found.append(file)

	return found

## The unlocked file at `path`, ignoring case, or null when it is missing or locked.
func find(path: String, unlocked: PackedStringArray) -> StationFile:
	for file: StationFile in files:
		if file.path.to_upper() == path.to_upper() and _unlocked(file, unlocked):
			return file

	return null

## The file's lines, without the empty one a trailing line break leaves.
func lines(file: StationFile) -> PackedStringArray:
	var text := file.text.rstrip("\n")
	return PackedStringArray() if text.is_empty() else text.split("\n")

## True when nothing unlocks `file`, or what unlocks it is in `unlocked`.
func _unlocked(file: StationFile, unlocked: PackedStringArray) -> bool:
	return file.unlocked_by.is_empty() or unlocked.has(file.unlocked_by)
