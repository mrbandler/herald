class_name WallClock
extends Label3D

## The mission clock on the wall: time since HERALD's launch, still counting, e.g.
## "T+ 214Y 117D" over "02:47:13". One window per night; the time of day is the station's.

## Seconds in a day.
const DAY := 86400.0

## Days in a mission year.
const YEAR_DAYS := 365

## Mission days at midnight before window 1.
@export var epoch_days := 214 * YEAR_DAYS + 117

## Read only. Seconds into the pass.
@export var pass_time: FloatValue

## Read only. Supplies the window number and the clock start.
@export var current_pass: ResourceValue

## Redraws on every change of `pass_time` and draws the first reading.
func _ready() -> void:
	pass_time.updated.connect(_on_time)
	_refresh()

## The mission clock for `seconds` since launch, e.g. "T+ 214Y 117D\n02:47:13".
static func format_mission(seconds: float) -> String:
	var days := floori(seconds / DAY)
	var day_part := "T+ %dY %03dD" % [floori(days / float(YEAR_DAYS)), days % YEAR_DAYS]
	return "%s\n%s" % [day_part, PassWindow.format_time(seconds)]

## Redraws the clock.
func _on_time(_previous: Variant, _current: Variant) -> void:
	_refresh()

## Shows the mission time, and nothing without a pass.
func _refresh() -> void:
	var window := current_pass.value as PassWindow
	text = "" if window == null else WallClock.format_mission(mission_seconds())

## Seconds since launch at the current pass time; one day per window. 0 without a pass.
func mission_seconds() -> float:
	var window := current_pass.value as PassWindow
	if window == null:
		return 0.0

	var days := epoch_days + window.number - 1
	return days * DAY + window.station_time(pass_time.value)
