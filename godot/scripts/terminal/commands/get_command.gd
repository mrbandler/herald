class_name GetCommand
extends Command

## GET <ID>[, <ID>] queues manifest items for download into local storage. Needs the downlink,
## a held lock and the manifest. `Downlink` does the timed work.

## Supplies the storage capacity and the lookups.
@export var model: DownlinkModel

## Read. True while the downlink is open.
@export var downlink_open: BoolValue

## Read. GET needs a held lock to reach HERALD.
@export var locked: BoolValue

## Read. True once the manifest push completed.
@export var manifest_received: BoolValue

## Read. The listing: ManifestItem resources.
@export var manifest: ResourceListValue

## Read and written. Waiting ManifestItems; the head is the running one.
@export var download_queue: ResourceListValue

## Read. Local storage: StoredItem resources.
@export var storage: ResourceListValue

## Checks the link, then queues each named item in order.
func run(args: PackedStringArray) -> void:
	if args.is_empty():
		write("USAGE: GET <ID>[, <ID>]")
		return

	if not downlink_open.value:
		write("DOWNLINK CLOSED")
		return

	if not locked.value:
		write("NO SIGNAL LOCK")
		return

	if not manifest_received.value:
		write("NO MANIFEST")
		return

	for token: String in args:
		_queue(token)

## Queues one item, or writes why it cannot.
func _queue(token: String) -> void:
	var item := model.listed(manifest.value, token)
	if item == null:
		write("%s UNKNOWN ITEM" % token)
		return

	if model.stored(storage.value, token) != null:
		write("%s ALREADY STORED" % token)
		return

	if download_queue.value.has(item):
		write("%s ALREADY QUEUED" % token)
		return

	var used := model.units(storage.value) + model.units(download_queue.value)
	if used + item.size > model.storage_capacity:
		write("%s NOT ENOUGH SPACE" % token)
		return

	download_queue.add(item)
	write("%s QUEUED" % token)
