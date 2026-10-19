// The terminal's glass: the screen viewport bent like a CRT face, with scanlines, a little
// phosphor bleed and darker corners.
shader_type spatial;
render_mode unshaded;

// The terminal's SubViewport.
uniform sampler2D display : source_color, filter_linear, repeat_disable;

// How far the picture bows away from the corners. 0 is flat.
uniform float curvature = 0.025;

// How dark the gaps between scanlines get, 0..1.
uniform float scanline_strength = 0.25;

// Scanlines over the screen's height.
uniform float scanlines = 240.0;

// How strongly the corners darken.
uniform float vignette = 0.1;

// The faint glow of the phosphor even where the screen is black, so the scanlines show.
uniform vec3 phosphor : source_color = vec3(0.045, 0.03, 0.012);

// The hum bar: a thin band rolling up the picture, as on old sets, that lifts the glow beneath
// it by this share. Black stays black.
uniform float hum_strength = 0.15;


// Seconds the hum bar takes to roll once over the picture.
uniform float hum_seconds = 7.0;

// Height of the hum bar as a share of the picture.
uniform float hum_width = 0.035;

// Overall brightness of the phosphor.
uniform float glow = 1.3;

// 0..1 where the rolling hum bar lies over `y`, softly faded at its edges.
float hum_bar(float y, float time, float seconds, float width) {
	float centre = 1.0 - fract(time / seconds);
	float distance = abs(fract(y - centre + 0.5) - 0.5);
	return smoothstep(width, 0.0, distance);
}

void fragment() {
	vec2 centred = UV * 2.0 - 1.0;
	centred *= 1.0 + curvature * dot(centred, centred);
	vec2 uv = centred * 0.5 + 0.5;

	if (any(lessThan(uv, vec2(0.0))) || any(greaterThan(uv, vec2(1.0)))) {
		ALBEDO = vec3(0.0);
	} else {
		vec2 texel = 1.0 / vec2(textureSize(display, 0));
		vec3 colour = texture(display, uv).rgb;
		vec3 bleed = texture(display, uv - vec2(texel.x, 0.0)).rgb;
		colour = max(colour, bleed * 0.45) + phosphor;

		float scan = 1.0 - scanline_strength * (0.5 + 0.5 * cos(uv.y * scanlines * TAU));
		vec2 edge = uv * (1.0 - uv);
		float shade = pow(clamp(edge.x * edge.y * 16.0, 0.0, 1.0), vignette);
		float band = hum_bar(uv.y, TIME, hum_seconds, hum_width);
		ALBEDO = colour * (1.0 + hum_strength * band) * scan * shade * glow;
	}
}
