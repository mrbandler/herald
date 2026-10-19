class_name LsCommand
extends Command

## LS lists the working directory, or the volumes at the top. LS <DIR> lists that directory,
## absolute or relative: subdirectories with their file count, files with their length.

## The volumes and their files.
@export var volume_model: VolumeModel

## Read. Modules unlocked so far; some files only exist once their module is unlocked.
@export var unlocked_modules: StringListValue

## Read. The working directory, empty at the top. CD writes it.
@export var directory: StringValue

## Lists the working directory or the named one.
func run(args: PackedStringArray) -> void:
	if args.size() > 1:
		write("USAGE: LS [<DIR>]")
		return

	var target := directory.value
	if not args.is_empty():
		target = volume_model.resolve(directory.value, args[0])

	if target.is_empty():
		_list_volumes()
	else:
		_list_directory(target, args[0] if not args.is_empty() else target)

## One line per volume: SEALED, or how many files it holds.
func _list_volumes() -> void:
	for volume: String in volume_model.volumes:
		write(" %-5s %s" % [volume + ":", _count(volume)])

## SEALED, or `<n> FILE(S)` for `volume`.
func _count(volume: String) -> String:
	if volume_model.is_sealed(volume, unlocked_modules.value):
		return "SEALED"

	var count := volume_model.files_under(volume + ":", unlocked_modules.value).size()
	return "%d FILE(S)" % count

## The entries of `target`, one per line, or why it cannot be listed. `typed` names it in errors.
func _list_directory(target: String, typed: String) -> void:
	var volume := target.get_slice(":", 0)
	if not volume_model.volumes.has(volume):
		write("%s UNKNOWN VOLUME" % volume)
		return

	if volume_model.is_sealed(volume, unlocked_modules.value):
		write(" %s: SEALED" % volume)
		return

	if not volume_model.exists(target, unlocked_modules.value):
		write("%s NOT FOUND" % typed)
		return

	var names := volume_model.entries(target, unlocked_modules.value)
	if names.is_empty():
		write(" NO FILES")
		return

	for entry: String in names:
		write(" %-30s %s" % [entry, _size(target + entry)])

## `<n> FILE(S)` for a subdirectory, `<n> LINE(S)` for a file.
func _size(path: String) -> String:
	if path.ends_with("/"):
		return "%d FILE(S)" % volume_model.files_under(path, unlocked_modules.value).size()

	var file := volume_model.find(path, unlocked_modules.value)
	return "%d LINE(S)" % volume_model.lines(file).size()
