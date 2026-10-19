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

## A progress bar such as `[######----]` for `fraction` 0..1.
func bar(fraction: float) -> String:
	var filled := clampi(floori(fraction * bar_width), 0, bar_width)
	return "[" + "#".repeat(filled) + "-".repeat(bar_width - filled) + "]"

## The running item's progress line, e.g. `RECV 21 AUTH [######----] 9/16`: the bar shows the
## rows sent, the count the rows that arrived.
func item_line(item: ManifestItem, sent: int, arrived: int) -> String:
	var progress := bar(float(sent) / item.rows)
	return "RECV %d %s %s %d/%d" % [item.id, item.type, progress, arrived, item.rows]

## The status notice of a completed item, e.g. `21 RECEIVED 15/16. CLEAN 14 NOISY 1 LOST 1`.
func received_notice(stored_item: StoredItem) -> String:
	return "%d RECEIVED %s" % [stored_item.item.id, _tally(stored_item)]

## The status notice of an item cut by the uplink, e.g. `21 CUT 9/16. CLEAN 8 NOISY 1 LOST 1`.
func cut_notice(stored_item: StoredItem) -> String:
	return "%d CUT %s" % [stored_item.item.id, _tally(stored_item)]

## `15/16. CLEAN 14 NOISY 1 LOST 1`: arrived rows of the total, then the rows by grade.
func _tally(stored_item: StoredItem) -> String:
	var counts := [stored_item.clean(), stored_item.noisy(), stored_item.lost()]
	var arrived := "%d/%d. " % [stored_item.arrived(), stored_item.item.rows]
	return arrived + "CLEAN %d NOISY %d LOST %d" % counts

## The manifest push's progress line, e.g. `RECV MANIFEST [#####-----]`.
func manifest_line(fraction: float) -> String:
	return "RECV MANIFEST " + bar(fraction)

## Units taken by a list of ManifestItems or StoredItems.
func units(resources: Array[Resource]) -> int:
	var total := 0
	for resource: Resource in resources:
		var kept := resource as StoredItem
		var item := kept.item if kept != null else resource as ManifestItem
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
