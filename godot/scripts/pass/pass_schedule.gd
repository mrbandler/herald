class_name PassSchedule
extends Node

## Raises each mark event when pass_time crosses its mark, in time order.

## Read only. Marks fire as this crosses them.
@export var pass_time: FloatValue
## Read only. Supplies the mark times.
@export var current_pass: ResourceValue
@export var aos_event: Event
@export var turn_event: Event
@export var speak_event: Event
@export var los_event: Event
@export var bell_event: Event


func _ready() -> void:
	pass_time.updated.connect(_on_time)


func _on_time(previous: float, current: float) -> void:
	var window := current_pass.value as PassWindow
	if window == null:
		return
	var times := window.mark_times()
	# Same order as PassWindow.MARK_NAMES and mark_times().
	var events: Array[Event] = [aos_event, turn_event, speak_event, los_event, bell_event]
	for i: int in range(times.size()):
		# Half-open (previous, current]: a mark fires exactly once, even when time lands on it.
		if previous < times[i] and times[i] <= current:
			events[i].raise()
