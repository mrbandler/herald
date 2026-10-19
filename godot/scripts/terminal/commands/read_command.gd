class_name ReadCommand
extends Command

## READ <FILE> opens a station file in the popup on the CRT. A missing or locked file is NOT
## FOUND, so a locked file gives nothing away.

## The volumes and their files.
@export var volume_model: VolumeModel

## Read. Modules unlocked so far; some files only exist once their module is unlocked.
@export var unlocked_modules: StringListValue

## Written. The open file's path, as the file spells it. The FileViewer shows it.
@export var viewing: StringValue

## Opens the named file, or writes why not.
func run(args: PackedStringArray) -> void:
	if args.size() != 1:
		write("USAGE: READ <FILE>")
		return

	var file := volume_model.find(args[0], unlocked_modules.value)
	if file == null:
		write("%s NOT FOUND" % args[0])
		return

	viewing.value = file.path
