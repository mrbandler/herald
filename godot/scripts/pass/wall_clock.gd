class_name WallClock
extends Label3D

## Digital wall clock: the station time of day, e.g. "02:51". Real time until LOS, faster after.
## The countdowns to the marks are on the terminal's status bar.

## Read only. Seconds into the pass, turned into the time of day.
@export var pass_time: FloatValue

## Read only. Supplies the clock start and the night rate.
@export var current_pass: ResourceValue

## Redraws on every change of `pass_time` and draws the first reading.
func _ready() -> void:
	pass_time.updated.connect(_on_time)
	_refresh()

## Time of day as "HH:MM" for `seconds` after midnight, wrapping at midnight.
static func format_time(seconds: float) -> String:
	var minutes := floori(seconds / 60.0)
	return "%02d:%02d" % [floori(minutes / 60.0) % 24, minutes % 60]

## Redraws the clock.
func _on_time(_previous: Variant, _current: Variant) -> void:
	_refresh()

## Shows the station time, and nothing without a pass.
func _refresh() -> void:
	var window := current_pass.value as PassWindow
	text = "" if window == null else WallClock.format_time(window.station_time(pass_time.value))
