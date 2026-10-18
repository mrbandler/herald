class_name UnlockCommand
extends Command

## UNLOCK <MODULE> <ID> unlocks a decoder module with a stored, valid AUTH key. The key is used
## up and leaves storage; the module stays unlocked for the rest of the game.

## Supplies the modules, their banners and key validity.
@export var module_model: ModuleModel

## Looks the key up in storage.
@export var downlink_model: DownlinkModel

## Read and written. Local storage: StoredItem resources.
@export var storage: ResourceListValue

## Read and written. The modules unlocked so far. Kept across windows.
@export var unlocked_modules: StringListValue

## Raised with the module name, for the relay thunk and the bell.
@export var module_unlocked: Event

## Checks the module and the key, then unlocks and prints the banner.
func run(args: PackedStringArray) -> void:
	if args.size() != 2:
		write("USAGE: UNLOCK <MODULE> <ID>")
		return

	var module := args[0]
	var token := args[1]
	var stored := _usable_key(module, token)
	if stored == null:
		return

	unlocked_modules.value = unlocked_modules.value + PackedStringArray([module])
	storage.remove(stored)
	module_unlocked.raise(module)

	write(" -- %s MODULE UNLOCKED --" % module)
	for line: String in module_model.banner(module):
		write(" " + line)

## The stored key `token` names if it can unlock `module`, or null after writing why not.
func _usable_key(module: String, token: String) -> StoredItem:
	if not module_model.modules.has(module):
		write("%s UNKNOWN MODULE" % module)
		return null

	if unlocked_modules.value.has(module):
		write("%s ALREADY UNLOCKED" % module)
		return null

	var stored := downlink_model.stored(storage.value, token)
	if stored == null:
		write("%s UNKNOWN ITEM" % token)
		return null

	if stored.item.type != "AUTH":
		write("%s IS NOT AN AUTH BLOCK" % token)
		return null

	if stored.item.key_for != module:
		write("KEY DOES NOT FIT %s" % module)
		return null

	if not module_model.is_valid_key(stored):
		write("%s INVALID. %d ROWS MISSING" % [token, stored.missing()])
		return null

	return stored
