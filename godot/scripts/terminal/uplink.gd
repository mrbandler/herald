class_name Uplink
extends Node

## Sends the sequence to HERALD one command at a time. A command arrives when its whole send
## time passes with the lock held; a dip below the signal margin garbles it and it stays queued.
## Losing lock or LOS cuts the send: the command in flight and the rest stay queued.

## Model to use.
@export var model: UplinkModel

## Supplies the signal margin a command must stay above.
@export var receiver_model: ReceiverModel

## Starts a transmission.
@export var tx_requested: Event

## Cuts a running transmission.
@export var los: Event

## The queued commands. Commands HERALD received leave it.
@export var sequence: StringListValue

## Read. Losing it cuts a running transmission.
@export var locked: BoolValue

## Read. Below the margin, the command in flight is garbled.
@export var signal_strength: FloatValue

## Written. True while a transmission runs.
@export var transmitting: BoolValue

## Receives TRANSMISSION IN PROGRESS when TX is typed during a send. Usually stdout.
@export var out: StringEvent

## Raised with each send's result for the status bar.
@export var status_notice: StringEvent

## Written. The transmission's progress, cleared when it ends.
@export var progress_line: StringValue

## Written. The commands HERALD received this window, in order. Kept across windows, so the last
## window's stay until this window's first command arrives.
@export var last_sent: StringListValue

## Written. True once HERALD received ACK.
@export var acked: BoolValue

## Raised at LOS when HERALD never received ACK, for the alarm.
@export var ack_missed: Event

## Written. Takes the alert box at LOS when HERALD never received ACK.
@export var alert: StringValue

## The commands of the running send, in order.
var _sending := PackedStringArray()

## Index into `_sending` of the command in flight.
var _index := 0

## Seconds the command in flight has been sending.
var _elapsed := 0.0

## True once the command in flight dipped below the margin.
var _dipped := false

## Indices into `_sending` that HERALD received.
var _received: Array[int] = []

## Commands of the running send that arrived garbled.
var _garbled := 0

## True once ACK arrived in the running send.
var _acknowledged := false

## The commands received this window, the source of `last_sent`.
var _received_this_window := PackedStringArray()

## Listens for TX requests, LOS and lock changes.
func _ready() -> void:
	tx_requested.raised.connect(_on_tx_requested)
	los.raised.connect(_on_los)
	locked.updated.connect(_on_locked)

## Sends each frame.
func _process(delta: float) -> void:
	tick(delta)

## Sends the command in flight for `delta` seconds, completes every command whose time is up,
## and ends the send after the last. Does nothing when idle.
func tick(delta: float) -> void:
	if not transmitting.value:
		return

	if signal_strength.value < receiver_model.margin:
		_dipped = true

	_elapsed += delta
	while _index < _sending.size() and _elapsed >= model.seconds_per_command:
		_complete_command()

	if _index >= _sending.size():
		_end(model.sent_notice(_received.size(), _sending.size(), _garbled, _acknowledged))
	else:
		_show_progress()

## Starts a send of the whole sequence, unless one is already running.
func _on_tx_requested(_payload: Variant) -> void:
	if transmitting.value:
		out.raise("TRANSMISSION IN PROGRESS")
		return

	_sending = sequence.value
	_index = 0
	_elapsed = 0.0
	_dipped = false
	_received.clear()
	_garbled = 0
	_acknowledged = false

	transmitting.value = true
	_show_progress()

## Cuts a running send when the lock is lost.
func _on_locked(_previous: bool, current: bool) -> void:
	if transmitting.value and not current:
		_cut("SIGNAL LOCK LOST")

## Cuts a running send at LOS, and sounds the alarm for a heartbeat that never arrived while the
## Listener is still awake.
func _on_los(_payload: Variant) -> void:
	if transmitting.value:
		_cut("LOS")

	if acked.value:
		return

	status_notice.raise(model.ack_missed_notice)
	alert.value = model.ack_missed_alert
	ack_missed.raise()

## HERALD takes the command in flight, or counts it garbled after a dip, and the next one starts.
func _complete_command() -> void:
	var command := _sending[_index]

	if _dipped:
		_garbled += 1
	else:
		_receive(command)

	_index += 1
	_elapsed -= model.seconds_per_command
	_dipped = false

## Records `command` as received this window, and the heartbeat when it is ACK.
func _receive(command: String) -> void:
	_received.append(_index)
	_received_this_window.append(command)
	last_sent.value = _received_this_window

	if command.get_slice(" ", 0) == "ACK":
		_acknowledged = true
		acked.value = true

## Ends the send early: the command in flight is lost and stays queued with the rest.
func _cut(reason: String) -> void:
	_end(model.cut_notice(_received.size(), _sending.size(), reason, _acknowledged))

## Stops the send, keeps every command HERALD did not receive queued in order, and reports.
func _end(notice: String) -> void:
	var left := PackedStringArray()
	for i: int in range(_sending.size()):
		if not _received.has(i):
			left.append(_sending[i])

	sequence.value = left
	transmitting.value = false
	progress_line.value = ""
	status_notice.raise(notice)

## Writes the running send's progress line.
func _show_progress() -> void:
	var elapsed := model.seconds_per_command * _index + _elapsed
	progress_line.value = model.line(elapsed, _sending.size())
