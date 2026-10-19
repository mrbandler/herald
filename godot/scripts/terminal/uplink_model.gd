class_name UplinkModel
extends Resource

## How long the uplink takes per command, and the status notices a send ends with.

## Transmission time per queued command, in seconds.
@export var seconds_per_command := 3.0

## What the status bar shows at LOS when HERALD never received ACK.
@export var ack_missed_notice := "!! NO ACK SENT !!"

## The alert box raised at LOS when HERALD never received ACK. Lines are centred.
@export_multiline var ack_missed_alert := (
	"/\\\n/  \\\n/ !! \\\n/  !!  \\\n/   !!   \\\n/          \\\n/     !!     \\\n"
	+ "/______________\\\n\n!! NO ACK SENT !!\n\n"
	+ "THE HEARTBEAT NEVER REACHED HERALD.\nHERALD HOLDS ITS PHASE AND WAITS."
)

## Characters inside the progress bar's brackets. The game's matches the downlink's.
@export var bar_width := 10

## The transmission's progress line `elapsed` seconds into sending `count` commands, e.g.
## `XMIT SEQ [#####-----] 1/2`: the bar shows the time, the count the commands through.
func line(elapsed: float, count: int) -> String:
	var total := seconds_per_command * count
	var fraction := elapsed / total if total > 0.0 else 1.0
	var sent := mini(floori(elapsed / seconds_per_command), count)
	return "XMIT SEQ %s %d/%d" % [DownlinkModel.draw_bar(fraction, bar_width), sent, count]

## The notice of a send that went through, e.g. `SEQ RECEIVED 2/3. GARBLED 1`, plus the heartbeat
## when ACK arrived.
func sent_notice(received: int, total: int, garbled: int, acknowledged: bool) -> String:
	var notice := "SEQ RECEIVED %d/%d" % [received, total]
	if garbled > 0:
		notice += ". GARBLED %d" % garbled

	return notice + _heartbeat(acknowledged)

## The notice of a send cut short by `reason`, e.g. `SEQ CUT 1/3. SIGNAL LOCK LOST`, plus the
## heartbeat when ACK arrived before the cut.
func cut_notice(received: int, total: int, reason: String, acknowledged: bool) -> String:
	return "SEQ CUT %d/%d. %s" % [received, total, reason] + _heartbeat(acknowledged)

## The heartbeat sentence when ACK arrived, otherwise nothing.
func _heartbeat(acknowledged: bool) -> String:
	return ". HEARTBEAT ACKNOWLEDGED" if acknowledged else ""
