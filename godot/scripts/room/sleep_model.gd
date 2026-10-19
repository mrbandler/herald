class_name SleepModel
extends Resource

## How the Listener nods off before the morning bell, and how they fall asleep at the desk.

## Seconds before the morning bell that the blinking starts.
@export var warning_seconds := 15.0

## Seconds per blink cycle when the warning starts (x) and at the bell (y).
@export var blink_seconds := Vector2(3.5, 1.4)

## Share of a cycle the eyes are shut, when the warning starts (x) and at the bell (y).
@export var blink_duty := Vector2(0.1, 0.6)

## Head pitch down at a full blink while drowsy, in degrees.
@export var sag_degrees := 6.0

## Head pitch down once asleep on the desk, in degrees.
@export var drop_degrees := 50.0

## Head offset once asleep on the desk, in metres from the seat.
@export var drop_offset := Vector3(0.0, -0.22, -0.18)

## Share of the fall after which the eyes are fully shut.
@export var eyes_shut_at := 0.8

## Low-pass cutoff in Hz on the master bus once asleep; awake it lets everything through.
@export var muffled_hz := 300.0

## Master volume in dB once asleep.
@export var muffled_db := -18.0

## Cutoff in Hz that lets every sound through.
@export var open_hz := 20000.0

## Half the height of a lid's soft edge at full drowsiness and asleep, as a share of the screen.
@export var lid_feather := 0.12

## Seconds the sound takes to rise out of the muffle when a window starts.
@export var wake_seconds := 3.0

## How strongly the view darkens and blurs at full drowsiness, 0..1. The fall takes it to 1.
@export var haze_at_bell := 0.7

## How much further each blink pushes the haze in while the lids are shut, at full drowsiness.
@export var blink_haze := 0.2

## 0 until the warning starts, rising to 1 at the `bell`, `t` seconds into the pass.
func drowsiness(t: float, bell: float) -> float:
	return clampf((t - (bell - warning_seconds)) / warning_seconds, 0.0, 1.0)

## Seconds per blink cycle at a `drowsiness`.
func blink_period(drowsy: float) -> float:
	return lerpf(blink_seconds.x, blink_seconds.y, drowsy)

## Lid closure 0..1 at a `fraction` 0..1 through a blink cycle: shut and open again, then open.
func lid_closure(fraction: float, drowsy: float) -> float:
	var duty := lerpf(blink_duty.x, blink_duty.y, drowsy)
	if fraction >= duty:
		return 0.0

	return sin(PI * fraction / duty)

## Lid closure 0..1 at `amount` 0..1 through falling asleep.
func asleep_closure(amount: float) -> float:
	return clampf(amount / eyes_shut_at, 0.0, 1.0)

## Share 0..1 of the head drop at `amount` through falling asleep: slow at first, then it falls.
func asleep_drop(amount: float) -> float:
	return amount * amount

## The master low-pass cutoff at `amount` 0..1 through falling asleep, eased in pitch.
func muffled_cutoff(amount: float) -> float:
	return exp(lerpf(log(open_hz), log(muffled_hz), amount))

## The haze 0..1 over the view at a `drowsiness` and a lid `closure`: it grows with drowsiness, and
## each blink pushes it in further while the lids are shut.
func haze(drowsy: float, closure := 0.0) -> float:
	return clampf(haze_at_bell * drowsy + blink_haze * closure * drowsy, 0.0, 1.0)
