class_name ScreenGlow
extends OmniLight3D

## Lights the desk in front of a screen in the colour it shows: the screen's average colour,
## sampled a few times a second.

## The screen's picture. Optional for subclasses that pick their colour another way.
@export var viewport: SubViewport

## Seconds between samples. Reading the picture back stalls the GPU, so not every frame.
@export var interval := 0.25

## Light energy for a fully white screen.
@export var energy_scale := 5.0

## Seconds since the last sample.
var _elapsed := INF

## Samples the screen every `interval` seconds.
func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed < interval or viewport == null:
		return

	_elapsed = 0.0
	shine(ScreenGlow.average(viewport.get_texture().get_image()))

## Takes `colour` as the light: its hue as the light colour, its brightness as the energy.
func shine(colour: Color) -> void:
	var peak := maxf(colour.r, maxf(colour.g, colour.b))
	light_color = Color.WHITE
	if peak > 0.0:
		light_color = Color(colour.r / peak, colour.g / peak, colour.b / peak)

	light_energy = colour.get_luminance() * energy_scale

## The average colour of `image`, halved down to a few pixels. Changes `image`.
static func average(image: Image) -> Color:
	if image.is_compressed():
		image.decompress()

	image.convert(Image.FORMAT_RGBA8)
	while image.get_width() > 8 or image.get_height() > 8:
		image.shrink_x2()

	var total := Color(0.0, 0.0, 0.0, 0.0)
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			total += image.get_pixel(x, y)

	var count := float(image.get_width() * image.get_height())
	return Color(total.r / count, total.g / count, total.b / count)
