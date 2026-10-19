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

## Raised with short notices that replace the mode text for `notice_seconds`. Optional.
@export var status_notice: StringEvent

## Seconds a notice stays before the mode text returns.
@export var notice_seconds := 4.0

## The band behind the text, coloured by the mode. Optional.
@export var band: ColorRect

## Band colour while the lock holds, and text colour on the dark band without lock.
@export var lit_color := Color(1, 0.72, 0.25)

## Band colour without lock: the screen's background.
@export var dark_color := Color(0.02, 0.015, 0.01)

## Text colour on the lit band.
@export var ink_color := Color(0.1, 0.07, 0.02)

## Text colour while nothing is heard and after LOS.
@export var dim_color := Color(0.6, 0.42, 0.14)

## How long the band blinks after the mode changes, in seconds.
@export var blink_seconds := 0.9

## One blink, on then off, in seconds.
@export var blink_period := 0.3

## The notice on show, or empty for none.
var _notice := ""

## Seconds left on the notice.
var _notice_left := 0.0

## The mode drawn last, compared to start a blink.
var _last_mode := Mode.NO_CARRIER

## False until the first draw, so the first mode does not blink.
var _drawn := false

## Seconds since the last mode change.
var _blink_elapsed := INF

## Listens for notices.
func _ready() -> void:
	if status_notice != null:
		status_notice.raised.connect(_on_notice)

## Advances the notice timer and refreshes every frame; the inputs change continuously.
func _process(delta: float) -> void:
	tick(delta)

## Counts the notice and the blink on by `delta` seconds, then shows the notice or the
## current mode.
func tick(delta: float) -> void:
	_blink_elapsed += delta
	if _notice_left > 0.0:
		_notice_left -= delta
		if _notice_left <= 0.0:
			_notice = ""

	refresh()

## Shows the notice if one is on show, otherwise the text of the current mode, and colours
## the band. A mode change starts a blink.
func refresh() -> void:
	var current := mode()
	if _drawn and current != _last_mode:
		_blink_elapsed = 0.0

	_last_mode = current
	_drawn = true

	text = _notice if not _notice.is_empty() else _text_for(current)
	_paint(current)

## Lights the band while the lock holds and darkens it otherwise. A blink swaps band and text.
func _paint(link_mode: Mode) -> void:
	var held := link_mode in [Mode.DOWNLINK, Mode.UPLINK, Mode.TRANSMITTING]
	var quiet := link_mode in [Mode.NO_CARRIER, Mode.LOS]
	var band_color := lit_color if held else dark_color
	var text_color := ink_color if held else (dim_color if quiet else lit_color)

	var blinking := _blink_elapsed < blink_seconds
	if blinking and fmod(_blink_elapsed, blink_period) < blink_period / 2.0:
		var swapped := band_color
		band_color = text_color
		text_color = swapped

	add_theme_color_override("font_color", text_color)
	if band != null:
		band.color = band_color

## Shows `line` for `notice_seconds`, over any mode, LOS included.
func _on_notice(line: String) -> void:
	_notice = line
	_notice_left = notice_seconds
	refresh()

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
