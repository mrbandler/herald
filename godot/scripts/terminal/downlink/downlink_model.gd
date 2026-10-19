class_name DownlinkModel
extends Resource

## The downlink's numbers: data rate, manifest push, storage, and how rows and progress read.

## How a row arrived.
enum Grade {
	CLEAN,
	NOISY,
	LOST,
}

## Seconds per unit of item size. Fixed per pass: the link decides quality, not speed.
@export var seconds_per_unit := 15.0

## Seconds HERALD takes to push its manifest.
@export var manifest_seconds := 3.0

## Local storage capacity in units.
@export var storage_capacity := 8

## Characters inside the progress bar's brackets. The game's 29 fills the screen's width with
## the longest line, `RECV 123 AUTH [...] 480/480`, beside the storage readout.
@export var bar_width := 10

## Lost without lock, noisy below the `margin` signal strength, clean at or above it.
func grade(locked: bool, strength: float, margin: float) -> Grade:
	if not locked:
		return Grade.LOST

	return Grade.CLEAN if strength >= margin else Grade.NOISY

## Seconds the whole item takes to download.
func seconds_for(item: ManifestItem) -> float:
	return item.size * seconds_per_unit

## Rows that have arrived `elapsed` seconds into the item. Row k arrives after k intervals.
func rows_due(item: ManifestItem, elapsed: float) -> int:
	# The epsilon keeps floating point from skipping the last row.
	var due := floori(elapsed * item.rows / seconds_for(item) + 0.0001)
	return clampi(due, 0, item.rows)

## A progress bar such as `[######----]` for `fraction` 0..1, `bar_width` wide.
func bar(fraction: float) -> String:
	return DownlinkModel.draw_bar(fraction, bar_width)

## A progress bar `width` characters inside its brackets. The uplink draws with it too.
static func draw_bar(fraction: float, width: int) -> String:
	var filled := clampi(floori(fraction * width), 0, width)
	return "[" + "#".repeat(filled) + "-".repeat(width - filled) + "]"

## The running item's progress line, e.g. `RECV 21 AUTH [######----] 9/16`: the bar shows the
## rows sent, the count the rows that arrived.
func item_line(item: ManifestItem, sent: int, arrived: int) -> String:
	var progress := bar(float(sent) / item.rows)
	return "RECV %d %s %s %d/%d" % [item.id, item.type, progress, arrived, item.rows]

## The status notice of a completed item, e.g. `21 RECEIVED 15/16. CLEAN 14 NOISY 1 LOST 1`.
func received_notice(stored_item: StoredItem) -> String:
	return "%d RECEIVED %s" % [stored_item.item.id, tally(stored_item)]

## The status notice of an item cut by the uplink, e.g. `21 CUT 9/16. CLEAN 8 NOISY 1 LOST 1`.
func cut_notice(stored_item: StoredItem) -> String:
	return "%d CUT %s" % [stored_item.item.id, tally(stored_item)]

## `15/16. CLEAN 14 NOISY 1 LOST 1`: arrived rows of the total, then the rows by grade. STAT and
## the notices share it.
func tally(stored_item: StoredItem) -> String:
	var counts := [stored_item.clean(), stored_item.noisy(), stored_item.lost()]
	var arrived := "%d/%d. " % [stored_item.arrived(), stored_item.item.rows]
	return arrived + "CLEAN %d NOISY %d LOST %d" % counts

## The manifest push's progress line, e.g. `RECV MANIFEST [#####-----]`.
func manifest_line(fraction: float) -> String:
	return "RECV MANIFEST " + bar(fraction)

## `kept` with each row at its better grade from `kept` and `again`, a second download of the
## same item. A row only one copy sent keeps that copy's grade.
func merged(kept: StoredItem, again: StoredItem) -> StoredItem:
	var best := kept.duplicate() as StoredItem
	var grades := PackedByteArray()
	for row: int in range(maxi(kept.sent(), again.sent())):
		var first: int = kept.grades[row] if row < kept.sent() else Grade.LOST
		var second: int = again.grades[row] if row < again.sent() else Grade.LOST
		grades.append(mini(first, second))

	best.grades = grades
	return best

## Units a list of ManifestItems or StoredItems takes.
func units(resources: Array[Resource]) -> int:
	var total := 0
	for resource: Resource in resources:
		total += size_of(resource)

	return total

## Units one ManifestItem or StoredItem takes: 1 for a decoded image, its size otherwise.
func size_of(resource: Resource) -> int:
	var kept := resource as StoredItem
	if kept != null:
		return 1 if kept.decoded else kept.item.size

	return (resource as ManifestItem).size

## Units the queue adds on top of storage: an item already stored is fetched again into the same
## place, so it adds nothing.
func queued_units(queue: Array[Resource], storage: Array[Resource]) -> int:
	var total := 0
	for resource: Resource in queue:
		var item := resource as ManifestItem
		if stored(storage, str(item.id)) == null:
			total += item.size

	return total

## The ManifestItem whose id is `token`, or null. A token that isn't a whole number matches none.
func listed(items: Array[Resource], token: String) -> ManifestItem:
	if not token.is_valid_int():
		return null

	for resource: Resource in items:
		var item := resource as ManifestItem
		if item.id == token.to_int():
			return item

	return null

## The StoredItem whose item id is `token`, or null.
func stored(items: Array[Resource], token: String) -> StoredItem:
	if not token.is_valid_int():
		return null

	for resource: Resource in items:
		var stored_item := resource as StoredItem
		if stored_item.item.id == token.to_int():
			return stored_item

	return null
