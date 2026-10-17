class_name Receiver
extends Node

## Each frame: reads the dish, the dial and the pass, writes what the receiver hears.
## The only writer of `locked`.

@export var model: ReceiverModel
## Read. Supplies the target and the true tuning.
@export var current_pass: ResourceValue
## Read. Seconds since pass start.
@export var pass_time: FloatValue
## Read. Degrees.
@export var dish_azimuth: FloatValue
## Read. Degrees.
@export var dish_elevation: FloatValue
## Read. Dial units.
@export var tuning: FloatValue
## Read. True between AOS and LOS.
@export var carrier_present: BoolValue
## Debug: forces `locked` true, even without a carrier. After release, hysteresis keeps the
## lock until quality drops below `lock_off`.
@export var force_lock: BoolValue
## Written. 0..1, how loudly the carrier is heard.
@export var signal_strength: FloatValue
## Written. 0..1, how close the dial is to the carrier.
@export var lock_quality: FloatValue
## Written. True while locked.
@export var locked: BoolValue


func _process(_delta: float) -> void:
	sense()


## Recomputes strength, quality and lock from the current inputs.
func sense() -> void:
	var window := current_pass.value as PassWindow
	if window == null or not carrier_present.value:
		signal_strength.value = 0.0
		lock_quality.value = 0.0
		locked.value = force_lock.value
		return
	var t := pass_time.value
	var dish := Vector2(dish_azimuth.value, dish_elevation.value)
	var strength := model.strength(model.pointing_error(dish, model.target_at(window, t)))
	var quality := model.lock_quality(tuning.value - model.true_tuning(window, t))
	signal_strength.value = strength
	lock_quality.value = quality
	locked.value = force_lock.value or model.next_locked(locked.value, quality, strength)
