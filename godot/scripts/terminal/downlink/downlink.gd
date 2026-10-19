class_name Downlink
extends Node

## Runs the downlink: pushes HERALD's manifest at the first lock, then downloads the queue one item
## at a time, grading every row by the signal as it arrives. The uplink opening cuts it.

## The data rate and the progress formats.
@export var model: DownlinkModel

## Supplies the margin a clean row needs.
@export var receiver_model: ReceiverModel

## Read. The window whose manifest HERALD pushes.
@export var current_pass: ResourceValue

## Read. True between AOS and LOS.
@export var carrier_present: BoolValue

## Read. True once the uplink is open; the downlink is closed from then on.
@export var speak_open: BoolValue

## Read. Rows that arrive without lock are lost.
@export var locked: BoolValue

## Read. Rows below the margin arrive noisy.
@export var signal_strength: FloatValue

## Cuts the running download when the uplink opens.
@export var speak_opened: Event

## Written. True while the carrier is present and the uplink is not open.
@export var downlink_open: BoolValue

## Written. HERALD's pushed queue listing: ManifestItem resources.
@export var manifest: ResourceListValue

## Written. True once the manifest push completed.
@export var manifest_received: BoolValue

## Read. False when HERALD never heard last window's ACK: this window's AUTH keys are held back.
@export var ack_heard: BoolValue

## Read. The commands HERALD received last window; the ones this window's `requests` name add
## their products to the manifest.
@export var last_sent: StringListValue

## Read and written. AUTH ManifestItems held back for a missed ACK, released with the next
## manifest after an ACK. Kept across windows.
@export var held_keys: ResourceListValue

## Read and written. Waiting ManifestItems; the head is the running one.
@export var download_queue: ResourceListValue

## Written. Local storage: StoredItem resources. Kept across windows.
@export var storage: ResourceListValue

## Written. The image on the monitor while one downloads.
@export var shown_item: ResourceValue

## Written. STREAM while an image downloads, SNOW after.
@export var monitor_mode: IntValue

## Written. The running item with its rows so far, null while nothing runs. STAT reads it.
@export var running_item: ResourceValue

## Written. Rows of the running item that arrived, for STAT.
@export var download_received: IntValue

## Written. The terminal's progress line; empty while nothing arrives.
@export var progress_line: StringValue

## Receives the manifest's arrival line, so it stays in the scrollback. Usually stdout.
@export var out: StringEvent

## Raised when the manifest arrives, for its bell.
@export var manifest_arrived: Event

## Raised with short notices for the status bar.
@export var status_notice: StringEvent

## Raised for every row that arrives.
@export var row_received: Event

## Raised when an item completes.
@export var download_complete: Event

## Seconds into the manifest push.
var _push_elapsed := 0.0

## Seconds into the running item.
var _item_elapsed := 0.0

## The running item and its grades so far, or null between items.
var _running: StoredItem

## Listens for the uplink opening.
func _ready() -> void:
	speak_opened.raised.connect(_on_speak_opened)

## Advances the downlink each frame.
func _process(delta: float) -> void:
	tick(delta)

## Advances the manifest push, or the running item, by `delta` seconds.
func tick(delta: float) -> void:
	downlink_open.value = carrier_present.value and not speak_open.value

	var window := current_pass.value as PassWindow
	if window == null or window.manifest.is_empty():
		return

	if not manifest_received.value:
		_advance_push(window, delta)
		return

	if not download_queue.value.is_empty():
		_advance_item(delta)

## Advances the push while the downlink is open and locked. A lost lock restarts it.
func _advance_push(window: PassWindow, delta: float) -> void:
	if not downlink_open.value or not locked.value:
		# Clear only a push in progress: the uplink writes the line while the downlink is shut.
		if _push_elapsed > 0.0:
			_push_elapsed = 0.0
			progress_line.value = ""

		return

	_push_elapsed += delta
	if _push_elapsed < model.manifest_seconds:
		progress_line.value = model.manifest_line(_push_elapsed / model.manifest_seconds)
		return

	var items := _released(window)

	manifest.value = items
	manifest_received.value = true
	progress_line.value = ""
	status_notice.raise("MANIFEST RECEIVED. %d ITEMS" % items.size())
	out.raise("-- MANIFEST RECEIVED. %d ITEM(S). TYPE MANIFEST --" % items.size())
	if not ack_heard.value:
		out.raise(model.keys_held_line)

	manifest_arrived.raise()

## The items HERALD lists this window. After a heard ACK: the held keys first, then the window's
## manifest. After a missed one: the manifest without its AUTH keys, which join the held ones.
## Either way, the products of last window's commands come last.
func _released(window: PassWindow) -> Array[Resource]:
	var items: Array[Resource] = []
	if ack_heard.value:
		items.assign(held_keys.value + window.manifest)
		held_keys.clear()
	else:
		for item: ManifestItem in window.manifest:
			if item.type != "AUTH":
				items.append(item)
			elif not held_keys.value.has(item):
				held_keys.add(item)

	for command: String in last_sent.value:
		var product: Resource = window.requests.get(command)
		if product != null and not items.has(product):
			items.append(product)

	return items

## Grades every row that came due, and stores the item once its last row arrived.
func _advance_item(delta: float) -> void:
	var head := download_queue.value[0] as ManifestItem
	if _running == null or _running.item != head:
		_start(head)

	_item_elapsed += delta

	var due := model.rows_due(head, _item_elapsed)
	while _running.grades.size() < due:
		var margin := receiver_model.margin
		_running.grades.append(model.grade(locked.value, signal_strength.value, margin))
		row_received.raise()

	download_received.value = _running.arrived()
	progress_line.value = model.item_line(head, _running.sent(), _running.arrived())

	if _running.sent() < head.rows:
		return

	var notice := model.received_notice(_store_running())
	download_complete.raise()
	status_notice.raise(notice)

## Starts a fresh StoredItem for `item`.
func _start(item: ManifestItem) -> void:
	_running = StoredItem.new()
	_running.item = item
	_item_elapsed = 0.0
	running_item.value = _running

	if item.type == "IMG" or item.type == "CAL":
		shown_item.value = _running
		monitor_mode.value = MonitorModel.Mode.STREAM

## Moves the running item into storage, merged into an earlier copy if there is one, then off
## the queue, and clears the progress. Returns the copy now in storage.
func _store_running() -> StoredItem:
	var item := _running.item
	var kept := model.stored(storage.value, str(item.id))
	var result := _running if kept == null else model.merged(kept, _running)

	if kept == null:
		storage.add(result)
	else:
		storage.replace(kept, result)

	download_queue.remove(item)
	_clear_running()

	return result

## Forgets the running item and clears its progress.
func _clear_running() -> void:
	if monitor_mode.value == MonitorModel.Mode.STREAM:
		monitor_mode.value = MonitorModel.Mode.SNOW
		shown_item.value = null

	_running = null
	running_item.value = null
	_item_elapsed = 0.0
	download_received.value = 0
	progress_line.value = ""

## Cuts the running item into a partial, drops the queue and abandons an unfinished push. An
## item cut before its first row was sent is dropped: no rows, nothing stored.
func _on_speak_opened(_payload: Variant) -> void:
	downlink_open.value = false
	_push_elapsed = 0.0
	progress_line.value = ""

	if _running != null and _running.sent() > 0:
		status_notice.raise(model.cut_notice(_store_running()))
	else:
		_clear_running()

	download_queue.clear()
