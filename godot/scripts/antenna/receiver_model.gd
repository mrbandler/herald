class_name ReceiverModel
extends Resource

## How the receiver hears the carrier: the tuning numbers and the math that uses them.

@export_group("Hearing")
## Degrees off target at which the carrier fades out completely.
@export_range(0.01, 10.0) var hearing_radius := 1.5
## Falloff exponent: 1 is linear, higher stays faint near the edge and rises near the target.
@export_range(0.5, 4.0) var hearing_curve := 1.0

@export_group("Lock")
## Lock quality (0..1) at which an unlocked receiver locks.
@export var lock_on := 0.9
## Lock quality (0..1) below which a locked receiver drops lock.
@export var lock_off := 0.7
## Dial units off the true carrier at which lock quality reaches zero.
@export_range(0.01, 20.0) var tuning_tolerance := 2.0

@export_group("Set")
## Seconds after LOS the carrier takes to fade out. It rises over the whole prep.
@export_range(0.1, 120.0) var set_seconds := 15.0

@export_group("Card error")
## Degrees of star card error at window 0.
@export var card_error_base := 0.5
## Degrees added per window.
@export var card_error_step := 0.3
## Cap on the card error, in degrees.
@export var card_error_max := 4.0
## Dial units of tuning error at window 0: the probe's oscillator has aged since the card.
@export var tuning_error_base := 0.2
## Dial units added per window.
@export var tuning_error_step := 0.2
## Cap on the tuning error, in dial units.
@export var tuning_error_max := 2.0

@export_group("Drift")
## Degrees per second the true target moves (azimuth, elevation).
@export var dish_drift := Vector2(0.01, -0.005)
## Dial units per second the carrier frequency moves.
@export var doppler_drift := 0.02


## Degrees the star card position is off in this window: the window's own value, or one that
## grows per window, capped.
func card_error(window: PassWindow) -> float:
	if window.card_error >= 0.0:
		return window.card_error
	return minf(card_error_base + card_error_step * window.number, card_error_max)


## Signed dial units the card tuning is off in this window: the window's own size, or one that
## grows per window, capped. The seed picks the sign.
func card_tuning_offset(window: PassWindow) -> float:
	var size := window.card_tuning_error
	if size < 0.0:
		size = minf(tuning_error_base + tuning_error_step * window.number, tuning_error_max)
	var rng := RandomNumberGenerator.new()
	rng.seed = window.card_seed
	rng.randf() # The first draw is the card error direction.
	return size if rng.randf() < 0.5 else -size


## Where the dish must point (azimuth, elevation in degrees) `t` seconds into the pass:
## the card position, offset by the seeded card error at AOS, drifting through it.
func target_at(window: PassWindow, t: float) -> Vector2:
	var rng := RandomNumberGenerator.new()
	rng.seed = window.card_seed
	var direction := Vector2.from_angle(rng.randf() * TAU)
	var card := Vector2(window.card_azimuth, window.card_elevation)
	return card + direction * card_error(window) + dish_drift * (t - window.aos)


## 0..1 how far the carrier stands out of the hiss: it rises from nothing at pass start to full
## at AOS, and after LOS sets over `set_seconds`.
func presence(window: PassWindow, t: float) -> float:
	if window.aos <= 0.0:
		return 1.0
	if t < window.los:
		return clampf(t / window.aos, 0.0, 1.0)
	return clampf(1.0 - (t - window.los) / set_seconds, 0.0, 1.0)


## Degrees between dish and target. Azimuth wraps around 360.
func pointing_error(dish: Vector2, target: Vector2) -> float:
	return Vector2(wrapf(dish.x - target.x, -180.0, 180.0), dish.y - target.y).length()


## Signal strength 0..1: 1 on target, 0 at `hearing_radius`, shaped by `hearing_curve`.
func strength(error_deg: float) -> float:
	return pow(clampf(1.0 - error_deg / hearing_radius, 0.0, 1.0), hearing_curve)


## The carrier's true dial position `t` seconds into the pass: the card tuning, off by the
## tuning error at AOS, drifting through it.
func true_tuning(window: PassWindow, t: float) -> float:
	return window.card_tuning + card_tuning_offset(window) + doppler_drift * (t - window.aos)


## Lock quality 0..1 from the dial error: 1 on the carrier, 0 at `tuning_tolerance`.
func lock_quality(tune_error: float) -> float:
	return clampf(1.0 - absf(tune_error) / tuning_tolerance, 0.0, 1.0)


## Lock with hysteresis: locks at `lock_on`, holds down to `lock_off`. Never without signal.
func next_locked(was_locked: bool, quality: float, signal_strength: float) -> bool:
	if signal_strength <= 0.0:
		return false
	return quality >= (lock_off if was_locked else lock_on)
