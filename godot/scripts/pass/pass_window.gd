class_name PassWindow
extends Resource

## Content of one contact window. Pure data plus lookups; it never runs anything.

## Mark names, in time order.
const MARK_NAMES: PackedStringArray = ["AOS", "UPLINK", "LOS", "BELL"]

## 1-based. `PassLoader` picks the window by this number. 0 means not authored yet.
@export var number := 0

@export_group("Marks")
## Seconds since pass start, in time order. AOS: the carrier becomes receivable.
@export var aos := 0.0

## The UPLINK lamp lights and HERALD starts listening; running downloads are cut off.
@export var speak := 0.0

## LOS: the carrier is gone and the pass closes.
@export var los := 0.0

## The morning bell: the shift ends.
@export var bell := 0.0

## Station time of day at pass start, in seconds after midnight. The wall clock shows it after LOS.
@export var clock_start := 0.0

## How much faster station time runs than real time after LOS, so the rest of the night passes.
@export var night_rate := 60.0

@export_group("Star Card")
## Azimuth printed on the star card, in degrees.
@export var card_azimuth := 0.0

## Elevation printed on the star card, in degrees.
@export var card_elevation := 0.0

## Tuning printed on the star card, in dial units.
@export var card_tuning := 0.0

## Picks the direction of the card error and the sign of the tuning error.
@export var card_seed := 0

## Degrees the card position is off at AOS. Negative uses the ReceiverModel formula.
@export var card_error := -1.0

## Dial units the card tuning is off at AOS. Negative uses the ReceiverModel formula.
@export var card_tuning_error := -1.0

@export_group("Desk")
## The handover letter on the desk for this window. Empty for none.
@export_multiline var letter := ""

@export_group("Downlink")
## HERALD's queue listing for this window, pushed at the first lock. Empty for none.
@export var manifest: Array[ManifestItem] = []

@export_group("Terminal")
## The commands this window offers. Every window needs one: Terminal and HELP read it.
@export var command_set: CommandSet

## Station time of day in seconds after midnight, `t` seconds into the pass. Real time until
## LOS, then `night_rate` times faster.
func station_time(t: float) -> float:
	return clock_start + minf(t, los) + maxf(t - los, 0.0) * night_rate

## The four mark times in `MARK_NAMES` order, in seconds.
func mark_times() -> PackedFloat64Array:
	return PackedFloat64Array([aos, speak, los, bell])

## The first mark after `t` seconds and the time left to it. Stays at BELL, 0 after it.
func next_mark(t: float) -> PassMark:
	var times := mark_times()

	for i: int in range(times.size()):
		if t < times[i]:
			return PassMark.new(MARK_NAMES[i], times[i] - t)

	return PassMark.new(MARK_NAMES[MARK_NAMES.size() - 1], 0.0)
