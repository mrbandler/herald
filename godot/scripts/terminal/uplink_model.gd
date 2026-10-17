class_name UplinkModel
extends Resource

## How long the uplink takes. Lock must hold for the whole transmission.

## Transmission time per queued command, in seconds.
@export var seconds_per_command := 3.0
