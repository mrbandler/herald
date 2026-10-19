// A CRT's glass over a flat screen: scanlines, darker corners and a rolling roll bar, drawn as a
// black veil over whatever lies beneath.
shader_type canvas_item;
#include "res://game/ui/roll_bar.gdshaderinc"

// Scanlines over the screen's height.
uniform float scanlines = 240.0;

// How dark the gaps between scanlines get, 0..1.
uniform float scanline_strength = 0.3;

// How strongly the corners darken.
uniform float vignette = 0.45;

// The roll bar: how dark its stripe gets, 0..1.
uniform float roll_darkness = 0.45;

// How far the roll bar's leading edge thins the veil, 0..1.
uniform float roll_glow = 0.35;

// Seconds the roll bar takes to roll once over the screen.
uniform float roll_seconds = 7.0;

// Height of the roll bar's stripe as a share of the screen.
uniform float roll_width = 0.02;

void fragment() {
	float scan = 0.5 + 0.5 * cos(SCREEN_UV.y * scanlines * TAU);
	vec2 edge = SCREEN_UV * (1.0 - SCREEN_UV);
	float corners = pow(clamp(edge.x * edge.y * 16.0, 0.0, 1.0), vignette);
	float dark = roll_dark(SCREEN_UV.y, TIME, roll_seconds, roll_width);
	float lead = roll_edge(SCREEN_UV.y, TIME, roll_seconds, roll_width);
	float light = (1.0 - scanline_strength * scan) * corners * (1.0 - roll_darkness * dark);
	light = mix(light, 1.0, roll_glow * lead);
	COLOR = vec4(0.0, 0.0, 0.0, 1.0 - light);
}
