class_name PassFixture
extends RefCounted

## Window 1 from the GDD time budget and Star Card, for tests.


static func window_one() -> PassWindow:
	var window := PassWindow.new()
	window.number = 1
	window.aos = 30.0
	window.turn = 75.0
	window.speak = 95.0
	window.los = 115.0
	window.bell = 175.0
	window.card_azimuth = 214.6
	window.card_elevation = 38.2
	window.card_tuning = 52.0
	window.card_seed = 1
	return window
