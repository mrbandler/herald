class_name WallClock
extends Label3D

## Digital wall clock: counts down to the next mark, e.g. "UPLINK T-00:42", until LOS.
## After LOS it shows the station time of day instead, e.g. "02:51", running faster than real time.

## Read only. The time the next mark is measured from.
@export var pass_time: FloatValue
## Read only. Supplies the marks.
@export var current_pass: ResourceValue


func _ready() -> void:
	pass_time.updated.connect(_on_time)
	_refresh()


## Mark name and time left rounded up to whole seconds, e.g. "UPLINK T-00:43".
static func format(mark: PassMark) -> String:
	var total := ceili(mark.remaining)
	return "%s T-%02d:%02d" % [mark.name, floori(total / 60.0), total % 60]


## Time of day as "HH:MM" for `seconds` after midnight, wrapping at midnight.
static func format_time(seconds: float) -> String:
	var minutes := floori(seconds / 60.0)
	return "%02d:%02d" % [floori(minutes / 60.0) % 24, minutes % 60]


func _on_time(_previous: Variant, _current: Variant) -> void:
	_refresh()


func _refresh() -> void:
	var window := current_pass.value as PassWindow
	if window == null:
		text = ""
	elif pass_time.value >= window.los:
		text = WallClock.format_time(window.station_time(pass_time.value))
	else:
		text = WallClock.format(window.next_mark(pass_time.value))
