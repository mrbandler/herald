class_name ManifestCommand
extends Command

## MANIFEST prints HERALD's queue listing, once it has been pushed, with each item's state at
## the station: queued, stored, or stored but damaged. Works any time after that.

## Read. True once the manifest push completed.
@export var manifest_received: BoolValue

## Read. The listing: ManifestItem resources.
@export var manifest: ResourceListValue

## Read. Items waiting for or in download.
@export var download_queue: ResourceListValue

## Read. What is stored: StoredItem resources.
@export var storage: ResourceListValue

## Finds stored copies by id.
@export var model: DownlinkModel

## Written. True once the listing was shown, so the progress row stops pointing at it.
@export var manifest_seen: BoolValue

## Prints the listing, or NO MANIFEST before the push.
func run(_args: PackedStringArray) -> void:
	if not manifest_received.value:
		write("NO MANIFEST")
		return

	manifest_seen.value = true
	write(" HERALD QUEUE - %d ITEMS" % manifest.value.size())
	write(" ID   TYPE  SIZE  STATE    NOTE")

	for resource: Resource in manifest.value:
		var item := resource as ManifestItem
		var columns := [item.id, item.type, item.size, _state(item), item.note]
		write((" %-4d %-5s %-5d %-8s %s" % columns).rstrip(" "))

## QUEUED while waiting or downloading, STORED for a clean copy, DAMAGED for one GET can fetch
## again, and NONE before any of that.
func _state(item: ManifestItem) -> String:
	if download_queue.value.has(item):
		return "QUEUED"

	var kept := model.stored(storage.value, str(item.id))
	if kept == null:
		return "NONE"

	return "STORED" if kept.clean() == item.rows else "DAMAGED"
