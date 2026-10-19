class_name MonitorModel
extends Resource

## The slow-scan monitor: what each mode shows, how a stream of samples becomes a picture at a
## given LINE and OFFSET, and the look. The screen's shader mirrors `source`.

## What the monitor shows.
enum Mode {
	SNOW,
	STREAM,
	TUNE,
	SHOW,
}

## A row's state in the row-state texture. The first three match `DownlinkModel.Grade`.
enum RowState {
	CLEAN,
	NOISY,
	LOST,
	UNSENT,
}

## LINE a CAL preset is off by, in knob units: the old decoder sets the knobs close, never exact.
@export var cal_line_error := 0.15

## OFFSET a CAL preset is off by, as a share of a line.
@export var cal_offset_error := 0.04

## How much snow a noisy row mixes into the picture, 0..1.
@export var noise := 0.6

## Rows behind the newest that still glow yellow-green while streaming.
@export var afterglow_rows := 6.0

## A 1-row image, one byte per image row: its grade, or UNSENT for a row not sent yet.
func row_states(stored: StoredItem) -> Image:
	var rows := maxi(stored.item.rows, 1)
	var bytes := PackedByteArray()
	bytes.resize(rows)
	for row: int in range(rows):
		bytes[row] = stored.grades[row] if row < stored.sent() else RowState.UNSENT

	return Image.create_from_data(rows, 1, false, Image.FORMAT_R8, bytes)

## Where screen point (`u`, `v`) samples the picture: (column, source row). The stream position
## is (screen row + u) × `k` + `phase` − `offset`, with `k` = LINE / true line. A row outside
## the picture comes back as −1.
func source(u: float, v: float, rows: int, k: float, phase: float, offset: float) -> Vector2:
	var screen_row := floorf(v * rows)
	var position := (screen_row + u) * k + phase - offset
	var row := floorf(position)
	if row < 0.0 or row >= rows:
		return Vector2(position - row, -1.0)

	return Vector2(position - row, row)

## LINE, OFFSET and CONTRAST the screen uses in `mode`: the committed tuning on SHOW, the knobs
## otherwise, so a stream arrives as slanted as the monitor is set.
func settings(mode: Mode, stored: StoredItem, knobs: Vector3) -> Vector3:
	return stored.tuning if mode == Mode.SHOW else knobs

## LINE and OFFSET a stored `cal` presets for `image`: the CAL's line and the image's offset, each a
## little off. A CAL from the other camera brings that camera's line.
func from_cal(image: ManifestItem, cal: ManifestItem) -> Vector2:
	return Vector2(cal.line_length + cal_line_error, fposmod(image.phase + cal_offset_error, 1.0))
