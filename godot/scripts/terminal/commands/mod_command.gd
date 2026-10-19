class_name ModCommand
extends Command

## MOD lists HERALD's decoder modules and whether each is locked or unlocked.

## Supplies the module names, in order.
@export var module_model: ModuleModel

## Read. The modules unlocked so far. Kept across windows.
@export var unlocked_modules: StringListValue

## The help, then every module with what it does, locked or not: knowing a module is the
## reason to look for its key.
func help_text() -> String:
	var lines := PackedStringArray([help, "MODULES:"])
	for module: String in module_model.modules:
		var description: String = module_model.descriptions.get(module, "")
		lines.append(("%-18s%s" % [module, description]).strip_edges())

	return "\n".join(lines)

## Prints one line per module, or the usage when given arguments.
func run(args: PackedStringArray) -> void:
	if not args.is_empty():
		write("USAGE: MOD")
		return

	for module: String in module_model.modules:
		var state := "UNLOCKED" if unlocked_modules.value.has(module) else "LOCKED"
		write(" %-4s %s" % [module, state])
