class_name LinkStatus
extends Label

## The terminal's status bar: which way the link runs right now, from the receiver and the pass.

## What the link is doing, in priority order from LOS down to no carrier.
enum Mode {
	NO_CARRIER,
	NO_LOCK,
	DOWNLINK,
	UPLINK,
	TRANSMITTING,
	LOS,
}

## Read. Seconds since pass start, compared with LOS.
@export var pass_time: FloatValue

## Read. Supplies the LOS time.
@export var current_pass: ResourceValue

## Read. Any signal above zero means the carrier is heard.
@export var signal_strength: FloatValue

## Read. True while the receiver holds lock.
@export var locked: BoolValue

## Read. True while the uplink is open.
@export var uplink_open: BoolValue

## Read. True while a transmission runs.
@export var transmitting: BoolValue

## Shown while nothing is heard.
@export var no_carrier_text := "NO CARRIER"

## Shown while the carrier is heard but not locked.
@export var no_lock_text := "SIGNAL. NO LOCK"

## Shown while locked before the uplink opens.
@export var downlink_text := "DOWNLINK. HERALD SPEAKING"

## Shown while locked with the uplink open.
@export var uplink_text := "UPLINK. HERALD LISTENING"

## Shown while the sequence is being sent.
@export var transmitting_text := "UPLINK. TRANSMITTING"

## Shown after LOS.
@export var los_text := "LOS"

## Refreshes the bar every frame; its inputs change continuously.
func _process(_delta: float) -> void:
	refresh()

## Shows the text of the current mode.
func refresh() -> void:
	text = _text_for(mode())

## The current mode. LOS wins, then a held lock by uplink state, then whether anything is heard.
func mode() -> Mode:
	var window := current_pass.value as PassWindow
	if window != null and pass_time.value >= window.los:
		return Mode.LOS

	if locked.value:
		if transmitting.value:
			return Mode.TRANSMITTING

		return Mode.UPLINK if uplink_open.value else Mode.DOWNLINK

	return Mode.NO_LOCK if signal_strength.value > 0.0 else Mode.NO_CARRIER

## The text shown for `link_mode`.
func _text_for(link_mode: Mode) -> String:
	match link_mode:
		Mode.NO_LOCK:
			return no_lock_text
		Mode.DOWNLINK:
			return downlink_text
		Mode.UPLINK:
			return uplink_text
		Mode.TRANSMITTING:
			return transmitting_text
		Mode.LOS:
			return los_text
	return no_carrier_text
