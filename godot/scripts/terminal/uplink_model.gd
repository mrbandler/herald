class_name UplinkModel
extends Resource

## How long the uplink takes. Lock must hold for the whole transmission.

## Transmission time per queued command, in seconds.
@export var seconds_per_command := 3.0

## Characters inside the progress bar's brackets. The game's matches the downlink's.
@export var bar_width := 10

## The transmission's progress line `elapsed` seconds into sending `count` commands, e.g.
## `XMIT SEQ [#####-----] 1/2`: the bar shows the time, the count the commands through.
func line(elapsed: float, count: int) -> String:
	var total := seconds_per_command * count
	var fraction := elapsed / total if total > 0.0 else 1.0
	var sent := mini(floori(elapsed / seconds_per_command), count)
	return "XMIT SEQ %s %d/%d" % [DownlinkModel.draw_bar(fraction, bar_width), sent, count]
