class_name LsCommand
extends Command

## LS lists the volumes with their file counts. LS <VOL:> lists that volume's files, and text
## after the colon narrows them by prefix.

## The volumes and their files.
@export var volume_model: VolumeModel

## Read. Modules unlocked so far; some files only exist once their module is unlocked.
@export var unlocked_modules: StringListValue

## Lists the volumes, or one volume's files.
func run(args: PackedStringArray) -> void:
	if args.size() > 1:
		write("USAGE: LS [<VOL:>]")
		return

	if args.is_empty():
		_list_volumes()
	else:
		_list_files(args[0])

## One line per volume: SEALED, or how many files it holds.
func _list_volumes() -> void:
	for volume: String in volume_model.volumes:
		write(" %-5s %s" % [volume + ":", _count(volume)])

## SEALED, NO FILES, 1 FILE or <N> FILES for `volume`.
func _count(volume: String) -> String:
	if volume_model.sealed.has(volume):
		return "SEALED"

	var count := volume_model.files_under(volume + ":", unlocked_modules.value).size()
	if count == 0:
		return "NO FILES"

	return "1 FILE" if count == 1 else "%d FILES" % count

## The files under `target`, e.g. `USR`, `USR:` or `USR:OKONJO`, one per line with its length.
func _list_files(target: String) -> void:
	var prefix := target if target.contains(":") else target + ":"
	var volume := prefix.get_slice(":", 0)
	if not volume_model.volumes.has(volume):
		write("%s UNKNOWN VOLUME" % volume)
		return

	if volume_model.sealed.has(volume):
		write(" %s: SEALED" % volume)
		return

	var found := volume_model.files_under(prefix, unlocked_modules.value)
	if found.is_empty():
		write(" NO FILES")
		return

	for file: StationFile in found:
		var count := volume_model.lines(file).size()
		var unit := "LINE" if count == 1 else "LINES"
		write(" %-30s %3d %s" % [file.path, count, unit])
