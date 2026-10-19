class_name EndingModel
extends Resource

## The four endings and how the verdict picks one: DESCEND with the evidence launches the Ark,
## DESCEND without it launches blind, TRANSFER waits for a second candidate, nothing is silence.

## Each piece of evidence as `TYPE NOTE` of a stored item, e.g. `IMG CANDRA NARROW`. Pictures
## count only once decoded.
@export var evidence := PackedStringArray(["IMG CANDRA NARROW", "SPC CANDRA"])

## Heading and text: DESCEND with every piece of evidence.
@export var ark_title := "THE ARK LAUNCHES"

## See `ark_title`.
@export_multiline var ark_text := ""

## Heading and text: DESCEND without the evidence.
@export var blind_title := "LAUNCH BLIND"

## See `blind_title`.
@export_multiline var blind_text := ""

## Heading and text: TRANSFER.
@export var transfer_title := "THE SECOND CANDIDATE"

## See `transfer_title`.
@export_multiline var transfer_text := ""

## Heading and text: no verdict sent.
@export var silence_title := "SILENCE"

## See `silence_title`.
@export_multiline var silence_text := ""

## The heading and text for the verdict in `sent`, judged by the items in `storage`.
func pick(sent: PackedStringArray, storage: Array[Resource]) -> PackedStringArray:
	for command: String in sent:
		if command == "DESCEND":
			if has_evidence(storage):
				return PackedStringArray([ark_title, ark_text])

			return PackedStringArray([blind_title, blind_text])

		if command == "TRANSFER":
			return PackedStringArray([transfer_title, transfer_text])

	return PackedStringArray([silence_title, silence_text])

## True when every piece of `evidence` is in `storage`, pictures decoded.
func has_evidence(storage: Array[Resource]) -> bool:
	for piece: String in evidence:
		var found := false
		for resource: Resource in storage:
			var stored := resource as StoredItem
			var named := "%s %s" % [stored.item.type, stored.item.note]
			if named == piece and (stored.item.type != "IMG" or stored.decoded):
				found = true

		if not found:
			return false

	return true
