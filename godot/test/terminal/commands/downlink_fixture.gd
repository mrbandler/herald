class_name DownlinkFixture
extends RefCounted

## Manifest and stored items for the downlink command tests.

static func item(id: int, type: String, size: int, rows: int, note: String = "") -> ManifestItem:
	var listed := ManifestItem.new()
	listed.id = id
	listed.type = type
	listed.size = size
	listed.rows = rows
	listed.note = note
	return listed

static func stored(listed: ManifestItem, grades: Array[int]) -> StoredItem:
	var kept := StoredItem.new()
	kept.item = listed
	kept.grades = PackedByteArray(grades)
	return kept

static func list(resources: Array[Resource]) -> ResourceListValue:
	var atom := ResourceListValue.new()
	atom.value = resources
	return atom
