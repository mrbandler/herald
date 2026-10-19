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

## For an AUTH item: the module it unlocks, e.g. `TLM`. Empty otherwise.
@export var key_for := ""

## For a text item: what DECODE shows, one line per line break.
@export_multiline var content := ""

## For an IMG or CAL item: the picture HERALD sends, row by row.
@export var image: Texture2D

## For an IMG or CAL item: the true line length, in LINE knob units (85 to 115).
@export var line_length := 100.0

## For an IMG or CAL item: where a line truly starts, 0..1, found with OFFSET.
@export var phase := 0.0
