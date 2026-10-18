class_name LampModel
extends Resource

## How console lamps light: steady when on, blinking while only the blink source is up.

## How a lamp is lit.
enum State {
	OFF,
	BLINK,
	ON,
}

## Blinks per second.
@export var blink_rate := 3.0

## Emission energy while lit.
@export var on_energy := 4.0

## Emission energy while dark.
@export var off_energy := 0.0

## ON if `on`, else BLINK while `blink_level` is above zero, else OFF.
func state(on: bool, blink_level: float) -> State:
	if on:
		return State.ON

	return State.BLINK if blink_level > 0.0 else State.OFF

## Emission energy for a state at time `seconds`. BLINK is on for half of each period.
func energy(lamp_state: State, seconds: float) -> float:
	match lamp_state:
		State.ON:
			return on_energy
		State.BLINK:
			return on_energy if fmod(seconds * blink_rate, 1.0) < 0.5 else off_energy
	return off_energy
