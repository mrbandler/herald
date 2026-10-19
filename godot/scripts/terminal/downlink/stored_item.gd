class_name StoredItem
extends Resource

## A downloaded item in local storage, with the grade of every row that arrived.

## The manifest entry it was downloaded from.
@export var item: ManifestItem

## One `DownlinkModel.Grade` per row HERALD sent, in order. A LOST row was sent but never
## arrived. Shorter than `item.rows` for a partial item; the rest were never sent.
@export var grades := PackedByteArray()

## The player's label, set with TAG. Empty for none.
@export var tag := ""

## Rows HERALD sent so far, arrived or lost.
func sent() -> int:
	return grades.size()

## Rows that arrived clean.
func clean() -> int:
	return _count(DownlinkModel.Grade.CLEAN)

## Rows that arrived noisy.
func noisy() -> int:
	return _count(DownlinkModel.Grade.NOISY)

## Rows sent without lock, so they never arrived.
func lost() -> int:
	return _count(DownlinkModel.Grade.LOST)

## Rows that arrived, clean or noisy.
func arrived() -> int:
	return clean() + noisy()

## Rows with `grade`.
func _count(grade: int) -> int:
	var count := 0
	for row: int in grades:
		if row == grade:
			count += 1

	return count

## Rows that never arrived: lost ones and the ones never sent.
func missing() -> int:
	return item.rows - arrived()
