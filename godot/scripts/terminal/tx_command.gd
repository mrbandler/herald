class_name TxCommand
extends Command

## TX checks that the uplink can start, then hands the timed transmission to Uplink.

## Read. The uplink only works while true.
@export var speak_open: BoolValue
## Read. Must not be empty.
@export var sequence: StringListValue
## Read. Must be true.
@export var locked: BoolValue
## Raised when all checks pass. `Uplink` does the transmission.
@export var tx_requested: Event


## Raises `tx_requested`, or writes why it cannot.
func run(args: PackedStringArray) -> void:
	if not args.is_empty():
		write("USAGE: TX")
	elif not speak_open.value:
		write("UPLINK CLOSED")
	elif sequence.value.is_empty():
		write("SEQUENCE EMPTY")
	elif not locked.value:
		write("NO LOCK")
	else:
		tx_requested.raise()
