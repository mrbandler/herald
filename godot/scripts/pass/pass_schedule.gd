class_name PassSchedule
extends Node

## Raises each mark event when pass_time crosses its mark, in time order.

## Read only. Marks fire as this crosses them.
@export var pass_time: FloatValue

## Read only. Supplies the mark times.
@export var current_pass: ResourceValue

## Raised when `pass_time` crosses AOS.
@export var aos_event: Event

## Raised when `pass_time` crosses the UPLINK mark.
@export var speak_event: Event

## Raised when `pass_time` crosses LOS.
@export var los_event: Event

## Raised when `pass_time` crosses the morning bell.
@export var bell_event: Event

## Watches `pass_time` for crossed marks.
func _ready() -> void:
	pass_time.updated.connect(_on_time)

## Raises every mark passed between `previous` and `current`, in time order.
func _on_time(previous: float, current: float) -> void:
	var window := current_pass.value as PassWindow
	if window == null:
		return

	# Same order as PassWindow.MARK_NAMES and mark_times().
	var events: Array[Event] = [aos_event, speak_event, los_event, bell_event]
	var times := window.mark_times()

	for i: int in range(times.size()):
		# Half-open (previous, current]: a mark fires exactly once, even when time lands on it.
		if previous < times[i] and times[i] <= current:
			events[i].raise()
