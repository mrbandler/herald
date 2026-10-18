class_name StatCommand
extends Command

## STAT shows the running download and the items waiting behind it.

## Read. Waiting ManifestItems; the head is the running one.
@export var download_queue: ResourceListValue

## Read. Rows of the running item that arrived.
@export var download_received: IntValue

## Prints the running item and the queue, or NO DOWNLOADS.
func run(_args: PackedStringArray) -> void:
	if download_queue.value.is_empty():
		write("NO DOWNLOADS")
		return

	var head := download_queue.value[0] as ManifestItem
	write("RECV %d %s %d/%d" % [head.id, head.type, download_received.value, head.rows])

	for i: int in range(1, download_queue.value.size()):
		var waiting := download_queue.value[i] as ManifestItem
		write("QUEUED %d %s" % [waiting.id, waiting.type])
