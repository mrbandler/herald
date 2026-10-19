class_name MonitorGlow
extends ScreenGlow

## Lights the desk in front of the image monitor: faint and cool over snow, in the picture's
## average colour while one is on.

## Read. The item on the monitor, or null.
@export var shown_item: ResourceValue

## Read. SNOW shows no picture.
@export var monitor_mode: IntValue

## The light's colour over snow.
@export var snow_color := Color(0.6, 0.65, 0.8)

## The light's energy over snow.
@export var snow_energy := 0.1

## Average colour per picture, worked out once.
var _averages: Dictionary[Texture2D, Color] = { }

## Follows the monitor every frame; a new picture is averaged once.
func _process(_delta: float) -> void:
	tick()

## Shines the snow colour, or the average of the picture on show.
func tick() -> void:
	var stored := shown_item.value as StoredItem
	var snowing := monitor_mode.value == MonitorModel.Mode.SNOW
	if stored == null or snowing or stored.item.image == null:
		light_color = snow_color
		light_energy = snow_energy
		return

	var image := stored.item.image
	if not _averages.has(image):
		_averages[image] = ScreenGlow.average(image.get_image())

	shine(_averages[image])
