class_name ManifestItem
extends Resource

## One product on HERALD's recorder, as the manifest lists it.

## The id the player types, e.g. `GET 21`.
@export var id := 0

## Product type: `AUTH`, `TLM`, `CAL`, `SPC` or `IMG`.
@export var type := ""

## Storage size in units. The download time scales with it.
@export var size := 1

## Rows (images) or segments (text, spectra) it arrives in.
@export var rows := 1

## Shown in the manifest's NOTE column.
@export var note := ""
