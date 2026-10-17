class_name ReceiverModel
extends Resource

## How the receiver hears the carrier: the tuning numbers and the math that uses them.

@export_group("Hearing")
## Degrees off target at which the carrier fades out completely.
@export_range(0.01, 10.0) var hearing_radius := 1.5

@export_group("Lock")
## Lock quality (0..1) at which an unlocked receiver locks.
@export var lock_on := 0.9
## Lock quality (0..1) below which a locked receiver drops lock.
@export var lock_off := 0.7
## Dial units off the true carrier at which lock quality reaches zero.
@export_range(0.01, 20.0) var tuning_tolerance := 2.0

@export_group("Card error")
## Degrees of star card error at window 0.
@export var card_error_base := 0.5
## Degrees added per window.
@export var card_error_step := 0.3
## Cap on the card error, in degrees.
@export var card_error_max := 4.0

@export_group("Drift")
## Degrees per second the true target moves (azimuth, elevation).
@export var dish_drift := Vector2(0.01, -0.005)
## Dial units per second the carrier frequency moves.
@export var doppler_drift := 0.02


## Degrees the star card is off in this window. Grows per window, capped.
func card_error(window_number: int) -> float:
	return minf(card_error_base + card_error_step * window_number, card_error_max)


## Where the dish must point (azimuth, elevation in degrees) `t` seconds into the pass:
## the card position, offset by the seeded card error, plus drift.
func target_at(window: PassWindow, t: float) -> Vector2:
	var rng := RandomNumberGenerator.new()
	rng.seed = window.card_seed
	var direction := Vector2.from_angle(rng.randf() * TAU)
	var card := Vector2(window.card_azimuth, window.card_elevation)
	return card + direction * card_error(window.number) + dish_drift * t


## Degrees between dish and target. Azimuth wraps around 360.
func pointing_error(dish: Vector2, target: Vector2) -> float:
	return Vector2(wrapf(dish.x - target.x, -180.0, 180.0), dish.y - target.y).length()


## Signal strength 0..1: 1 on target, 0 at `hearing_radius`.
func strength(error_deg: float) -> float:
	return clampf(1.0 - error_deg / hearing_radius, 0.0, 1.0)


## The carrier's true dial position `t` seconds into the pass.
func true_tuning(window: PassWindow, t: float) -> float:
	return window.card_tuning + doppler_drift * t


## Lock quality 0..1 from the dial error: 1 on the carrier, 0 at `tuning_tolerance`.
func lock_quality(tune_error: float) -> float:
	return clampf(1.0 - absf(tune_error) / tuning_tolerance, 0.0, 1.0)


## Lock with hysteresis: locks at `lock_on`, holds down to `lock_off`. Never without signal.
func next_locked(was_locked: bool, quality: float, signal_strength: float) -> bool:
	if signal_strength <= 0.0:
		return false
	return quality >= (lock_off if was_locked else lock_on)
