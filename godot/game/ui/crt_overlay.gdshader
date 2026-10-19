// A CRT's glass over a flat screen: scanlines and darker corners, drawn as a black veil over
// whatever lies beneath.
shader_type canvas_item;

// Scanlines over the screen's height.
uniform float scanlines = 240.0;

// How dark the gaps between scanlines get, 0..1.
uniform float scanline_strength = 0.3;

// How strongly the corners darken.
uniform float vignette = 0.45;

// The hum bar: a soft band rolling up the screen. Outside it the screen sits this much darker.
uniform float hum_strength = 0.2;

// Seconds the hum bar takes to roll once over the screen.
uniform float hum_seconds = 7.0;

// Height of the hum bar as a share of the screen.
uniform float hum_width = 0.035;

void fragment() {
	float scan = 0.5 + 0.5 * cos(SCREEN_UV.y * scanlines * TAU);
	vec2 edge = SCREEN_UV * (1.0 - SCREEN_UV);
	float corners = pow(clamp(edge.x * edge.y * 16.0, 0.0, 1.0), vignette);
	float centre = 1.0 - fract(TIME / hum_seconds);
	float distance = abs(fract(SCREEN_UV.y - centre + 0.5) - 0.5);
	float band = smoothstep(hum_width, 0.0, distance);
	float light = (1.0 - scanline_strength * scan) * corners * (1.0 - hum_strength * (1.0 - band));
	COLOR = vec4(0.0, 0.0, 0.0, 1.0 - light);
}
