class_name CdCommand
extends Command

## CD <DIR> changes the working directory: absolute or relative, `..` one level up, and CD
## alone back to the top. The prompt shows where the player is.

## The volumes and their files.
@export var volume_model: VolumeModel

## Read. Modules unlocked so far; a directory exists once it holds an unlocked file.
@export var unlocked_modules: StringListValue

## Written. The working directory, empty at the top.
@export var directory: StringValue

## Changes into the named directory, or writes why not.
func run(args: PackedStringArray) -> void:
	if args.size() > 1:
		write("USAGE: CD [<DIR>]")
		return

	var target := volume_model.resolve(directory.value, args[0] if not args.is_empty() else "")
	var volume := target.get_slice(":", 0)

	if not target.is_empty() and not volume_model.volumes.has(volume):
		write("%s UNKNOWN VOLUME" % volume)
	elif volume_model.sealed.has(volume):
		write(" %s: SEALED" % volume)
	elif not volume_model.exists(target, unlocked_modules.value):
		write("%s NOT FOUND" % args[0])
	else:
		directory.value = target
