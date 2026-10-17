class_name PassWindow
extends Resource

## Content of one contact window. Pure data plus lookups; it never runs anything.

## Mark names, in time order.
const MARK_NAMES: PackedStringArray = ["AOS", "TURN", "SPEAK", "LOS", "BELL"]

## 1-based. `PassLoader` picks the window by this number. 0 means not authored yet.
@export var number := 0

@export_group("Marks")
## Seconds since pass start, in time order. AOS: the carrier becomes receivable.
@export var aos := 0.0
## The probe stops speaking and starts listening.
@export var turn := 0.0
## The SPEAK lamp lights; the uplink opens.
@export var speak := 0.0
## LOS: the carrier is gone and the pass closes.
@export var los := 0.0
## The morning bell: the shift ends.
@export var bell := 0.0

@export_group("Star Card")
## Azimuth printed on the star card, in degrees.
@export var card_azimuth := 0.0
## Elevation printed on the star card, in degrees.
@export var card_elevation := 0.0
## Tuning printed on the star card, in dial units.
@export var card_tuning := 0.0
## Picks the direction of the card error.
@export var card_seed := 0

@export_group("Terminal")
## The commands this window offers. Every window needs one: Terminal and HELP read it.
@export var command_set: CommandSet


## The five mark times in `MARK_NAMES` order, in seconds.
func mark_times() -> PackedFloat64Array:
	return PackedFloat64Array([aos, turn, speak, los, bell])


## The first mark after `t` seconds and the time left to it. Stays at BELL, 0 after it.
func next_mark(t: float) -> PassMark:
	var times := mark_times()
	for i: int in range(times.size()):
		if t < times[i]:
			return PassMark.new(MARK_NAMES[i], times[i] - t)
	return PassMark.new(MARK_NAMES[MARK_NAMES.size() - 1], 0.0)
