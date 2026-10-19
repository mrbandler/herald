class_name StatCommand
extends Command

## STAT shows the running download with its rows by grade, and the items waiting behind it.

## Read. Waiting ManifestItems; the head is the running one.
@export var download_queue: ResourceListValue

## Read. The running item with its rows so far, null before its first row is due.
@export var running_item: ResourceValue

## Counts the rows by grade.
@export var model: DownlinkModel

## Prints the running item with its rows by grade, then the queue, or NO DOWNLOADS.
func run(_args: PackedStringArray) -> void:
	if download_queue.value.is_empty():
		write("NO DOWNLOADS")
		return

	var head := download_queue.value[0] as ManifestItem
	var running := running_item.value as StoredItem
	if running == null or running.item != head:
		running = StoredItem.new()
		running.item = head

	write("RECV %d %s %s" % [head.id, head.type, model.tally(running)])

	for i: int in range(1, download_queue.value.size()):
		var waiting := download_queue.value[i] as ManifestItem
		write("QUEUED %d %s" % [waiting.id, waiting.type])
