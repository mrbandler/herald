class_name ShiftEnd
extends Node

## At the morning bell (or a pull of the lamp chain): ends the shift, dims the lamp, lets the
## Listener fall asleep and reloads the room. It also advances the campaign to the next window.
## Greybox stand-in for the tube report.

## Collection of global tunables.
@export var tunables: Tunables

## Starts the end of the shift.
@export var morning_bell: Event

## Raised right after the report, so the clock stops.
@export var shift_ended: Event

## Raised by one when the shift ends, so the next room load picks the next window.
@export var window_number: IntValue

## Optional. Falls asleep before the reload. Tests leave it unset.
@export var sleep: Sleep

## Dimmed to dark while the Listener falls asleep: the desk lamps.
@export var lamps: Array[Light3D] = []

## Read. The window ending, for its required command. Optional.
@export var current_pass: ResourceValue

## Read. The commands HERALD received this window.
@export var last_sent: StringListValue

## Shown instead of the next window when the required command never arrived.
@export var end_card: EndCard

## The heading of the card for a missed required command.
@export var lost_title := "HERALD IS LOST"

## True once the shift has ended, so a second bell or pull does nothing.
var _ended := false

## Listens for the morning bell.
func _ready() -> void:
	morning_bell.raised.connect(_on_bell)

## Ends the shift, then falls asleep and reloads the room.
func _on_bell(_payload: Variant) -> void:
	# The chain and the bell can both fire; the shift ends once.
	if _ended:
		return

	_ended = true
	var missed := missed_command()
	if missed.is_empty():
		window_number.value += 1

	shift_ended.raise()

	if sleep == null:
		return

	var tween := create_tween()
	tween.tween_method(sleep.fall, 0.0, 1.0, tunables.shift_fade_seconds)

	for lamp: Light3D in lamps:
		tween.parallel().tween_property(lamp, "light_energy", 0.0, tunables.shift_fade_seconds)

	tween.tween_callback(_after_sleep.bind(missed))

## The command this window required that HERALD never received; empty when none. A key held back
## for a missed ACK makes it unsendable, and that loses too.
func missed_command() -> String:
	var window := current_pass.value as PassWindow if current_pass != null else null
	if window == null or window.required.is_empty():
		return ""

	return "" if last_sent.value.has(window.required) else window.required

## Reloads into the next window, or shows the end card for a missed required command.
func _after_sleep(missed: String) -> void:
	if missed.is_empty() or end_card == null:
		get_tree().reload_current_scene()
		return

	end_card.show_card(lost_title, (current_pass.value as PassWindow).missed_text, true)
