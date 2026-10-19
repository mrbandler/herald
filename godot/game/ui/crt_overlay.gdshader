// A CRT's glass over a flat screen: scanlines and darker corners, drawn as a black veil over
// whatever lies beneath.
shader_type canvas_item;

// Scanlines over the screen's height.
uniform float scanlines = 360.0;

// How dark the gaps between scanlines get, 0..1.
uniform float scanline_strength = 0.2;

// How strongly the corners darken.
uniform float vignette = 0.45;

void fragment() {
	float scan = 0.5 + 0.5 * cos(SCREEN_UV.y * scanlines * TAU);
	vec2 edge = SCREEN_UV * (1.0 - SCREEN_UV);
	float corners = pow(clamp(edge.x * edge.y * 16.0, 0.0, 1.0), vignette);
	float light = (1.0 - scanline_strength * scan) * corners;
	COLOR = vec4(0.0, 0.0, 0.0, 1.0 - light);
}
