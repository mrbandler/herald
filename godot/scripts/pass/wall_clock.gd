class_name WallClock
extends Label3D

## Digital wall clock: counts down to the next mark and names it, e.g. "SPEAK T-00:42".

## Read only. The time the next mark is measured from.
@export var pass_time: FloatValue
## Read only. Supplies the marks.
@export var current_pass: ResourceValue


func _ready() -> void:
	pass_time.updated.connect(_on_time)
	_refresh()


## Mark name and time left rounded up to whole seconds, e.g. "SPEAK T-00:43".
static func format(mark: PassMark) -> String:
	var total := ceili(mark.remaining)
	return "%s T-%02d:%02d" % [mark.name, floori(total / 60.0), total % 60]


func _on_time(_previous: Variant, _current: Variant) -> void:
	_refresh()


func _refresh() -> void:
	var window := current_pass.value as PassWindow
	text = "" if window == null else WallClock.format(window.next_mark(pass_time.value))
