class_name Uplink
extends Node

## Runs a timed transmission of the sequence. Losing lock or LOS aborts it and keeps the sequence.

@export var model: UplinkModel
## Starts a transmission.
@export var tx_requested: Event
## Aborts a running transmission.
@export var los: Event
## Raised when a transmission completes.
@export var uplinked: Event
## The queued commands. Sets the duration, cleared on success.
@export var sequence: StringListValue
## Read. Losing it aborts a running transmission.
@export var locked: BoolValue
## Written. True while a transmission runs.
@export var transmitting: BoolValue
@export var out: StringEvent

var _remaining := 0.0


func _ready() -> void:
	tx_requested.raised.connect(_on_tx_requested)
	los.raised.connect(_on_los)
	locked.updated.connect(_on_locked)


func _process(delta: float) -> void:
	tick(delta)


## Counts the transmission down and finishes it at zero. Does nothing when idle.
func tick(delta: float) -> void:
	if not transmitting.value:
		return
	_remaining -= delta
	if _remaining <= 0.0:
		_finish()


func _on_tx_requested(_payload: Variant) -> void:
	if transmitting.value:
		out.raise("TRANSMISSION IN PROGRESS")
		return
	_remaining = model.seconds_per_command * sequence.value.size()
	transmitting.value = true
	out.raise("TRANSMITTING...")


func _on_locked(_previous: bool, current: bool) -> void:
	if transmitting.value and not current:
		_fail("UPLINK FAILED. LOCK LOST")


func _on_los(_payload: Variant) -> void:
	if transmitting.value:
		_fail("UPLINK FAILED. LOS")


func _fail(message: String) -> void:
	transmitting.value = false
	out.raise(message)


func _finish() -> void:
	# Clear the sequence before `transmitting` flips, so no handler can restart on stale commands.
	var count := sequence.value.size()
	sequence.value = PackedStringArray()
	transmitting.value = false
	out.raise("%d COMMANDS SENT." % count)
	uplinked.raise()
