class_name Uplink
extends Node

## Runs a timed transmission of the sequence. Losing lock or LOS aborts it and keeps the sequence.

## Model to use.
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

## Receives the progress and result lines. Usually stdout.
@export var out: StringEvent

## Written. The transmission's progress, cleared when it ends.
@export var progress_line: StringValue

## Seconds left in the running transmission.
var _remaining := 0.0

## Commands in the running transmission.
var _count := 0

## Listens for TX requests, LOS and lock changes.
func _ready() -> void:
	tx_requested.raised.connect(_on_tx_requested)
	los.raised.connect(_on_los)
	locked.updated.connect(_on_locked)

## Counts the transmission down each frame.
func _process(delta: float) -> void:
	tick(delta)

## Counts the transmission down and finishes it at zero. Does nothing when idle.
func tick(delta: float) -> void:
	if not transmitting.value:
		return

	_remaining -= delta
	if _remaining <= 0.0:
		_finish()
	else:
		_show_progress()

## Writes the running transmission's progress line.
func _show_progress() -> void:
	var elapsed := model.seconds_per_command * _count - _remaining
	progress_line.value = model.line(elapsed, _count)

## Starts a transmission sized by the sequence, unless one is already running.
func _on_tx_requested(_payload: Variant) -> void:
	if transmitting.value:
		out.raise("TRANSMISSION IN PROGRESS")
		return

	_count = sequence.value.size()
	_remaining = model.seconds_per_command * _count
	transmitting.value = true
	out.raise("TRANSMITTING...")
	_show_progress()

## Fails a running transmission when the lock is lost.
func _on_locked(_previous: bool, current: bool) -> void:
	if transmitting.value and not current:
		_fail("UPLINK FAILED. SIGNAL LOCK LOST")

## Fails a running transmission at LOS.
func _on_los(_payload: Variant) -> void:
	if transmitting.value:
		_fail("UPLINK FAILED. LOS")

## Stops the transmission and reports why. The sequence is kept.
func _fail(message: String) -> void:
	transmitting.value = false
	progress_line.value = ""
	out.raise(message)

## Completes the transmission: clears the sequence, reports and raises `uplinked`.
func _finish() -> void:
	# Clear the sequence before `transmitting` flips, so no handler can restart on stale commands.
	var count := sequence.value.size()
	sequence.value = PackedStringArray()
	transmitting.value = false
	progress_line.value = ""

	out.raise("%d COMMANDS SENT." % count)
	uplinked.raise()
