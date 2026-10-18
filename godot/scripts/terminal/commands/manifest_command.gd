class_name ManifestCommand
extends Command

## MANIFEST prints HERALD's queue listing, once it has been pushed. Works any time after that.

## Read. True once the manifest push completed.
@export var manifest_received: BoolValue

## Read. The listing: ManifestItem resources.
@export var manifest: ResourceListValue

## Prints the listing, or NO MANIFEST before the push.
func run(_args: PackedStringArray) -> void:
	if not manifest_received.value:
		write("NO MANIFEST")
		return

	write(" HERALD QUEUE - %d ITEMS" % manifest.value.size())
	write(" ID   TYPE  SIZE  NOTE")

	for resource: Resource in manifest.value:
		var item := resource as ManifestItem
		write(" %-4d %-5s %-5d %s" % [item.id, item.type, item.size, item.note])
