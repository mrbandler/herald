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

## The directory `target` names from `directory`, e.g. `USR:OKONJO/`. A colon makes it absolute,
## `..` goes one level up, and at the top a bare name is a volume. Empty is the top. It may not
## exist; see `exists`.
func resolve(directory: String, target: String) -> String:
	var upper := target.to_upper()
	if upper.is_empty():
		return ""

	if upper == "..":
		return _parent(directory)

	if not upper.contains(":"):
		return upper + ":" if directory.is_empty() else directory + upper + "/"

	return upper if upper.ends_with(":") or upper.ends_with("/") else upper + "/"

## The full path of the file `target` names from `directory`.
func file_path(directory: String, target: String) -> String:
	return target if target.contains(":") else directory + target

## True for the top, a known volume, or a directory holding an unlocked file.
func exists(directory: String, unlocked: PackedStringArray) -> bool:
	if directory.is_empty():
		return true

	var volume := directory.get_slice(":", 0)
	if not volumes.has(volume):
		return false

	return directory.ends_with(":") or not files_under(directory, unlocked).is_empty()

## The entries one level inside `directory`, named relative to it: subdirectories end in `/`.
func entries(directory: String, unlocked: PackedStringArray) -> PackedStringArray:
	var found := PackedStringArray()
	for file: StationFile in files_under(directory, unlocked):
		var rest := file.path.substr(directory.length())
		var entry := rest.get_slice("/", 0) + "/" if rest.contains("/") else rest
		if not found.has(entry):
			found.append(entry)

	return found

## The file's lines, without the empty one a trailing line break leaves.
func lines(file: StationFile) -> PackedStringArray:
	var text := file.body().rstrip("\n")
	return PackedStringArray() if text.is_empty() else text.split("\n")

## One level above `directory`: a directory's volume, or the top above a volume.
func _parent(directory: String) -> String:
	if not directory.ends_with("/"):
		return ""

	return directory.get_slice(":", 0) + ":"

## True when nothing unlocks `file`, or what unlocks it is in `unlocked`.
func _unlocked(file: StationFile, unlocked: PackedStringArray) -> bool:
	return file.unlocked_by.is_empty() or unlocked.has(file.unlocked_by)
